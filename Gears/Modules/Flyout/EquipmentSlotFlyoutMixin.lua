--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_IsSlotIgnoredForSave = C_EquipmentSet and C_EquipmentSet.IsSlotIgnoredForSave
local C_IgnoreSlotForSave = C_EquipmentSet and C_EquipmentSet.IgnoreSlotForSave
local C_UnignoreSlotForSave = C_EquipmentSet and C_EquipmentSet.UnignoreSlotForSave
local C_GetIgnoredSlots = C_EquipmentSet and C_EquipmentSet.GetIgnoredSlots

--[[-------------------------------------------------------------------
Slot Mapping
---------------------------------------------------------------------]]

-- /dump CharacterFinger0Slot:IconOverlay:SetAlpha(0.4)
-- /dump CharacterFinger0Slot:GetName()
-- /dump CharacterFinger0Slot:LockHighlight()

--[[-------------------------------------------------------------------
Types
---------------------------------------------------------------------]]
--- @class FlyoutFrame__ : Frame Flyout Container
--- @field PlaceInBagsButton PlaceInBagsSlotActionButton
--- @field IgnoreSlotButton IgnoreSlotActionButton
--- @field buttons ButtonObj[]
--- @field GetParent fun(self:FlyoutFrame__) : EquipmentSlotFlyout

--
--
--- @alias FlyoutFrame FlyoutFrame__ | FrameObjWithBackdrop

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutMixin
-------------------------------------------------------------------------------]]
local libName = 'EquipmentSlotFlyoutMixin'
--- @class EquipmentSlotFlyoutMixin : Button
--- @field GetID fun(self:EquipmentSlotFlyoutMixin) : number @The equipment slot identifier
--- @field widget EquipmentSlotFlyoutWidget
--- @field Flyout FlyoutFrame Flyout Container
--- @field Arrow TextureObj
--- @see EquipmentSlotFlyoutManager#Create(slotInfo, slotButton
Gears_EquipmentSlotFlyoutMixin = {}
--
--- @alias EquipmentSlotFlyout EquipmentSlotFlyoutMixin|ButtonObj
--

local p, pd, t, tf = ns:log(libName)
--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @return EquipmentSlotFlyoutManager
local function flyoutMgr() return ns.O.EquipmentSlotFlyoutManager end

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type EquipmentSlotFlyoutMixin | ButtonObj
local o = Gears_EquipmentSlotFlyoutMixin

--local slotID = INVSLOT_SHOULDER
--
---- ignore slot for equipment set
--C_EquipmentSet.IgnoreSlotForSave(slotID)
--
---- get item currently equipped
--local link = GetInventoryItemLink("player", slotID)
--
---- get icon
--local texture = GetInventoryItemTexture("player", slotID)
--- /dump "Character"..select(1, GetInventorySlotInfo(3))
function o:OnLoad()
  self.Flyout:SetBackdropColor(0.25, 0.32, 0.50, 0.95)
  self.Flyout:SetBackdropBorderColor(1.0, 0.84, 0.0, 0.95)
  
  self.Arrow:SetTexture(310765);
  self.Arrow:SetTexCoord(0.02, 0.98, 0.02, 0.48);
  
  self:FlyoutHide()
  self:Hide()
end

--- @class EquipmentSlotFlyoutWidgetMixin
local EquipmentSlotFlyoutWidgetMixin = {}

--
--- @alias EquipmentSlotFlyoutWidget EquipmentSlotFlyoutWidgetMixin
--
do
  --- @type EquipmentSlotFlyoutWidgetMixin | EquipmentSlotFlyoutWidget
  local w = EquipmentSlotFlyoutWidgetMixin
  
  --- @param slotFlyout EquipmentSlotFlyout
  --- @param slotInfo InventorySlotInfo
  --- @param slotButton BlizzCharacterSlotItemButton
  function w:Init(slotFlyout, slotInfo, slotButton)
    self.frame = slotFlyout
    self.flyoutFrame = slotFlyout.Flyout
    self.info = slotInfo
    self.slotButton = slotButton
  end
  
  --- @return SlotID
  function w:GetSlotID() return self.frame:GetID() end
  --- @return boolean
  function w:IsCharacterSlotShown()
    return self.slotButton and self.slotButton:IsShown()
  end
  --- @param ignored boolean
  function w:SyncIgnoredState(ignored)
    self:isb().widget:SyncIgnoredState(ignored)
  end
  --- @return boolean
  function w:IsIgnored()
    local ignored = false
    ns.gears:WithSelectedEquipmentSet(function(sel)
      local slotID = self.frame.widget:GetSlotID()
      local ignoredSlots = C_GetIgnoredSlots(sel:GetIdentity())
      ignored = ignoredSlots and ignoredSlots[slotID]
    end)
    return ignored
  end
  function w:GetIgnoreSlotButton() return self.flyoutFrame.IgnoreSlotButton end
  function w:isb() return self:GetIgnoreSlotButton() end
end

-- Gears_EquipmentSlotFlyoutMixin
--- /dump PaperDollFrame.HeadSlotFlyout
--- @param slotInfo InventorySlotInfo
--- @param slotButton BlizzCharacterSlotItemButton
--- @return EquipmentSlotFlyout
function o:Create(slotInfo, slotButton)
  --- @type EquipmentSlotFlyout
  local slotFlyout = CreateFrame('Button', nil, PaperDollFrame, 'GearsEquipmentSlotFlyoutTemplate', slotInfo.id)
  local name = slotInfo.name .. 'Flyout'
  slotFlyout:SetParentKey(name)
  slotFlyout.widget = CreateAndInitFromMixin(EquipmentSlotFlyoutWidgetMixin, slotFlyout, slotInfo, slotButton)
  slotFlyout:CreateActionButtons()
  
  slotFlyout:ClearAllPoints()
  local ofsx, ofsy = -2, 0
  --if ns:HasBlizzEquipmentManager() then ofsx = -10 end
  slotFlyout:SetPoint('LEFT', slotFlyout.widget.slotButton, 'RIGHT', ofsx, ofsy)
  
  return slotFlyout
end

function o:CreateActionButtons()
  local flyout = self.widget.flyoutFrame
  flyout.buttons = {}
  
  --- @type ButtonObj - Include Button
  local placeInBagsBtn = CreateFrame("Button", nil, flyout, Gears_PlaceInBagsSlotActionButtonMixin.TemplateName)
  placeInBagsBtn:SetParentKey('PlaceInBagsButton')
  placeInBagsBtn.Icon:SetTexture([[Interface\Icons\INV_Misc_Bag_09]])
  placeInBagsBtn:ClearAllPoints()
  placeInBagsBtn:SetPoint("LEFT", flyout, "LEFT", 8, 0)
  flyout.PlaceInBagsButton = placeInBagsBtn
  table.insert(flyout.buttons, placeInBagsBtn)
  
  --- @type ButtonObj - Exclude Button
  local excludeBtn = CreateFrame("Button", nil, flyout, Gears_IgnoreSlotActionButtonMixin.TemplateName)
  excludeBtn:SetParentKey('ExcludeButton')
  excludeBtn.Icon:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
  excludeBtn:ClearAllPoints()
  excludeBtn:SetPoint("LEFT", placeInBagsBtn, "RIGHT", 1, 0)
  flyout.IgnoreSlotButton = excludeBtn
  table.insert(flyout.buttons, excludeBtn)
  
  local widthPadding = 16
  flyout:SetWidth(placeInBagsBtn:GetWidth() + excludeBtn:GetWidth() + widthPadding)
  flyout:SetHeight(flyout:GetHeight() + 4)
end

function o:FlyoutHide()
  -- /run PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
  ns:PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
  self.Arrow:SetRotation(math.rad(-90)) -- ▶ collapsed
  self.Flyout:Hide()
end

function o:FlyoutShow()
  ns:PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
  self.Flyout:Show()
  self.Arrow:SetRotation(math.rad(90)) -- ◀ expanded
end

function o:OnClick()
  if self.Flyout:IsShown() then self:FlyoutHide(); return end
  local slotID = self:GetID()
  local isIgnoredForSave = C_IsSlotIgnoredForSave(slotID)
  ns.gears:WithSelectedEquipmentSet(function(sel)
    t('OnClick', 'set=', sel.info.name, 'slot=', self:GetID(),
            'ignored-for-save=', isIgnoredForSave,
            'currently-ignored=', self.widget:IsIgnored())
  end)
  
  self:FlyoutShow()
end

function o:OnEnter()
  self.Arrow:SetVertexColor(0.4, 0.95, 0.4, 1)
  self.Arrow:SetBlendMode("BLEND")
end

function o:OnLeave()
  self.Arrow:SetVertexColor(1, 1, 1, 1)
  self.Arrow:SetBlendMode("BLEND")
end

function o:__GetDebugName()
  local info = self.widget.info
  return ('%s::%s'):format(info.name, info.id, self.widget.slotButton:GetName())
end
