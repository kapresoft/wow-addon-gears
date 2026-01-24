--- @type Namespace
local ns = select(2, ...)

--- @class EquipmentSetMixinImpl : Frame
Gears_EquipmentSetMixin = {}
local p = ns:log('EquipmentSetMixin')

--- @type EquipmentSetMixinImpl | FrameObjWithBackdrop
local o = Gears_EquipmentSetMixin

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)
  self:HideBorder()
end

function o:ShowBorder()
  self:SetBackdropColor(0, 0, 0, 0.5)
  self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
end

function o:HideBorder()
  self:SetBackdropColor(0, 0, 0, 0)
  self:SetBackdropBorderColor(0, 0, 0, 0)
end
