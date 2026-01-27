--- @type Namespace
local ns = select(2, ...)
--[[-------------------------------------------------------------------
Types and Alias
---------------------------------------------------------------------]]
--- @class __ButtonsContainerFrame
--- @field EquipButton ButtonObj

--- @class EquipmentSetInfo
--- @field id Identifier The equipment set ID
--- @field index Index
--- @field name Name
--- @field icon IconIDOrPath

-- Aliases -------------
--- @alias ButtonsContainerFrame __ButtonsContainerFrame|FrameObj
--- @alias MainFrame MainFrameMixin | FrameObj
--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]

--[[-------------------------------------------------------------------
MainFrame
---------------------------------------------------------------------]]
--- @class MainFrameMixin
--- @field private framePool table<number, EquipmentSetFrame>
--- @field info EquipmentSetInfo
--- @field ScrollFrame ScrollFrameObj
Gears_MainFrameMixin = {}
local p = ns:log('MainFrame')

--- @type MainFrameMixin | MainFrame | AceEvent | AceBucket
local o = Gears_MainFrameMixin
LibStub("AceEvent-3.0"):Embed(o);
LibStub("AceBucket-3.0"):Embed(o)

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

--[[-------------------------------------------------------------------
Methods: Gears_MainFrameMixin (Private Methods)
---------------------------------------------------------------------]]
--- @param frame FrameObj
local function MainFrameMixin_AnchorToPaperDoll(frame)
  frame:ClearAllPoints()
  local osx, osy = 0, 2
  if ns:IsTBC() then
    osx, osy = -34, -12
  end
  frame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", osx, osy)
end
--- @param self MainFrameMixin
--- @return ButtonObj
local function MainFrameMixin_EquipButton(self) return self.ButtonsContainerFrame.EquipButton end
--- @param self MainFrameMixin
--- @return ButtonObj
local function MainFrameMixin_SaveButton(self) return self.ButtonsContainerFrame.SaveButton end

--- @param self MainFrameMixin
--- @param isEnabledState boolean
local function MainFrameMixin_UpdateActionsEnabledState(self, isEnabledState)
  MainFrameMixin_EquipButton(self):SetEnabled(isEnabledState)
  MainFrameMixin_SaveButton(self):SetEnabled(isEnabledState)
end

--- @param self MainFrameMixin
--- @param index number The equipment set frame index
--- @return EquipmentSetFrame
local function MainFrameMixin_EquipmentSet(self, index) return self.framePool[index] end

--- @param self MainFrameMixin
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

--- @param self MainFrameMixin
local function MainFrameMixin_OnPlayerLogin(self) self:OnLoadEquipmentSet() end

--- @private
--- @param self MainFrameMixin
local function MainFrameMixin_OnEquipmentChanged(self)
  print('xx MainFrameMixin_OnEquipmentChanged')
  self:ForEachEquipment(function(info)
    local equipSet = MainFrameMixin_EquipmentSet(self, info.index)
    
    if equipSet then equipSet:UpdateFullyEquippedState(function(isFullyEquipped)
      if equipSet.selected then
        MainFrameMixin_UpdateActionsEnabledState(self, false)
      end
    end) end
  end)
end

--- Fired when equipment set is created, updated, deleted
--- via C_DeleteEquipmentSet()
--- @param self MainFrameMixin
local function MainFrameMixin_OnEquipmentSetsChanged(self)
  self:RefreshEquipmentSet()
end

--[[-------------------------------------------------------------------
Methods: Gears_MainFrameMixin
---------------------------------------------------------------------]]
function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)
  --self:SetBackdrop(BACKDROP_DARK_DIALOG_32_32)
  
  -- set same parent so frame is scaled automatically
  self:SetParent(PaperDollFrame:GetParent())
  
  --- @type ScrollFrameObj
  local scrollFrame = self.ScrollFrame
  -- set scrollChild here to enable scrolling
  scrollFrame:SetScrollChild(scrollFrame.ScrollChild)
  
  --- @type FontString
  local headerText = self.HeaderTitle
  headerText:SetText(ns.addon)
  
  -- todo next: locale
  MainFrameMixin_EquipButton(self):SetText('Equip')
  MainFrameMixin_SaveButton(self):SetText('Save')
  
  local _frame = self
  PaperDollFrame:HookScript("OnShow", function()
    MainFrameMixin_AnchorToPaperDoll(_frame)
    _frame:Show()
  end)
  PaperDollFrame:HookScript("OnHide", function()
    _frame:OnClickClose()
  end)
  
  self:RegisterEvent('PLAYER_LOGIN', fn(MainFrameMixin_OnPlayerLogin, self))
  
  local equipButton = MainFrameMixin_EquipButton(self)
  local saveButton = MainFrameMixin_SaveButton(self)
  equipButton.owner = self
  saveButton.owner = self
end

--- When the mouse is out of the EquipmentSetFrame and into the main frame,
--- hide other EquipmentSet specific action buttons
function o:OnEnter()
  self:ForEachEquipmentFrame(function(eqs)
    eqs:HideActionButtons()
  end)
end

--- @private
function o:OnLoadEquipmentSet()
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
      print('xx removing unused')
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
    if eqs.selected and callback then callback(eqs) end
  end
end

--- @private
function o:OnClickClose() self:Hide() end

--- @see MainFrame.xml#L124 (EquipButton)
--- @param button ButtonObj
--- @param mouseButton Name The name of the button that was clicked.
function o:OnEquipButtonClick(button, mouseButton)
  if mouseButton ~= "LeftButton" then return end
  self:WithSelectedEquipmentSet(function(sel) sel:EquipGear() end)
end

--- @see MainFrame.xml#L124 (SaveButton)
--- @param button ButtonObj
--- @param mouseButton Name The name of the button that was clicked.
function o:OnSaveButtonClick(button, mouseButton)
  if mouseButton ~= "LeftButton" then return end
  self:WithSelectedEquipmentSet(function(sel) sel:SaveGear() end)
end
