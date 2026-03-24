--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
--[[-------------------------------------------------------------------
Backdrop
@see Modules/Flyout/EquipmentSlotFlyout.xml#Flyout
---------------------------------------------------------------------]]
GEARS_BACKDROP_TOAST_12_12 = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
  tile = true,
  tileEdge = true,
  tileSize = 12,
  edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
};

--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_IsSlotIgnoredForSave = C_EquipmentSet and C_EquipmentSet.IsSlotIgnoredForSave
local C_GetIgnoredSlots = C_EquipmentSet and C_EquipmentSet.GetIgnoredSlots
local C_PickupContainerItem = C_Container and C_Container.PickupContainerItem
local EquipCursorItem, GameTooltip_ShowCompareItem = EquipCursorItem, GameTooltip_ShowCompareItem

--[[-------------------------------------------------------------------
Types
---------------------------------------------------------------------]]
--- @class FlyoutFrame__ : Frame Flyout Container
--- @field PlaceInBagsButton PlaceInBagsSlotActionButton
--- @field IgnoreSlotButton IgnoreSlotActionButton
--- @field anim AnimationGroup
--- @field buttons ButtonObj[]
--- @field GetParent fun(self:FlyoutFrame__) : EquipmentSlotFlyout
--
--- @alias FlyoutFrame FlyoutFrame__ | FrameObjWithBackdrop
--
--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutMixin
-------------------------------------------------------------------------------]]
local libName = 'EquipmentSlotFlyoutMixin'
--- @class EquipmentSlotFlyoutMixin : Button
--- @field TemplateName string
--- @field GetID fun(self:EquipmentSlotFlyoutMixin) : number @The equipment slot identifier
--- @field widget EquipmentSlotFlyoutWidget
--- @field Flyout FlyoutFrame Flyout Container
--- @field Arrow TextureObj
--- @see EquipmentSlotFlyoutManager#Create(slotInfo, slotButton
Gears_EquipmentSlotFlyoutMixin = ns:AceEvent()
--
--- @alias EquipmentSlotFlyout EquipmentSlotFlyoutMixin|ButtonObj|AceEvent_3_0
--
local p, pd, t, tf = ns:log(libName)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function inventorUtil() return ns.O.InventoryUtil end

--- @param self EquipmentSlotFlyout
local function __Trace_OnClick(self)
  local slotID = self:GetSlotID()
  local isIgnoredForSave = C_IsSlotIgnoredForSave(slotID)
  ns.gears:WithSelectedEquipmentSet(function(sel)
    t('OnClick', 'set=', sel.info.name, 'slot=', slotID,
            'ignored-for-save=', isIgnoredForSave,
            'currently-ignored=', self.widget:IsIgnored())
  end)
end

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type EquipmentSlotFlyoutMixin | EquipmentSlotFlyout
local o = Gears_EquipmentSlotFlyoutMixin
--- @see EquipmentSlotFlyout.xml/GearsEquipmentSlotFlyoutTemplate
o.TemplateName = 'GearsEquipmentSlotFlyoutTemplate'

--[[-------------------------------------------------------------------
Mixin: EquipmentSlotFlyoutWidgetMixin
---------------------------------------------------------------------]]
--- @class EquipmentSlotFlyoutWidgetMixin
local EquipmentSlotFlyoutWidgetMixin = {}
--
--- @alias EquipmentSlotFlyoutWidget EquipmentSlotFlyoutWidgetMixin
--
local function EquipmentSlotFlyoutWidgetMixin_Methods()
  --- @type EquipmentSlotFlyoutWidgetMixin | EquipmentSlotFlyoutWidget
  local w = EquipmentSlotFlyoutWidgetMixin
  
  --- @param slotFlyout EquipmentSlotFlyout
  --- @param slotInfo InventorySlotInfo
  --- @param slotButton BlizzCharacterSlotItemButton
  function w:Init(slotFlyout, slotInfo, slotButton)
    self.frame = slotFlyout
    self.flyoutFrame = slotFlyout.Flyout
    self.info = slotInfo
    self.charSlotButton = slotButton
  end
  --- @return SlotID
  function w:GetSlotID() return self.frame:GetSlotID() end
  --- @return boolean
  function w:IsCharacterSlotShown()
    return self.charSlotButton and self.charSlotButton:IsShown()
  end
  --- @return boolean
  function w:ShouldShowSlotGroup()
    return self:IsCharacterSlotShown()
            and ns.gears:HasSelection()
            and ns.gears:IsShown()
  end
  --- @param ignored boolean
  function w:SyncIgnoredState(ignored)
    self:isb().widget:SyncIgnoredState(ignored)
  end
  --- @return boolean
  function w:IsIgnored()
    local ignored = false
    ns.gears:WithSelectedEquipmentSet(function(sel)
      local slotID = self:GetSlotID()
      local ignoredSlots = C_GetIgnoredSlots(sel:GetIdentity())
      ignored = ignoredSlots and ignoredSlots[slotID]
    end)
    return ignored
  end
  
  --- @return boolean
  function w:IsIgnoredForSave() return C_IsSlotIgnoredForSave(self:GetSlotID()) end

  function w:GetIgnoreSlotButton() return self.flyoutFrame.IgnoreSlotButton end
  function w:isb() return self:GetIgnoreSlotButton() end
  
  --- Some equipment slots (e.g. CharacterAmmoSlot) are not
  --- applicable to the player's class and should be hidden.
  function w:ShowSlotGroup()
    if not self:ShouldShowSlotGroup() then self:HideSlotGroup() return end
    self.frame:Show()
    self.frame:ClosePopup()
  end
  
  function w:HideSlotGroup()
    self.frame:Hide()
    self.frame:ClosePopup()
    
    -- hide ignore overlay if present (reset visual state)
    local slot = self.charSlotButton
    if slot and slot.ignoreSlotOverlay then
      slot.ignoreSlotOverlay:Hide()
    end
  end
end; EquipmentSlotFlyoutWidgetMixin_Methods()

--[[-------------------------------------------------------------------
EquipmentSlotFlyout: Methods
---------------------------------------------------------------------]]
function o:OnLoad()
  self.Flyout:SetBackdropColor(0.34, 0.21, 0.13, 0.96)
  self.Flyout:SetBackdropBorderColor(0.55, 0.65, 0.25, 1)
  
  self.Arrow:SetTexture(310765);
  self.Arrow:SetTexCoord(0.02, 0.98, 0.02, 0.48);
  
  self:Hide()
  self:ClosePopup()
end

function o:OnClick()
  if self.Flyout:IsShown() then
    ns:PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
    self:ClosePopup()
    return
  end
  --__Trace_OnClick(self)
  ns:PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
  self:CreateSlotItems()
  self:OpenPopup()
  self:SendMessage(ns:msg('SlotOpened'), self:GetSlotID())
end

function o:OnSlotOpened(evt, slotID)
  if self:GetSlotID() == slotID then return end
  -- close the popups of non-active slots
  if self.Flyout:IsShown() then self:ClosePopup(); return end
end

function o:OnShowPaperDollFrame() self.widget:ShowSlotGroup() end

--- Creates buttons for each candidate items
--- using template GearsEquipmentSlotActionButtonTemplate
function o:CreateSlotItems()
  local flyout = self.Flyout
  local slotID = self:GetSlotID()
  
  -- 1. Clear existing dynamic buttons (keep first 2: Place + Ignore)
  if flyout.buttons then
    for i = #flyout.buttons, 3, -1 do
      local btn = flyout.buttons[i]
      btn:Hide()
      btn:SetParent(nil) -- allow GC (simple approach)
      flyout.buttons[i] = nil
    end
  else
    flyout.buttons = {}
  end
  
  local prev = flyout.IgnoreSlotButton
  local spacing = 2
  local totalWidth = 0
  
  -- include base buttons width
  if flyout.PlaceInBagsButton then
    totalWidth = totalWidth + flyout.PlaceInBagsButton:GetWidth()
  end
  if flyout.IgnoreSlotButton then
    totalWidth = totalWidth + flyout.IgnoreSlotButton:GetWidth()
  end
  
  -- 2. Create item buttons
  inventorUtil():ForEachBagItemMatchingSlot(slotID, function(info, item)
    --- @type ButtonObj
    local btn = CreateFrame('Button', nil, flyout, 'GearsEquipmentSlotActionButtonTemplate')
    btn:SetParentKey(('ItemButton%d'):format(#flyout.buttons + 1))
    if info.iconFileID then btn.Icon:SetTexture(info.iconFileID) end
    btn:ClearAllPoints()
    btn:SetPoint('LEFT', prev, 'RIGHT', spacing, 0)
    
    table.insert(flyout.buttons, btn)
    
    prev = btn
    totalWidth = totalWidth + btn:GetWidth() + spacing
    
    local slotFlyout = self
    btn:SetScript('OnClick', function(self)
      if InCombatLockdown() then return end
      if not (info.bagID and info.slotIndex) then return end
      C_PickupContainerItem(info.bagID, info.slotIndex)
      EquipCursorItem(slotFlyout:GetSlotID())
      slotFlyout:ClosePopup()
    end)
    
    btn:SetScript('OnEnter', function(self)
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
      GameTooltip:SetInventoryItemByID(info.itemID)
      GameTooltip:Show()
      GameTooltip_ShowCompareItem(GameTooltip)
    end)
    
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
  end)
  
  -- 3. Resize flyout (horizontal growth)
  local padding = 16
  flyout:SetWidth(totalWidth + padding)
end

function o:CreateEquipmentSlotItems()

end

-- Gears_EquipmentSlotFlyoutMixin
--- /dump PaperDollFrame.HeadSlotFlyout
--- @param slotInfo InventorySlotInfo
--- @param characterSlotButton BlizzCharacterSlotItemButton
--- @return EquipmentSlotFlyout
function o:Create(slotInfo, characterSlotButton)
  --- @type EquipmentSlotFlyout
  local slotFlyout = CreateFrame('Button', nil, PaperDollFrame, self.TemplateName, slotInfo.id)
  local name = slotInfo.name .. 'Flyout'
  slotFlyout:SetParentKey(name)
  slotFlyout.widget = CreateAndInitFromMixin(EquipmentSlotFlyoutWidgetMixin, slotFlyout, slotInfo, characterSlotButton)
  slotFlyout:CreateActionButtons()
  slotFlyout:SetHeight(24)
  slotFlyout:ClearAllPoints()
  local ofsx, ofsy = -7, 0
  --if ns:HasBlizzEquipmentManager() then ofsx = -10 end
  slotFlyout:SetPoint('LEFT', slotFlyout.widget.charSlotButton, 'RIGHT', ofsx, ofsy)
  slotFlyout:RegisterMessage(ns:msg('SlotOpened'), 'OnSlotOpened')
  slotFlyout:RegisterMessage(ns:msg('ShowPaperDollFrame'), 'OnShowPaperDollFrame')
  
  return slotFlyout
end

function o:CreateActionButtons()
  local flyout = self.widget.flyoutFrame
  flyout.buttons = {}
  
  --- @type ButtonObj - Include Button
  local placeInBagsBtn = CreateFrame("Button", nil, flyout, Gears_PlaceInBagsSlotActionButtonMixin.TemplateName)
  placeInBagsBtn:ClearAllPoints()
  placeInBagsBtn:SetPoint("LEFT", flyout, "LEFT", 8, 0)
  flyout.PlaceInBagsButton = placeInBagsBtn
  table.insert(flyout.buttons, placeInBagsBtn)
  
  --- @type IgnoreSlotActionButton
  local ignoreSlotBtn = CreateFrame("Button", nil, flyout, Gears_IgnoreSlotActionButtonMixin.TemplateName)
  ignoreSlotBtn:ClearAllPoints()
  ignoreSlotBtn:SetPoint("LEFT", placeInBagsBtn, "RIGHT", 1, 0)
  flyout.IgnoreSlotButton = ignoreSlotBtn
  table.insert(flyout.buttons, ignoreSlotBtn)
  
  local widthPadding = 16
  flyout:SetWidth(placeInBagsBtn:GetWidth() + ignoreSlotBtn:GetWidth() + widthPadding)
  flyout:SetHeight(flyout:GetHeight() + 4)
end

function o:OpenPopup()
  self.Flyout.anim:Play()
  self:__ExpandedArrow()
end

--- Hides the flyout popup frame
--- (not the top-most(parent) flyout button)
function o:ClosePopup()
  if not self.Flyout:IsShown() then return end
  self:__CollapsedArrow()
  self.Flyout:Hide()
end

function o:OnEnter()
  self.Arrow:SetVertexColor(0.4, 0.95, 0.4, 1)
  self.Arrow:SetBlendMode("BLEND")
end

function o:OnLeave()
  self.Arrow:SetVertexColor(1, 1, 1, 1)
  self.Arrow:SetBlendMode("BLEND")
end

--- @return SlotID
function o:GetSlotID() return self:GetID() end

-- ▶ collapsed
function o:__CollapsedArrow() self.Arrow:SetRotation(math.rad(-90)) end
-- ◀ expanded
function o:__ExpandedArrow() self.Arrow:SetRotation(math.rad(90)) end

function o:__GetDebugName()
  local info = self.widget.info
  return ('%s::%s'):format(info.name, info.id, self.widget.charSlotButton:GetName())
end

