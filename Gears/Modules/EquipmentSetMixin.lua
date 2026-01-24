--- @type Namespace
local ns = select(2, ...)

--- @class EquipmentSetMixinImpl : Frame
--- @field owner MainFrame
--- @field selected boolean
--- @field equipSetID Identifier
--- @field CheckMarkFrame FrameObj

--- @alias EquipmentSet EquipmentSetMixinImpl|FrameObjWithBackdrop

Gears_EquipmentSetMixin = {}
local p = ns:log('EquipmentSetMixin')

--- @type EquipmentSetMixinImpl | EquipmentSet
local o = Gears_EquipmentSetMixin

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)
  self:HideBorder()
  local t = self.CheckMark
  t:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
  t:SetVertexColor(1, 1, 1, 1)
  t:Show()
end

--- @return MainFrame
function o:GetMainFrame() return self.owner end

function o:OnMouseDown() self:GetMainFrame():SelectEquipmentSet(self) end

function o:OnEnter()
  self:ShowBorder()
end
function o:OnLeave()
  if self.selected == true then return end
  self:HideBorder()
  print('xx hide border')
end

--- @param selected boolean
function o:SetSelected(selected)
  assert(type(selected) == 'boolean', 'Expected SetSelected(selected:boolean)')
  self.selected = selected
  if self.selected then return self:ShowBorder() end
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

