--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- @alias EquipmentSetDeleteButton EquipmentSetDeleteButtonMixin|ButtonObj

--- @class EquipmentSetDeleteButtonMixin : Button
--- @field owner EquipmentSetFrame
Gears_EquipmentSetDeleteButtonMixin = {}
local p           = ns:log('EquipmentSetDeleteButtonMixin')
local OBJECT_TYPE = 'Gears_EquipmentSetDeleteButton'

--- @type EquipmentSetDeleteButtonMixin | EquipmentSetFrame
local o  = Gears_EquipmentSetDeleteButtonMixin
o.DeleteButton = true

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param self EquipmentSetDeleteButtonMixin
local function DeleteButton_SetupPressedState(self)
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

--- @param self EquipmentSetDeleteButtonMixin
local function DeleteButton_OnEnterShowTooltip(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(DELETE, 1, 1, 1)
  GameTooltip:Show()
  -- edit: EQUIPMENT_SET_EDIT
end
--- @param self EquipmentSetDeleteButtonMixin
local function DeleteButton_OnLeaveHideTooltip(self)
  GameTooltip:Hide()
end

function o:OnLoad()
  DeleteButton_SetupPressedState(self)
end

--- @param button Name
function o:OnClick(button)
  self.owner:OnDeleteButtonClick(self, button);
end

function o:OnEnter()
  self:GetNormalTexture():SetAlpha(1.0)
  self.owner:ShowBorderOnHover()
  
  DeleteButton_OnEnterShowTooltip(self)
end

function o:OnLeave()
  self:GetNormalTexture():SetAlpha(0.4)
  self.owner:HideBorder()
  
  DeleteButton_OnLeaveHideTooltip(self)
end
