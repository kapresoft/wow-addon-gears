--- @type Namespace
local ns = select(2, ...)
--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local LIP = ns.O.LibIconPickerUtil
local C_ModifyEquipmentSet = C_EquipmentSet.ModifyEquipmentSet

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- @alias EquipmentSetChangeButton EquipmentSetChangeButtonMixin|ButtonObj

--- @class EquipmentSetChangeButtonMixin : Button
--- @field owner EquipmentSetFrame
--- @field ChangeButton boolean
Gears_EquipmentSetChangeButtonMixin = {}
local p           = ns:log('EquipmentSetChangeButtonMixin')
local OBJECT_TYPE = 'Gears_EquipmentSetChangeButton'

--- @type EquipmentSetChangeButtonMixin | EquipmentSetChangeButton
local o  = Gears_EquipmentSetChangeButtonMixin
o.ChangeButton = true

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param self EquipmentSetChangeButtonMixin
local function ChangeButton_SetupPressedState(self)
  local normal = self:GetNormalTexture()
  local pushed = self:GetPushedTexture()
  
  -- Normal: full size
  normal:ClearAllPoints()
  normal:SetPoint("CENTER")
  normal:SetSize(13, 13)
  
  -- Pushed: slightly smaller
  pushed:ClearAllPoints()
  pushed:SetPoint("CENTER")
  pushed:SetSize(11, 11)
end
--- @param self EquipmentSetChangeButtonMixin
local function ChangeButton_OnEnterShowTooltip(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(EQUIPMENT_SET_EDIT, 1, 1, 1)
  GameTooltip:Show()
end
--- @param self EquipmentSetChangeButtonMixin
local function ChangeButton_OnLeaveHideTooltip(self)
  GameTooltip:Hide()
end

--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
function o:OnLoad()
  ChangeButton_SetupPressedState(self)
end

--- @param button Name
function o:OnClick(button)
  self:ShowPicker()
end

--- @return Name
function o:GetEquipmentSetName()
  local info = self.owner.info
  return info and info.name
end

function o:ShowPicker()
  local id, name, icon = self.owner:GetIdentity()
  local opt = {
    icon = icon, showTextInput = true,
    textInput = { label = 'Set Name:', value = name }
  }
  LIP:Instance():Open(function(sel)
    if not sel.textInputValue then return end
    C_ModifyEquipmentSet(self.owner:GetID(), sel.textInputValue, sel.icon)
    --print('Updated name:', sel.textInputValue, ', icon:', sel.icon)
  end, opt)
end

function o:OnEnter()
  self:GetNormalTexture():SetAlpha(1.0)
  self.owner:ShowBorderOnHover()
  ChangeButton_OnEnterShowTooltip(self)
end

function o:OnLeave()
  self:GetNormalTexture():SetAlpha(0.4)
  self.owner:HideBorder()
  ChangeButton_OnLeaveHideTooltip(self)
end
