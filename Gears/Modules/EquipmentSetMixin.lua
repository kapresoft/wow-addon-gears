--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local C_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo

local CHECKBOX_TEXTURE = [[Interface\Buttons\UI-CheckBox-Check]]

--[[-------------------------------------------------------------------
Mixin
---------------------------------------------------------------------]]
--- @alias EquipmentSetFrame EquipmentSetMixin|ButtonObjWithBackdrop

--- @class EquipmentSetMixin : Button
--- @field private owner MainFrame
--- @field selected boolean
--- @field equipSetID Identifier
--- @field CheckMark TextureObj
--- @field DeleteButton ButtonObj
--- @field info EquipmentSetInfo
--- @field private __used boolean|nil
Gears_EquipmentSetMixin = {}
local p = ns:log('EquipmentSetMixin')

--- @type EquipmentSetMixin | EquipmentSetFrame
local o = Gears_EquipmentSetMixin

local BACKDROP_WITH_BG = {
  bgFile   = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 12,
  insets   = { left = 3, right = 3, top = 3, bottom = 3 },
}

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  --self:SetBackdrop(BACKDROP_TOAST_12_12)
  self:SetBackdrop(BACKDROP_WITH_BG)
  
  self:HideBorder()
  self:__OnLoadCheckMark()
  
  self:__CreateDeleteButton()
end

function o:__CreateDeleteButton()
  if self.DeleteButton then return end
  
  local btn = CreateFrame(
          "Button",
          "$parentDeleteButton",
          self,
          "Gears_DeleteButtonTemplate"
  )
  
  btn.owner = self
  btn:SetFrameLevel(self:GetFrameLevel() + 2)
  
  btn:ClearAllPoints()
  btn:SetPoint("RIGHT", self.CheckMark, "LEFT", 0, 0)
  
  -- Initial visual state
  btn:GetNormalTexture():SetAlpha(0.4)
  btn:Hide()
  
  self.DeleteButton = btn
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
  
  self.DeleteButton:Show()
end

local function FrameAtMouse()
  local foci = GetMouseFoci()
  if #foci <= 0 then return end
  local f = foci[1]
  return f.GetName and f:GetName() or tostring(f)
end

--- @return boolean
local function IsDeleteButtonAtMousePoint()
  local foci = GetMouseFoci()
  if #foci <= 0 then return end
  --- @type EquipmentSetDeleteButton|table
  local f = foci[1]
  return f.IsDeleteButton == true
end
--'Gears_EquipmentSetDeleteButton'

function o:OnLeave()
  print('xx ESM OnLeave: Delete btn at mouse-pt:', IsDeleteButtonAtMousePoint())
  if not IsDeleteButtonAtMousePoint() then self.DeleteButton:Hide() end
  if self.selected == true then return end
  self:HideBorder()
end
function o:OnDoubleClick() self:EquipGear() end

--- @see MainFrame.xml#L11 / Gears_DeleteButtonTemplate
--- @param button ButtonObj
--- @param mouseButton Name The name of the button that was clicked.
function o:OnDeleteButtonClick(button, mouseButton)
  if mouseButton ~= "LeftButton" then return end
  print('xx OnDeleteButtonClick')
end

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
  if self.selected then self:ShowBorder(); return end
  self:HideBorder()
end

function o:ShowBorderOnHover()
  self:SetBackdropColor(1.0, 0.9, 0.2, 0.05)
  self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
end


function o:ShowBorder()
  --self:SetBackdropColor(1, 1, 1, 1)
  --self:SetBackdropColor(0, 0, 0, 0)
  self:SetBackdropColor(1, 1, 1, 0.1)
  self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
end

function o:HideBorder()
  self:SetBackdropColor(0, 0, 0, 0)
  self:SetBackdropBorderColor(0, 0, 0, 0)
end

