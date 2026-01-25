--- @type Namespace
local ns = select(2, ...)

-- todo next: EQUIPMENT_SWAP_PENDING
-- todo next: EQUIPMENT_SWAP_FINISHED true, <equipSetID>

--- @class EquipmentSetMixinImpl : Frame
--- @field owner MainFrame
--- @field selected boolean
--- @field equipSetID Identifier
--- @field CheckMark TextureObj

--- @alias EquipmentSet EquipmentSetMixinImpl|FrameObjWithBackdrop
--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local C_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo

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

--- The `callbackFn` is optional.
--- @param callbackFn nil|fun(isFullyEquipped:boolean) | "function(isFullyEquipped) end"
function o:OnUpdateEquippedState(callbackFn)
  local equipped = false
  if self:IsFullyEquipped() then
    self.CheckMark:Show()
    equipped = true
  else
    self.CheckMark:Hide()
  end
  if callbackFn then callbackFn(equipped) end
end

function o:IsFullyEquipped()
  local name, _, _, isEquipped = C_GetEquipmentSetInfo(self.equipSetID)
  --print(('yy equipped[%s::%s]: %s'):format(self.equipSetID, name, tostring(isEquipped)))
  return isEquipped
end

function o:OnMouseDown() self:GetMainFrame():SelectEquipmentSet(self) end
function o:OnEnter() self:ShowBorder() end
function o:OnLeave()
  if self.selected == true then return end; self:HideBorder()
end

--- This is not the same as 'equipped' state
--- @param selected boolean
function o:SetSelected(selected)
  assert(type(selected) == 'boolean', 'Expected SetSelected(selected:boolean)')
  
  self.selected = selected
  if self.selected then self:ShowBorder(); return end
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

