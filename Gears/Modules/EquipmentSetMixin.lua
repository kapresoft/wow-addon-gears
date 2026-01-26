--- @type Namespace
local ns = select(2, ...)

-- todo next: EQUIPMENT_SWAP_PENDING
-- todo next: EQUIPMENT_SWAP_FINISHED true, <equipSetID>

--- @class EquipmentSetMixinImpl : Button
--- @field owner MainFrame
--- @field selected boolean
--- @field equipSetID Identifier
--- @field CheckMark TextureObj
--- @field info EquipmentSetInfo
--- @field private __used boolean|nil

--- @alias EquipmentSetFrame EquipmentSetMixinImpl|ButtonObjWithBackdrop
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

--- @type EquipmentSetMixinImpl | EquipmentSetFrame
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

--- Show check-mark if fully equipped.
--- The `callbackFn` is optional.
--- @param callbackFn nil|fun(isFullyEquipped:boolean) | "function(isFullyEquipped) end"
function o:UpdateCheckedState(callbackFn)
  local equipped = self:IsFullyEquipped()
  if equipped then
    self.CheckMark:Show()
  else
    self.CheckMark:Hide()
  end
  if callbackFn then callbackFn(equipped) end
end

function o:IsFullyEquipped()
  local name, _, _, isEquipped = C_GetEquipmentSetInfo(self:GetID())
  --print(('yy equipped[%s::%s]: %s'):format(self.equipSetID, name, tostring(isEquipped)))
  return isEquipped
end

function o:OnMouseDown() self:GetMainFrame():SelectEquipmentSet(self) end
function o:OnEnter() self:ShowBorder() end
function o:OnLeave()
  if self.selected == true then return end; self:HideBorder()
end
function o:OnDoubleClick()
  if EquipmentManager_EquipSet then
    EquipmentManager_EquipSet(self:GetID())
  else
    C_EquipmentSet.UseEquipmentSet(self:GetID())
  end
  PlaySound(SOUNDKIT.GUILD_BANK_OPEN_BAG)
end

---@param info EquipmentSetInfo
function o:SetInfo(info)
  assert(info, "SetInfo(info): The parameter info is required.")
  self.info = info
  self:SetID(info.id)
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

