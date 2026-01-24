--- @type Namespace
local ns = select(2, ...)

--- @class EquipmentSetMixinImpl : Frame
--- @field owner MainFrame
--- @field selected boolean
--- @field equipSetID Identifier
--- @field CheckMark TextureObj

--- @alias EquipmentSet EquipmentSetMixinImpl|FrameObjWithBackdrop
--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local CHECKBOX_TEXTURE = [[Interface\Buttons\UI-CheckBox-Check]]

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]

Gears_EquipmentSetMixin = {}
local p = ns:log('EquipmentSetMixin')

--- @type EquipmentSetMixinImpl | EquipmentSet
local o = Gears_EquipmentSetMixin

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)
  
  self:HideBorder()
  self:__OnLoadCheckMark()
end

--- @private
function o:__OnLoadCheckMark()
  local t = self.CheckMark
  t:SetTexture(CHECKBOX_TEXTURE)
  t:SetVertexColor(1, 1, 1, 1)
  t:Hide()
end

--- @return MainFrame
function o:GetMainFrame() return self.owner end

-- TODO next: needs implementation.
function o:SelectWhenEquipped()
  -- if isEquipped then
  -- self.CheckMark:Show()
  if self:IsFullyEquipped() then
    self.CheckMark:Show()
    -- todo: disable action buttons
    return
  end
  
  -- todo: else, enable action buttons
  
end

function o:IsFullyEquipped()
  local _, _, _, _, numItems, numEquipped =
  C_EquipmentSet.GetEquipmentSetInfo(self.equipSetID)
  
  return numItems > 0 and numEquipped == numItems
end


function o:OnMouseDown() self:GetMainFrame():SelectEquipmentSet(self) end

function o:OnEnter() self:ShowBorder() end

function o:OnLeave()
  if self.selected == true then return end
  self:HideBorder()
  print('xx hide border')
end

--- This is not the same as 'equipped' state
--- @param selected boolean
function o:SetSelected(selected)
  assert(type(selected) == 'boolean', 'Expected SetSelected(selected:boolean)')
  
  self.selected = selected
  if self.selected then
    self:ShowBorder()
    return
  end

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

