--- @type Namespace
local ns = select(2, ...)
--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local LibIconPickerUtil    = ns.O.LibIconPickerUtil
local C_ModifyEquipmentSet = C_EquipmentSet.ModifyEquipmentSet

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- @alias EquipmentSetChangeButton EquipmentSetChangeButtonMixin|ButtonObj|IconButtonMixin

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
  IconButtonMixin.OnLoad(self)
  self.tooltipText = EQUIPMENT_SET_EDIT
  -- baseline (dimmed)
  self.Icon:SetAlpha(0.4)
  self.onClickHandler = function() self:ShowPicker()  end
end

function o:OnEnter()
  IconButtonMixin.OnEnter(self)
  self.owner:ShowBorderOnHover()
end

function o:OnLeave()
  IconButtonMixin.OnLeave(self)
  self.owner:HideBorder()
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
  LibIconPickerUtil:Get(function(lip)
    lip:Open(function(sel)
      if not sel.textInputValue then return end
      C_ModifyEquipmentSet(self.owner:GetID(), sel.textInputValue, sel.icon)
      p('Updated name:', sel.textInputValue, ', icon:', sel.icon)
    end, opt)
  end)
end

