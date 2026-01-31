--- @type Namespace
local ns = select(2, ...)

-- todo: Drag and drop to actionbars

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local C_GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo
local C_PickupEquipmentSet = C_EquipmentSet.PickupEquipmentSet
local CHECKBOX_TEXTURE = [[Interface\Buttons\UI-CheckBox-Check]]

local TOOLTIP_DELAY = 0.01
local BULLET        = '•'

local bulletFmt = ' %s %s: %s'
local c_white = ns:colorFn('afafaf')
local c_blue = ns:colorFn('71ABFF')
local c_yellow1 = ns:colorFn('E6BF33')
local c_yellow = ns:colorFn('FFE680')

--- temp locale
local L = {}
L['Equipment Set']         = 'Equipment Set'
L['Left-click']            = 'Left-click'
L['Double-click']          = 'Double-click'
L['Drag']                  = 'Drag'
L['Available Actions']     = 'Available Actions'
L['Select']                = 'Select'
L['Equip']                 = 'Equip'
L['Drag to an action bar'] = 'Drag to an action bar'


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
--- @param self EquipmentSetFrame
local function EquipmentSet_ShowTooltip(self)
  C_Timer.After(TOOLTIP_DELAY, function()
    if not self:IsMouseOver() then return end
    
    local name, iconFileID, setID, isEquipped,
    numItems, numEquipped, numInInventory,
    numLost, numIgnored =
    C_EquipmentSet.GetEquipmentSetInfo(self:GetID())
    
    local eq = {
      name            = name,
      iconFileID      = iconFileID,
      setID           = setID,
      isEquipped      = isEquipped,
      numItems        = numItems,
      numEquipped     = numEquipped,
      numInInventory  = numInInventory,
      numLost         = numLost,
      numIgnored      = numIgnored,
    }

    local availableActions = c_blue(L['Available Actions']) .. ':'
    local eqSet = c_yellow1(L['Equipment Set'] .. ':')
    local leftClick = (bulletFmt):format(c_white(BULLET), c_yellow(L['Left-click']), c_white(L['Select']))
    local doubleClick = (bulletFmt):format(c_white(BULLET), c_yellow(L['Double-click']),  c_white(L['Equip']))
    local drag = (bulletFmt):format(c_white(BULLET), c_yellow(L['Drag']), c_white(L['Drag to an action bar']))
    
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddDoubleLine(eqSet, c_blue(self.info.name))
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(availableActions)
    GameTooltip:AddLine(leftClick)
    GameTooltip:AddLine(doubleClick)
    GameTooltip:AddLine(drag)
    GameTooltip:Show()
  end)
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
  if ns:IsMists() then
    PlaySound(SOUNDKIT.PUT_DOWN_SMALL_CHAIN)
  else
    PlaySound(SOUNDKIT.PUT_DOWN_SMALL_CHAIN)
    C_Timer.After(0.2, function()
      PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
    end)
  end
  
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
