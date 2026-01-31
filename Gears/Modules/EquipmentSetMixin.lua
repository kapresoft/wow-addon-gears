--- @type Namespace
local ns = select(2, ...)

-- todo: Drag and drop to actionbars

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local C_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo
local C_PickupEquipmentSet = C_EquipmentSet.PickupEquipmentSet

local CHECKBOX_TEXTURE = [[Interface\Buttons\UI-CheckBox-Check]]

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- @alias EquipmentSetFrame EquipmentSetMixin|ButtonObjWithBackdrop

--- @class EquipmentSetMixin : Button
--- @field owner Gears_MainFrame
--- @field info EquipmentSetInfo
--- @field selected boolean
--- @field equipSetID Identifier
--- @field CheckMark TextureObj
--- @field DeleteButton ButtonObj
--- @field ChangeButton ButtonObj
--- @field private __used boolean|nil
Gears_EquipmentSetMixin = {}
local p = ns:log('EquipmentSetMixin')

--- @type EquipmentSetMixin | EquipmentSetFrame
local o = Gears_EquipmentSetMixin
o.EquipmentSet = true

local BACKDROP_WITH_BG = {
  bgFile   = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 12,
  insets   = { left = 3, right = 3, top = 3, bottom = 3 },
}

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function EquipmentSet_ShowTooltip(self)
  local bullet = '  • '
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText("Available Actions" .. ':', 0.90, 0.75, 0.20)
  GameTooltip:AddLine(bullet .. "Left-click to select.", 0.9, 0.9, 0.9, true)
  GameTooltip:AddLine(bullet .. "Double-click to equip.", 0.9, 0.9, 0.9, true)
  GameTooltip:AddLine(bullet .. "Drag-and-drop to an action bar.", 0.9, 0.9, 0.9, true)
  GameTooltip:Show()
end

--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  
  self:SetBackdrop(BACKDROP_WITH_BG)
  self:HideBorder()
  self:__OnLoadCheckMark()
  self:__CreateDeleteButton()
  self:__CreateChangeButton()
end

function o:OnDragStart()
  ClearCursor()
  C_PickupEquipmentSet(self:GetID())
end

--- If dropped nowhere valid, clear cursor
function o:OnDragStop()
  if CursorHasItem() or CursorHasSpell() or CursorHasMacro() then
    ClearCursor()
  end
end

function o:__CreateDeleteButton()
  --- @type ButtonObj
  local btn = CreateFrame(
          "Button",
          "$parentDeleteButton",
          self,
          "Gears_DeleteButtonTemplate"
  )
  btn.owner = self
  btn:SetFrameLevel(self:GetFrameLevel() + 2)
  btn:ClearAllPoints()
  btn:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
  btn:Hide()
end

function o:__CreateChangeButton()
  --- @type ButtonObj
  local btn = CreateFrame(
          "Button",
          "$parentChangeButton",
          self,
          "Gears_ChangeButtonTemplate"
  )
  btn.owner = self
  btn:SetFrameLevel(self:GetFrameLevel() + 2)
  btn:ClearAllPoints()
  btn:SetPoint("RIGHT", self.DeleteButton, "LEFT", 4, 0)
  btn:Hide()
end

--- @private
function o:__OnLoadCheckMark()
  local t = self.CheckMark
  t:SetTexture(CHECKBOX_TEXTURE)
  t:SetVertexColor(1, 1, 1, 1)
  t:Hide()
end

--- @return Gears_MainFrame
function o:GetMainFrame() return self.owner end

--- Show check-mark if fully equipped.
--- The `callbackFn` is optional.
--- @param callbackFn nil|fun(isFullyEquipped:boolean) | "function(isFullyEquipped) end"
function o:UpdateFullyEquippedState(callbackFn)
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

function o:OnEnter()
  EquipmentSet_ShowTooltip(self)
  
  if not self.selected then self:ShowBorderOnHover() end
  
  --- When we hover over to another EquipmentSetFrame,
  --- hide other EquipmentSet specific action buttons
  self.owner:ForEachEquipmentFrame(function(otherEQS)
    otherEQS:HideActionButtons()
  end, function(eqsInfo) return self:GetID() ~= eqsInfo.id end)
  
  self:ShowActionButtons()
end

function o:OnLeave()
  GameTooltip:Hide()
  if self.selected == true then return end
  self:HideBorder()
end

function o:OnDoubleClick() self:EquipGear() end

function o:ShowActionButtons()
  self.DeleteButton:Show()
  self.ChangeButton:Show()
end
function o:HideActionButtons()
  self.DeleteButton:Hide()
  self.ChangeButton:Hide()
end

function o:EquipGear()
  PlaySound(SOUNDKIT.PUT_DOWN_SMALL_CHAIN)
  PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
  
  if EquipmentManager_EquipSet then
    EquipmentManager_EquipSet(self:GetID())
  else
    C_EquipmentSet.UseEquipmentSet(self:GetID())
  end
end

function o:SaveGear()
  PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
  C_EquipmentSet.SaveEquipmentSet(self:GetID(), self.info.icon)
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
  
  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF, "Ambience")
  self.selected = selected
  if self.selected then self:ShowAsSelectedBorder(); return end
  self:HideBorder()
end

function o:ShowBorderOnHover()
  if self.selected then return end
  self:SetBackdropColor(1.0, 0.9, 0.2, 0.05)
  self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
end

function o:HideBorder()
  if self.selected then return end
  self:SetBackdropColor(0, 0, 0, 0)
  self:SetBackdropBorderColor(0, 0, 0, 0)
end

function o:ShowAsSelectedBorder()
  --self:SetBackdropColor(1, 1, 1, 1)
  --self:SetBackdropColor(0, 0, 0, 0)
  self:SetBackdropColor(1, 1, 1, 0.1)
  self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
end

--- @return Identifier, Name, IconIDOrPath
function o:GetIdentity()
  local info = self.info
  if not self.info then return nil end
  return self.info.id, self.info.name, self.info.icon
end

--- @return Name
function o:GetEquipmentSetName()
  local info = self.owner.info
  return info and info.name
end
