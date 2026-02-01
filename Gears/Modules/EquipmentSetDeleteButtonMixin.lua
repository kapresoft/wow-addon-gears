--- @type Namespace
local ns = select(2, ...)
--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_DeleteEquipmentSet = C_EquipmentSet.DeleteEquipmentSet
local DELETE = DELETE
local CONFIRM_DELETE_EQUIPMENT_SET = 'CONFIRM_DELETE_EQUIPMENT_SET'

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local p = ns:log('EquipmentSetDeleteButtonMixin')

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- @alias EquipmentSetDeleteButton EquipmentSetDeleteButtonMixin|ButtonObj

--- @class EquipmentSetDeleteButtonMixin : Button
--- @field owner EquipmentSetFrame
--- @field DeleteButton boolean
Gears_EquipmentSetDeleteButtonMixin = {}

--- @type EquipmentSetDeleteButtonMixin | EquipmentSetDeleteButton
local o  = Gears_EquipmentSetDeleteButtonMixin
o.DeleteButton = true

--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
function o:OnLoad()
  IconButtonMixin.OnLoad(self)
  self.tooltipText = DELETE
  -- baseline (dimmed)
  self.Icon:SetAlpha(0.4)
  self.onClickHandler = function()
    local id, name = self.owner:GetIdentity()
    StaticPopup_Show(CONFIRM_DELETE_EQUIPMENT_SET, name, nil, id)
  end
end

function o:OnEnter()
  IconButtonMixin.OnEnter(self)
  self.owner:ShowBorderOnHover()
end

function o:OnLeave()
  IconButtonMixin.OnLeave(self)
  self.owner:HideBorder()
end
