--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutMixin
-------------------------------------------------------------------------------]]
local libName = 'EquipmentSlotFlyoutMixin'
--- @class EquipmentSlotFlyoutMixin
Gears_EquipmentSlotFlyoutMixin = {}
local p, pd, t, tf = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type EquipmentSlotFlyoutMixin
local o = Gears_EquipmentSlotFlyoutMixin

function o:OnLoad()
  self.Flyout:SetBackdropColor(0.25, 0.32, 0.50, 0.95)
  self.Flyout:SetBackdropBorderColor(1.0, 0.84, 0.0, 0.95)
  self.Arrow:SetTexture(310765);
  self.Arrow:SetRotation(math.rad(-90));
  self.Arrow:SetTexCoord(0.02, 0.98, 0.02, 0.48);
end

function o:OnClick()
  print('xx Clicked...')
  if self.Flyout:IsShown() then
    self.Flyout:Hide()
  else
    self.Flyout:Show()
  end
end
