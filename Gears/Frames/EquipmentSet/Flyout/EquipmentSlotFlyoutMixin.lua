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
--- @field __interactionMode boolean Internal use for immediate interaction on flyouts

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
    self.__interactionMode = nil
  end
  --- @return SlotID
  function w:GetSlotID() return self.frame:GetSlotID() end
  --- @return boolean
  function w:IsCharacterSlotShown()
    return self.charSlotButton and self.charSlotButton:IsShown()
  end
  --- @return boolean
  function w:IsGearsShown() return ns.gears:IsShown() end
  --- @param mode boolean
  function w:SetInteractionMode(mode) self.__interactionMode = mode end
  function w:IsInteractionMode() return self.__interactionMode == true end
  function w:ClearInteractionMode() self:SetInteractionMode(nil) end
  
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
  function w:CreateSlotItems() self.frame:CreateSlotItems() end
  
  -- Shows and opens this slot's flyout for direct interaction
  function w:OpenPopup()
    self:__OpenPopupSound()
    self:ShowSlotGroup()
    self:ShowFlyoutActions()
  end
  
  --- Closes/Collapses the flyout button
  --- (not the top-most(parent) flyout button)
  ---@param resetSlot boolean Resets the slot group; default is false
  function w:ClosePopup(resetSlot, closeSound)
    self:__ClosePopupSound(closeSound)
    self:HideFlyoutActions()
    self:__ShowExpandArrow()
    
    if not self:IsGearsShown() then self:HidePopup() end
    
    if resetSlot then self:__ResetSlot() end
    
    self:ClearInteractionMode()
  end
  
  function w:ShowFlyoutActions()
    self:CreateSlotItems()
    self.frame.Flyout:PlayAnimation()
    self:__ShowCollapseArrow()
    self:NotifyOpened()
  end
  function w:HideFlyoutActions() return self.frame.Flyout:Hide() end
  function w:HidePopup()
    self.flyoutFrame:StopAnimation()
    self.frame:Hide()
  end
  function w:NotifyOpened() self.frame:SendMessage(ns:msg('SlotOpened'), self:GetSlotID()) end
  
  --- Some equipment slots (e.g. CharacterAmmoSlot) are not
  --- applicable to the player's class and should be hidden.
  function w:ShowSlotGroup() self.frame:Show() end
  
  --- @return boolean
  function w:IsExpanded() return self.flyoutFrame:IsShown() end
  --- @return boolean
  function w:IsCollapsed() return not self:IsExpanded() end
  
  --- ###############################################
  --- Private Methods
  --- ###############################################
  
  function w:__ResetSlot()
    -- hide ignore overlay if present (reset visual state)
    local slot = self.charSlotButton
    if slot and slot.ignoreSlotOverlay then
      slot.ignoreSlotOverlay:Hide()
    end
  end

  -- todo next: rename functions with underscore
  -- Show Arrow ▶
  function w:__ShowExpandArrow()
    if self.frame:IsDownExpand() then
      self.frame.Arrow:SetRotation(math.rad(180))
      return
    end
    self.frame.Arrow:SetRotation(math.rad(-90))
  end
  -- Show Arrow ◀
  function w:__ShowCollapseArrow()
    if self.frame:IsDownExpand() then
      self.frame.Arrow:SetRotation(math.rad(0))
      return
    end
    self.frame.Arrow:SetRotation(math.rad(90))
  end
  
  function w:__OpenPopupSound()
    if self:IsInteractionMode() then return end
    --t('__OpenPopupSound', 'intmode=', self:IsInteractionMode())
    ns:PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
  end
  
  --- We want to play sound only when clicking
  --- an opened slot and not in interactive mode.
  --- @param alwaysPlay boolean
  function w:__ClosePopupSound(alwaysPlay)
    if alwaysPlay == false or self:IsInteractionMode() then return end
    ns:PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
  end
  
  function w:n() return self.charSlotButton:GetName() end
  function w:ndbg() return ('%s::%s'):format(self.info.name, self.info.id, self:n()) end
  
end; EquipmentSlotFlyoutWidgetMixin_Methods()

--- @param fo FlyoutFrame__ | FlyoutFrame
--- @param slot EquipmentSlotFlyout
local function FlyoutFrameMixin_Methods(fo, slot)
  
  function fo:OnLoad()
    self:SetBackdropColor(0.34, 0.21, 0.13, 0.96)
    self:SetBackdropBorderColor(0.55, 0.65, 0.25, 1)
  end
  function fo:OnPlay()
    self:SetAlpha(0)
    self:Show()
  end
  function fo:OnFinished()
    self:SetAlpha(1)
  end
  
  function fo:AnchorForDownExpansion()
    self:ClearAllPoints()
    self:SetPoint('TOPLEFT', self:GetParent(), 'BOTTOMLEFT', -14, 8)
  end
  function fo:PlayAnimation()
    self:StopAnimation()
    
    if slot.widget:IsInteractionMode() then
      self:SetAlpha(1.0)
      self:Show()
      return
    end
    
    self:Show()
    self.anim:Play()
  end
  function fo:StopAnimation()
    if self.anim:IsPlaying() then self.anim:Stop() end
    self:SetAlpha(1.0)
  end
end

--[[-------------------------------------------------------------------
EquipmentSlotFlyout: Methods
---------------------------------------------------------------------]]
function o:OnLoad()
  FlyoutFrameMixin_Methods(self.Flyout, self)
  self.Flyout:OnLoad()
  
  self.Arrow:SetTexture(310765);
  self.Arrow:SetTexCoord(0.02, 0.98, 0.02, 0.48);
  if not self:IsDownExpand() then return end
  
  self.Flyout:AnchorForDownExpansion()
end

function o:ApplyInitialState()
  self:Hide()
  self.widget:__ShowExpandArrow()
  self.widget:HideFlyoutActions()
end

function o:OnClick()
  if self.widget:IsExpanded() then
    return self.widget:ClosePopup(false, true)
  end
  self.widget:OpenPopup()
end

function o:OnSlotOpened(evt, slotID)
  if self:GetSlotID() == slotID then return end
  -- close the other expanded flyouts
  if self.widget:IsExpanded() then self.widget:ClosePopup(false, false); return end
end

function o:OnSlotEnter(evt, slotID)
  if self:GetSlotID() == slotID then return end
  if not self.widget:IsExpanded() then return end
  self.widget:ClosePopup(false, false)
end

function o:OnEquipmentSetSelected(evt, slotID)
  if not self.widget:IsExpanded() then return end
  self.widget:ClosePopup(false, false)
end

function o:OnShowPaperDollFrame()
  if not self.widget:ShouldShowSlotGroup() then self.widget:ClosePopup() return end
  self.widget:ShowSlotGroup() end

--- Creates buttons for each candidate items
--- using template GearsEquipmentSlotActionButtonTemplate
function o:CreateSlotItems()
  local flyout = self.Flyout
  local slotID = self:GetSlotID()
  local hasItem = GetInventoryItemID('player', slotID) ~= nil
  
  -- 1. Clear existing dynamic buttons (keep first 2: Place + Ignore)
  for i = #flyout.buttons, 3, -1 do
    local btn = flyout.buttons[i]
    btn:Hide()
    btn:ClearAllPoints()
    flyout.buttons[i] = nil
  end
  
  local spacing = 2
  local totalWidth = 0
  
  if hasItem then
  -- include base buttons width
    flyout.PlaceInBagsButton:Show()
    totalWidth = totalWidth + flyout.PlaceInBagsButton:GetWidth()
  else
    flyout.PlaceInBagsButton:Hide()
  end
  
  if self.widget:IsGearsShown() and ns.gears:HasSelection() then
    flyout.IgnoreSlotButton:Show()
    totalWidth = totalWidth + flyout.IgnoreSlotButton:GetWidth()
  else
    flyout.IgnoreSlotButton:Hide()
  end
  
  local prev
  if flyout.IgnoreSlotButton:IsShown() then
    prev = flyout.IgnoreSlotButton
  elseif flyout.PlaceInBagsButton:IsShown() then
    prev = flyout.PlaceInBagsButton
  else
    prev = self.widget.flyoutFrame
  end
  
  flyout.IgnoreSlotButton:ClearAllPoints()
  
  if flyout.PlaceInBagsButton:IsShown() then
    flyout.IgnoreSlotButton:SetPoint('LEFT', flyout.PlaceInBagsButton, 'RIGHT', 1, 0)
  else
    flyout.IgnoreSlotButton:SetPoint('LEFT', flyout, 'LEFT', 8, 0)
  end
  
  -- 2. Create item buttons
  inventorUtil():ForEachBagItemMatchingSlot(slotID, function(info, item)
    --- @type ButtonObj
    local btn = CreateFrame('Button', nil, flyout, 'GearsEquipmentSlotActionButtonTemplate')
    btn:SetParentKey(('ItemButton%d'):format(#flyout.buttons + 1))
    if info.iconFileID then btn.Icon:SetTexture(info.iconFileID) end
    
    btn:ClearAllPoints()
    if prev == self.widget.flyoutFrame then
      btn:SetPoint('LEFT', prev, 'LEFT', 9, 0)   -- first / only button
    else
      btn:SetPoint('LEFT', prev, 'RIGHT', spacing, 0) -- chained
    end
    table.insert(flyout.buttons, btn)
    
    prev = btn
    totalWidth = totalWidth + btn:GetWidth() + spacing
    
    local slotFlyout = self
    btn:SetScript('OnClick', function(self)
      if InCombatLockdown() then return end
      if not (info.bagID and info.slotIndex) then return end
      C_PickupContainerItem(info.bagID, info.slotIndex)
      EquipCursorItem(slotFlyout:GetSlotID())
      slotFlyout.widget:ClosePopup()
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

--- @param slotInfo InventorySlotInfo
--- @param characterSlotButton BlizzCharacterSlotItemButton
--- @return EquipmentSlotFlyout
function o:Create(slotInfo, characterSlotButton)
  --- @type EquipmentSlotFlyout
  local slotFlyout = CreateFrame('Button', nil, PaperDollFrame, self.TemplateName, slotInfo.id)
  characterSlotButton.__Gears_flyout = slotFlyout
  local name = characterSlotButton:GetName() .. 'Flyout'
  slotFlyout:SetParentKey(name)
  slotFlyout.widget = CreateAndInitFromMixin(EquipmentSlotFlyoutWidgetMixin,
          slotFlyout, slotInfo, characterSlotButton)
  slotFlyout:ApplyInitialState()
  slotFlyout:CreateActionButtons()
  slotFlyout:SetHeight(24)
  slotFlyout:ClearAllPoints()
  slotFlyout:SetPoint(slotFlyout:GetSlotAnchor())
  
  slotFlyout:RegisterMessage(ns:msg('SlotOpened'), 'OnSlotOpened')
  slotFlyout:RegisterMessage(ns:msg('ShowPaperDollFrame'), 'OnShowPaperDollFrame')
  slotFlyout:RegisterMessage(ns:msg('SlotEnter'), 'OnSlotEnter')
  slotFlyout:RegisterMessage(ns:msg('EquipmentSetSelected'), 'OnEquipmentSetSelected')
  
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

function o:IsDownExpand()
  local slotID = self:GetSlotID()
  return slotID == INVSLOT_MAINHAND
          or slotID == INVSLOT_OFFHAND
          or slotID == INVSLOT_RANGED
end

function o:GetSlotAnchor()
  local ofsx, ofsy = -7, 0
  local relativeTo = self.widget.charSlotButton
  if self:IsDownExpand() then
    return 'TOP', relativeTo, 'BOTTOM', 0, 10
  end
  return 'LEFT', relativeTo, 'RIGHT', ofsx, ofsy
end


