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

function o:OnLoad()
  --local tex = self:GetNormalTexture()
  --tex:SetSnapToPixelGrid(false)
  --tex:SetTexelSnappingBias(0)
end

--- @param button Name
function o:OnClick(button)
  self.owner:OnDeleteButtonClick(self, button);
end

function o:OnEnter()
  self.owner.__overDeleteButton = true
  print('OnEnter::__overDeleteButton:', self.owner.__overDeleteButton)
  self:GetNormalTexture():SetAlpha(1.0)
  --self.owner:EnableMouse(false)
  self.owner:ShowBorderOnHover()
end

function o:OnLeave()
  self.owner.__overDeleteButton = false
  print('OnLeave::__overDeleteButton:', self.owner.__overDeleteButton)
  self:GetNormalTexture():SetAlpha(0.4)
  --self.owner:EnableMouse(true)
  self.owner:HideBorder()
end
