--- @type Namespace
local ns = select(2, ...)

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
  print('xx ChangeButton::OnClick...')
  --self.owner:OnChangeButtonClick(self, button);
end

function o:OnEnter()
  print('xx ChangeButton::OnEnter...')
  self:GetNormalTexture():SetAlpha(1.0)
  self.owner:ShowBorderOnHover()
  
  ChangeButton_OnEnterShowTooltip(self)
end

function o:OnLeave()
  print('xx ChangeButton::OnLeave...')
  self:GetNormalTexture():SetAlpha(0.4)
  self.owner:HideBorder()
  
  ChangeButton_OnLeaveHideTooltip(self)
end
