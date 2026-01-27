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
o.IsDeleteButton = true

function o:OnLoad()
  self:SetAlpha(1.0)
end

--- @param button Name
function o:OnClick(button)
  self.owner:OnDeleteButtonClick(self, button);
end

function o:OnEnter()
  self.owner.__OnEnterDeleteButton = true
  self:GetNormalTexture():SetAlpha(1.0)
  --self.owner:EnableMouse(false)
  self.owner:ShowBorder()
end

function o:OnLeave()
  self.owner.__OnEnterDeleteButton = false
  self:GetNormalTexture():SetAlpha(0.4)
  --self.owner:EnableMouse(true)
  self.owner:HideBorder()
end
