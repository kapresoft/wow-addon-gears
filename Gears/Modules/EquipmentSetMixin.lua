--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local C_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo

local CHECKBOX_TEXTURE = [[Interface\Buttons\UI-CheckBox-Check]]
local NORMAL_TEXTURE_ALPHA = 0.4

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- @alias EquipmentSetFrame EquipmentSetMixin|ButtonObjWithBackdrop

--- @class EquipmentSetMixin : Button
--- @field owner MainFrame
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

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  
  self:SetBackdrop(BACKDROP_WITH_BG)
  self:HideBorder()
  self:__OnLoadCheckMark()
  self:__CreateDeleteButton()
  self:__CreateChangeButton()
end

function o:__CreateDeleteButton()
  local btn = CreateFrame(
          "Button",
          "$parentDeleteButton",
          self,
          "Gears_DeleteButtonTemplate"
  )
  
  btn.owner = self
  btn:SetFrameLevel(self:GetFrameLevel() + 2)
  
  btn:ClearAllPoints()
  btn:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, 5)
  
  -- Initial visual state
  btn:GetNormalTexture():SetAlpha(NORMAL_TEXTURE_ALPHA)
  btn:Hide()
  
  self.DeleteButton = btn
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
  btn:SetPoint("RIGHT", self.DeleteButton, "LEFT", -2, 0)
  
  -- Initial visual state
  btn:GetNormalTexture():SetAlpha(NORMAL_TEXTURE_ALPHA)
  btn:Hide()
  
  self.ChangeButton = btn
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
  --self:ShowBorder()
  if not self.selected then
    --self:SetBackdropColor(0, 0, 0, 0.5)
    --self:SetBackdropBorderColor(1.0, 1, 1.0, 1.0)
    --self:SetBackdropColor(1, 1, 1, 0.12)
    self:ShowBorderOnHover()
  end
  
  --- When we hover over to another EquipmentSetFrame,
  --- hide other EquipmentSet specific action buttons
  self.owner:ForEachEquipmentFrame(function(otherEQS)
    otherEQS:HideActionButtons()
  end, function(eqsInfo) return self:GetID() ~= eqsInfo.id end)
  
  self:ShowActionButtons()
end

function o:ShowActionButtons()
  self.DeleteButton:Show()
  self.ChangeButton:Show()
end
function o:HideActionButtons()
  self.DeleteButton:Hide()
  self.ChangeButton:Hide()
end

local function FrameAtMouse()
  local foci = GetMouseFoci()
  if #foci <= 0 then return end
  local f = foci[1]
  return f.GetName and f:GetName() or tostring(f)
end

local function GetFirstMouseFoci()
  local foci = GetMouseFoci()
  if #foci <= 0 then return nil end
  return foci[1]
end

--- @return boolean
--- @param obj EquipmentSetDeleteButton|table
local function IsDeleteButton(obj)
  return obj and obj.ChangeButton == true
end

--- @return boolean
--- @param obj EquipmentSetFrame|table
local function IsEquipmentSet(obj)
  return obj and obj.EquipmentSet == true
end
--'Gears_EquipmentSetDeleteButton'

--- @return boolean
local function IsInTheRightArea()
  local obj = GetFirstMouseFoci(); if not obj then return false end
  return IsEquipmentSet(obj) or IsDeleteButton(obj)
  --print('xx is-del?:', IsDeleteButton(obj))
  --return IsDeleteButton(obj)
end

function o:OnLeave()
  if self.__overDeleteButton then
    print('xx ESet OnLeave: __overDeleteButton')
  end
  if self.selected == true then return end
  self:HideBorder()
end
function o:OnDoubleClick() self:EquipGear() end

function o:EquipGear()
  PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
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
