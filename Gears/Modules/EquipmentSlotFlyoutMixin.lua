--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
--[[-------------------------------------------------------------------
Slot Mapping
---------------------------------------------------------------------]]
local SLOT_NAMES = {
  [INVSLOT_HEAD] = "HeadSlot",
  [INVSLOT_NECK] = "NeckSlot",
  [INVSLOT_SHOULDER] = "ShoulderSlot",
  [INVSLOT_BODY] = "ShirtSlot",
  [INVSLOT_CHEST] = "ChestSlot",
  [INVSLOT_WAIST] = "WaistSlot",
  [INVSLOT_LEGS] = "LegsSlot",
  [INVSLOT_FEET] = "FeetSlot",
  [INVSLOT_WRIST] = "WristSlot",
  [INVSLOT_HAND] = "HandsSlot",
  [INVSLOT_FINGER1] = "Finger0Slot",
  [INVSLOT_FINGER2] = "Finger1Slot",
  [INVSLOT_TRINKET1] = "Trinket0Slot",
  [INVSLOT_TRINKET2] = "Trinket1Slot",
  [INVSLOT_BACK] = "BackSlot",
  [INVSLOT_MAINHAND] = "MainHandSlot",
  [INVSLOT_OFFHAND] = "SecondaryHandSlot",
  [INVSLOT_RANGED] = "RangedSlot",
  [INVSLOT_TABARD] = "TabardSlot",
};
-- /dump CharacterFinger0Slot:IconOverlay:SetAlpha(0.4)
-- /dump CharacterFinger0Slot:GetName()
-- /dump CharacterFinger0Slot:LockHighlight()

--[[-------------------------------------------------------------------
Types
---------------------------------------------------------------------]]
--- @class EquipmentSlotFlyout__ : Frame Flyout Container
--- @field ExcludeButton ButtonObj
--- @field IncludeButton ButtonObj
--- @field buttons ButtonObj[]
--
--
--- @alias EquipmentSlotFlyout EquipmentSlotFlyout__ | FrameObjWithBackdrop

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutMixin
-------------------------------------------------------------------------------]]
local libName = 'EquipmentSlotFlyoutMixin'
--- @class EquipmentSlotFlyoutMixin
--- @field Flyout EquipmentSlotFlyout Flyout Container
--- @field Arrow TextureObj
Gears_EquipmentSlotFlyoutMixin = {}
local p, pd, t, tf = ns:log(libName)

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
  self:ClearAllPoints()
  local ofsx, ofsy = -2, 0
  if ns:HasBlizzEquipmentManager() then ofsx = -10 end
  self:SetPoint('LEFT', CharacterShoulderSlot, 'RIGHT', ofsx, ofsy)
  
  self.Flyout:SetBackdropColor(0.25, 0.32, 0.50, 0.95)
  self.Flyout:SetBackdropBorderColor(1.0, 0.84, 0.0, 0.95)
  self:CreateActionButtons()
  self.Arrow:SetTexture(310765);
  self.Arrow:SetTexCoord(0.02, 0.98, 0.02, 0.48);
  
  self:FlyoutHide()
  self:Show()
end

function o:CreateActionButtons()
  local flyout = self.Flyout
  flyout.buttons = {}
  
  --- @type ButtonObj - Include Button
  local placeInBagsBtn = CreateFrame("Button", nil, flyout, "GearsEquipmentSlotActionButton")
  placeInBagsBtn:SetParentKey('PlaceInBagsButton')
  placeInBagsBtn.Icon:SetTexture([[Interface\Icons\INV_Misc_Bag_09]])
  placeInBagsBtn:ClearAllPoints()
  placeInBagsBtn:SetPoint("LEFT", flyout, "LEFT", 8, 0)
  table.insert(flyout.buttons, placeInBagsBtn)
  
  --- @type ButtonObj - Exclude Button
  local excludeBtn = CreateFrame("Button", nil, flyout, "GearsEquipmentSlotActionButton")
  excludeBtn:SetParentKey('ExcludeButton')
  excludeBtn.Icon:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
  excludeBtn:ClearAllPoints()
  excludeBtn:SetPoint("LEFT", placeInBagsBtn, "RIGHT", 1, 0)
  table.insert(flyout.buttons, excludeBtn)
  
  local widthPadding = 16
  flyout:SetWidth(placeInBagsBtn:GetWidth() + excludeBtn:GetWidth() + widthPadding)
  flyout:SetHeight(flyout:GetHeight() + 4)
end

function o:FlyoutHide()
  ns:PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE)
  self.Arrow:SetRotation(math.rad(-90)) -- ▶ collapsed
  self.Flyout:Hide()
end

function o:FlyoutShow()
  ns:PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
  self.Flyout:Show()
  self.Arrow:SetRotation(math.rad(90)) -- ◀ expanded
end

function o:OnClick()
  if self.Flyout:IsShown() then self:FlyoutHide()
  else self:FlyoutShow() end
end

function o:OnEnter()
  self.Arrow:SetVertexColor(0.4, 0.95, 0.4, 1)
  self.Arrow:SetBlendMode("BLEND")
end

function o:OnLeave()
  self.Arrow:SetVertexColor(1, 1, 1, 1)
  self.Arrow:SetBlendMode("BLEND")
end
