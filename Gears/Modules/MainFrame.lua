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
MainFrame
---------------------------------------------------------------------]]
--- @class MainFrameMixin
--- @field rows table<number, EquipmentSet>
Gears_MainFrameMixin = {}
local p = ns:log('MainFrame')

--- @type MainFrameMixin | MainFrame
local o = Gears_MainFrameMixin

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param frame FrameObj
local function AnchorToPaperDoll(frame)
  frame:ClearAllPoints()
  local osx, osy = 0, 2
  if ns:IsTBC() then
    osx, osy = -34, -12
  end
  frame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", osx, osy)
end

--- @param self MainFrameMixin
--- @return ButtonObj
local function EquipButton(self) return self.ButtonsContainerFrame.EquipButton end
--- @param self MainFrameMixin
--- @return ButtonObj
local function SaveButton(self) return self.ButtonsContainerFrame.SaveButton end

--[[-------------------------------------------------------------------
Methods: Gears_MainFrameMixin
---------------------------------------------------------------------]]
function o:OnLoad()

  -- set same parent so frame is scaled automatically
  self:SetParent(PaperDollFrame:GetParent())
  --self:SetBackdrop(BACKDROP_DARK_DIALOG_32_32)
  self:SetBackdrop(BACKDROP_TOAST_12_12)

  --- @type ScrollFrameObj
  local scrollFrame = self.ScrollFrame
  local child = scrollFrame.ScrollChild
  --child:SetWidth(scrollFrame:GetWidth() - 20) -- scrollbar width

  scrollFrame:SetScrollChild(child)

  --- @type FontString
  local headerText = self.HeaderTitle
  headerText:SetText(ns.addon)

  local _frame = self
  PaperDollFrame:HookScript("OnShow", function()
    AnchorToPaperDoll(_frame)
    _frame:Show()
  end)
  PaperDollFrame:HookScript("OnHide", function()
    _frame:OnClickClose()
  end)

  C_Timer.After(0.1, function()
    local rowCount = self:ForEachEquipment(function(info)
      self:AddEquipmentSet(info)
    end)
    self:UpdateScrollHeight(rowCount)
    
    self:__UpdateActionsEnabledState(false)
  end)

end

--- @param equipID Identifier
--- @param callback fun(info:EquipmentSetInfo) | "function(info) end"
function o:ForEachEquipmentExcept(equipID, callback)
    assert(equipID, "The param equipID is required.")
    self:ForEachEquipment(function(info)
      if info.id ~= equipID then callback(info) end
    end)
end

--- @param callback fun(info:EquipmentSetInfo) | "function(info) end"
--- @return number The row count
function o:ForEachEquipment(callback)
  local rowCount = 0
  local eq = C_EquipmentSet
  --- @type table<number,number>
  local ids = eq.GetEquipmentSetIDs()
  local set = {}
  for i, id in ipairs(ids) do
    rowCount = rowCount + 1
    local name, icon = eq.GetEquipmentSetInfo(id)
    local info       = { id=id, index=i, name = name, icon = icon }
    callback(info)
  end
  return rowCount
end

--- @param eq EquipmentSetInfo
function o:AddEquipmentSet(eq)
  local index        = eq.index
  local rowKey       = 'Row' .. index
  self.rows          = self.rows or {}
  local scrollChild  = self.ScrollFrame.ScrollChild

  --- @type EquipmentSet
  local equipmentSet = CreateFrame("Frame", ("$parent_EquipmentSet%s"):format(index),
          scrollChild, "Gears_EquipmentSetTemplate");
  equipmentSet.owner = self; self.rows[index] = equipmentSet
  equipmentSet:SetParentKey(rowKey)
  equipmentSet.equipSetID = eq.id
  
  if index > 1 then
    equipmentSet:SetPoint("TOPLEFT", self.rows[index - 1], "BOTTOMLEFT")
  end

  --- @type ButtonObj
  local iconBtn = equipmentSet.IconButton
  iconBtn:SetNormalTexture(eq.icon)
  --- @type FontStringObj
  local eqSetName = equipmentSet.Label
  eqSetName:SetText(eq.name)

  equipmentSet:Show()
  self.rows[index] = equipmentSet
  equipmentSet:OnUpdateEquippedState()

  return equipmentSet
end

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

function o:OnClickClose() self:Hide() end

--- @param equipSet EquipmentSet
function o:SelectEquipmentSet(equipSet)
  assert(type(equipSet) == 'table', "The param equipSet is required.")
  
  --- @type EquipmentSet
  local otherEquipSet
  local id = equipSet.equipSetID
  
  equipSet:SetSelected(true)
  equipSet:OnUpdateEquippedState(function(isFullyEquipped)
    self:__UpdateActionsEnabledState(not isFullyEquipped)
  end)
  
  -- uncheck the rest
  self:ForEachEquipmentExcept(id, function(info)
    otherEquipSet = self.rows[info.index]
    otherEquipSet:SetSelected(false)
  end)
end

--- @private
--- @param isEnabledState boolean
function o:__UpdateActionsEnabledState(isEnabledState)
  EquipButton(self):SetEnabled(isEnabledState)
  SaveButton(self):SetEnabled(isEnabledState)
end
