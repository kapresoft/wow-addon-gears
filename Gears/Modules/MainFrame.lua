--- @type Namespace
local ns = select(2, ...)
local L = ns:GetLocale()

--[[-------------------------------------------------------------------
Types and Alias
---------------------------------------------------------------------]]
--- @class __ButtonsContainerFrame
--- @field EquipButton ButtonObj
--- @field SaveButton ButtonObj
--- @field AddButton ButtonObj

--- @class EquipmentSetInfo
--- @field id Identifier The equipment set ID
--- @field index Index
--- @field name Name
--- @field icon IconIDOrPath

-- Aliases -------------
--- @alias ButtonsContainerFrame __ButtonsContainerFrame|FrameObj
--- @alias Gears_MainFrame Gears_MainFrameMixin | FrameObj | AceEvent_3_0 | AceBucket_3_0
--- @alias Gears_AddButton ButtonObj|IconButtonMixin

--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_CreateEquipmentSet = C_EquipmentSet.CreateEquipmentSet
local strtrim = strtrim

local esf = ns.O.EquipmentSlotFactory

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local libName = 'MainFrame'
local LibIconPickerUtil = ns.O.LibIconPickerUtil
local p, pd, t, tf = ns:log(libName)

--[[-------------------------------------------------------------------
Gears_AddButtonMixin
---------------------------------------------------------------------]]
--- @class Gears_AddButtonMixin : Button
--- @field owner Gears_MainFrame
Gears_AddButtonMixin = {}
do
  --- @type Gears_AddButtonMixin | Gears_AddButton
  local a = Gears_AddButtonMixin
  function a:OnLoad()
    IconButtonMixin.OnLoad(self)
    self.onClickHandler = function() self.owner:OnClick_AddButton(self) end
    self.tooltipText = L['Create a new equipment set']
  end
end

--[[-------------------------------------------------------------------
MainFrame
---------------------------------------------------------------------]]

--- @class Gears_MainFrameMixin : Frame
--- @field private framePool table<number, EquipmentSetFrame>
--- @field protected ButtonsContainerFrame ButtonsContainerFrame
--- @field info EquipmentSetInfo
--- @field ScrollFrame ScrollFrameObj
--- @field HeaderIconLeft TextureObj
--- @field __lastIcon IconIDOrPath
Gears_MainFrameMixin = {}

--- @type Gears_MainFrameMixin | Gears_MainFrame
local o = Gears_MainFrameMixin; ns:AceEvent(o); ns:AceBucket(o)

o.framePool = {}

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param targetFn fun()
--- @return fun()
local function fn(targetFn, ...)
  local boundArgs = { ... }
  return function(...) targetFn(unpack(boundArgs), ...) end
end

-- todo next: move to MainController?
--- @param self Gears_MainFrameMixin|Gears_MainFrame
local function MainFrame_PaperDollFrameHooks(self)
  PaperDollFrame:HookScript("OnShow", function(pdf)
    self:OnShow_PaperDollFrame()
    self:SendMessage(ns:msg('OnShowPaperDollFrame'), self, pdf)
  end)
end

--- @param frame Gears_MainFrameMixin|Gears_MainFrame
local function MainFrameMixin_AnchorToPaperDoll(frame)
  local anchorFrame = CharacterFrameCloseButton
  local osx, osy = -6, -4
  
  if EngravingFrame then
    if EngravingFrame:IsShown() then
      anchorFrame = EngravingFrame.Border.NineSlice
      osx, osy = -4, 1
    else
      osx, osy    = -8, -3
    end
  elseif ns:IsMainLine() then
    osx, osy = -2, 0
    if frame.__origHeight then frame:SetHeight(frame.__origHeight - 3) end
  end
  
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", osx, osy)
  ns.toggleButton:AnchorToPaperDoll()
end

--- @param self Gears_MainFrameMixin
--- @return ButtonObj
local function MainFrameMixin_OnLoadButtons(self)
  local equipButton = self:GetEquipButton()
  local saveButton = self:GetSaveButton()
  local addButton = self:GetAddButton()
  equipButton.owner = self
  saveButton.owner = self
  addButton.owner = self
end

--- @param self Gears_MainFrameMixin
--- @param isEnabledState boolean
local function MainFrameMixin_UpdateActionsEnabledState(self, isEnabledState)
  self:GetEquipButton():SetEnabled(isEnabledState)
  self:GetSaveButton():SetEnabled(isEnabledState)
end

--- @param self Gears_MainFrameMixin
--- @param index number The equipment set frame index
--- @return EquipmentSetFrame
local function MainFrameMixin_EquipmentSet(self, index) return self.framePool[index] end

--- @param self Gears_MainFrameMixin
--- @param eqInfo EquipmentSetInfo
--- @return EquipmentSetFrame
local function MainFrameMixin_GetFrame(self, eqInfo)
  local index = eqInfo.index
  if not self.framePool[index] then
    self.framePool[index] = CreateFrame("Button", ("$parent_EquipmentSet%s"):format(eqInfo.id),
            self.ScrollFrame.ScrollChild, "Gears_EquipmentSetTemplate")
  end
  self.framePool[index].owner = self
  self.framePool[index]:SetInfo(eqInfo)
  
  return self.framePool[index]
end

--- @private
--- @param self Gears_MainFrameMixin
local function MainFrameMixin_OnEquipmentChanged(self)
  self:ForEachEquipment(function(info)
    local equipSet = MainFrameMixin_EquipmentSet(self, info.index)
    if not equipSet then return end
    
    equipSet:UpdateFullyEquippedState(function(isFullyEquipped)
      if equipSet.selected then
        MainFrameMixin_UpdateActionsEnabledState(self, not isFullyEquipped)
      end
    end)
    
  end)
end

--- @param self Gears_MainFrameMixin
local function MainFrameMixin_EngravingFrameHook(self)
  if not EngravingFrame then return end
  hooksecurefunc(EngravingFrame, "Show", function() MainFrameMixin_AnchorToPaperDoll(self) end)
  hooksecurefunc(EngravingFrame, "Hide", function() MainFrameMixin_AnchorToPaperDoll(self) end)
end

--- When the Blizzard EquipmentSet UI is visible and the
--- `CharacterFrameExpandButton` is expanded, the
--- `CharacterLevelText` becomes misaligned (e.g., "Level 80 Survival Hunter").
--- This adjusts the alignment to properly top/middle align the character level text.
local function MainFrameMixin_AlignCharacterLevelText()
  -- PaperDollInnerBorderTop: retail and MoP Adjustments
  if not PaperDollInnerBorderTop then return end

  --- @type FontStringObj
  local c = CharacterLevelText; if not c then return end
  c:ClearAllPoints()
  c:SetPoint("BOTTOM", PaperDollInnerBorderTop, 'TOP', 0, 0)
end

function o:OnShow_PaperDollFrame()
  if self:IsShown() then
    MainFrameMixin_AnchorToPaperDoll(self)
    MainFrameMixin_EngravingFrameHook(self)
  end
  MainFrameMixin_AlignCharacterLevelText()
end

--- In Retail (as of 12.x), CharStats/Titles/EquipmentSet is
--- always expanded.
--- @param self Gears_MainFrameMixin|Gears_MainFrame
local function MainFrameMixin_CharacterFrameHooks(self)
  local cfeb = CharacterFrameExpandButton; if not cfeb then return end
  cfeb:HookScript("OnClick", MainFrameMixin_AlignCharacterLevelText)
end

--- Fired when equipment set is created, updated, deleted
--- via C_DeleteEquipmentSet()
--- @param self Gears_MainFrameMixin
local function MainFrameMixin_OnEquipmentSetsChanged(self) self:RefreshEquipmentSet() end

--[[-------------------------------------------------------------------
Methods: Gears_MainFrameMixin
---------------------------------------------------------------------]]
function o:OnLoad()
  ns.gears = self
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)
  
  -- Reassert draw layer after SetBackdrop(); backdrop textures are created
  -- after XML construction and can overlap this texture due to same layer/sublevel.
  -- Calling SetDrawLayer here ensures HeaderIconLeft renders on top.
  self.HeaderIconLeft:SetDrawLayer("OVERLAY")
  
  -- set same parent so frame is scaled automatically
  self:SetParent(PaperDollFrame)
  -- set high so it is above other addons attached to char frame
  self:SetFrameLevel(100)
  
  local sb = self.ScrollFrame.ScrollBar
  local up = sb.ScrollUpButton
  local down = sb.ScrollDownButton
  
  up:SetAlpha(0)
  down:SetAlpha(0)
  up:EnableMouse(false)
  down:EnableMouse(false)
  
  --- @type TextureObj
  local thumb = sb:GetThumbTexture()
  local thumbAlpha, highlightAlpha = 0.4, 0.8
  
  thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
  thumb:SetVertexColor(0.75, 0.65, 0.25, thumbAlpha)
  thumb:SetSize(7, 160)
  
  sb:HookScript("OnEnter", function()
    thumb:SetAlpha(highlightAlpha)
  end)
  sb:HookScript("OnLeave", function()
    thumb:SetAlpha(thumbAlpha)
  end)
  
  --- @type ScrollFrameObj
  local scrollFrame = self.ScrollFrame
  -- set scrollChild here to enable scrolling
  scrollFrame:SetScrollChild(scrollFrame.ScrollChild)
  
  --- @type FontString
  local headerText = self.HeaderTitle
  headerText:SetText(ns.addon)
  
  MainFrameMixin_CharacterFrameHooks(self)
  MainFrameMixin_OnLoadButtons(self)
  
  self:Show()
  self:RegisterMessage(ns:msg('OnInit'), 'OnInit')
end

--- Only called once
function o:OnInit()
  self.__origHeight = self:GetHeight()
  self:InitEquipmentSet()
  esf:CreateSlotFlyouts()
  
  MainFrame_PaperDollFrameHooks(self)
  self:SendMessage(ns:msg('OnAfterInit'), self)
end

--- When the mouse is out of the EquipmentSetFrame and into the main frame,
--- hide other EquipmentSet specific action buttons
function o:OnEnter()
  self:ForEachEquipmentFrame(function(eqs)
    eqs:HideActionButtons()
  end)
end

--- @private
function o:InitEquipmentSet()
  self:RefreshEquipmentSet()
  MainFrameMixin_UpdateActionsEnabledState(self, false)
  
  -- bucket because [PLAYER_EQUIPMENT_CHANGED] fires a few times
  self:RegisterBucketEvent('PLAYER_EQUIPMENT_CHANGED', 0.01, fn(MainFrameMixin_OnEquipmentChanged, self))
  self:RegisterEvent('EQUIPMENT_SETS_CHANGED', fn(MainFrameMixin_OnEquipmentSetsChanged, self))
end

function o:RefreshEquipmentSet()
  -- always go through eq.GetEquipmentSetIDs() in self:ForEachEquipment()
  local usedCount = self:ForEachEquipment(function(info)
    local f = self:BuildEquipmentSet(info)
    f.__used = true
  end)
  
  for _, frame in pairs(self.framePool) do
    if not frame.__used then
      frame.info = nil
      frame:SetSelected(false)
      frame.CheckMark:Hide()
      frame:Hide()
    end
    frame.__used = nil
  end
  
  self:UpdateScrollHeight(usedCount)
end

--- Iterate through all equipments with an optional accept function.
--- @param callback fun(info:EquipmentSetInfo) | "function(info) end"
--- @param acceptFn nil|fun(eqsInfo:EquipmentSetInfo) : boolean @Optional: The filter function | "function(eqs) return true end"
--- @return number The number of accepted equipment sets
function o:ForEachEquipment(callback, acceptFn)
  local rowCount = 0
  local eq       = C_EquipmentSet
  local acceptEquipmentSet = acceptFn or function() return true  end
  
  --- @type table<number,number>
  local ids = eq.GetEquipmentSetIDs()
  for i, id in ipairs(ids) do
    local name, icon = eq.GetEquipmentSetInfo(id)
    local info       = { id = id, index = i, name = name, icon = icon }
    if acceptEquipmentSet(info) then
      rowCount = rowCount + 1
      callback(info) end
  end
  return rowCount
end

--- Iterate through all equipments with an optional accept function.
--- @param callback fun(eqs:EquipmentSetFrame) | "function(eqs) end"
--- @param acceptFn nil|fun(eqsInfo:EquipmentSetInfo) : boolean @Optional: The filter function | "function(eqs) return true end"
--- @return number The number of accepted equipment sets
function o:ForEachEquipmentFrame(callback, acceptFn)
  local rowCount = self:ForEachEquipment(function(info)
    callback(self.framePool[info.index])
  end, acceptFn)
  return rowCount
end

--- @param eqInfo EquipmentSetInfo
function o:BuildEquipmentSet(eqInfo)
  assert(eqInfo, 'BuildEquipmentSet(eqInfo): The param eqInfo is required.')
  
  local equipmentSet = MainFrameMixin_GetFrame(self, eqInfo)
  if eqInfo.index > 1 then
    equipmentSet:SetPoint("TOPLEFT", self.framePool[eqInfo.index - 1], "BOTTOMLEFT")
  end
  
  --- @type ButtonObj
  local iconBtn = equipmentSet.IconButton
  iconBtn:SetNormalTexture(eqInfo.icon)
  --- @type FontStringObj
  local eqSetName = equipmentSet.Label
  eqSetName:SetWidth(80)
  eqSetName:SetMaxLines(1)
  eqSetName:SetText(eqInfo.name)
  
  equipmentSet:Show()
  equipmentSet:UpdateFullyEquippedState()
  
  return equipmentSet
end

--- @private
function o:UpdateScrollHeight(numRows)
  local scrollFrame = self.ScrollFrame
  local child = scrollFrame.ScrollChild
  
  local rowHeight = 48
  local spacing   = 2
  local padding   = 0 -- adjust if you add top/bottom padding
  
  local height = (numRows * rowHeight)
          + ((numRows - 1) * spacing)
          + padding
  
  child:SetHeight(height)
end

--- @param equipSet EquipmentSetFrame
function o:SelectEquipmentSet(equipSet)
  assert(type(equipSet) == 'table', "The param equipSet is required.")
  
  --- @type EquipmentSetFrame
  local otherEquipSet
  local id = equipSet:GetID()
  
  equipSet:SetSelected(true)
  equipSet:UpdateFullyEquippedState(function(isFullyEquipped)
    MainFrameMixin_UpdateActionsEnabledState(self, not isFullyEquipped)
  end)
  
  -- uncheck the rest
  self:ForEachEquipment(function(info)
    otherEquipSet = self.framePool[info.index]
    otherEquipSet:SetSelected(false)
  end, function(eqsInfo) return eqsInfo.id ~= id end)
end

--- There is only one that can be selected at a time.
--- @param callback fun(sel:EquipmentSetFrame) : void
function o:WithSelectedEquipmentSet(callback)
  for _, eqs in pairs(self.framePool) do
    if eqs.selected and callback then return callback(eqs) end
  end
end

--- @see MainFrame.xml @XMLPath: Gears_MainFrameTemplate/ButtonsContainerFrame/EquipButton
--- @param button ButtonObj
--- @param mouseButton Name The name of the button that was clicked.
function o:OnClick_EquipButton(button, mouseButton)
  self:WithSelectedEquipmentSet(function(sel) sel:EquipGear() end)
end

--- @see MainFrame.xml @XMLPath: Gears_MainFrameTemplate/ButtonsContainerFrame/SaveButton
--- @param button ButtonObj
--- @param mouseButton Name The name of the button that was clicked.
function o:OnClick_SaveButton(button, mouseButton)
  self:WithSelectedEquipmentSet(function(sel) sel:SaveGear() end)
end

--- @see MainFrame.xml @XMLPath: Gears_MainFrameTemplate/ButtonsContainerFrame/AddButton
--- @param button ButtonObj
function o:OnClick_AddButton(button)
  ns:PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
  local opt = {
    icon = self.__lastIcon, showTextInput = true,
    textInput = { label = L['New Equipment Set'] .. ':', max = ns.MAX_CHARS_SET_NAME }
  }
  LibIconPickerUtil:Get(function(lip)
    lip:Open(function(sel)
      local esName = strtrim(sel.textInputValue)
      if #esName <= 0 then return end
      C_CreateEquipmentSet(esName, sel.icon)
      ns:PlaySound(SOUNDKIT.IG_MAINMENU_QUIT)
      self.__lastIcon = sel.icon
    end, opt)
  end)
end

function o:GetEquipButton()
  return self.ButtonsContainerFrame.EquipButton
end
function o:GetSaveButton()
  return self.ButtonsContainerFrame.SaveButton
end
function o:GetAddButton()
  return self.ButtonsContainerFrame.AddButton
end
