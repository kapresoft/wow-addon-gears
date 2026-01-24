--- @type Namespace
local ns = select(2, ...)

--- @class EquipmentSetFrameMixin : Frame
Gears_EquipmentSetFrameMixin = {}
local S = Gears_EquipmentSetFrameMixin
local p = ns:log('Gears_EquipmentSetFrame')

--- @param frame FrameObj
local function AnchorToPaperDoll(frame)
  frame:ClearAllPoints()
  local osx, osy = 0, 2
  if ns:IsTBC() then
    osx, osy = -34, -12
  end
  frame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", osx, osy)
end

function S:OnLoad()

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

  C_Timer.After(1, function()
    local rowCount = self:ForEachEquipment(function(info)
      self:AddRow(info)
    end)
    self:UpdateScrollHeight(rowCount)
  end)

end

--- @class EquipmentSetInfo
--- @field index Index
--- @field name Name
--- @field icon IconIDOrPath

--- @param callback fun(info:EquipmentSetInfo) | "function(info) end"
--- @return number The row count
function S:ForEachEquipment(callback)
  local rowCount = 0
  local eq = C_EquipmentSet
  --- @type table<number,number>
  local ids = eq.GetEquipmentSetIDs()
  local set = {}
  for i, id in ipairs(ids) do
    rowCount = rowCount + 1
    local name, icon = eq.GetEquipmentSetInfo(id)
    local info       = { index=i, name = name, icon = icon }
    callback(info)
  end
  return rowCount
end

--- @param eq EquipmentSetInfo
function S:AddRow(eq)
  local index       = eq.index
  local rowKey      = 'Row' .. index
  self.rows         = self.rows or {}
  local scrollChild = self.ScrollFrame.ScrollChild

  --- @type FrameObj
  local row = CreateFrame("Frame", ("$parent_EquipmentSet%s"):format(index),
          scrollChild, "Gears_EquipmentSetRowTemplate");
  row:SetParent(self)
  row:SetParentKey(rowKey)
  print('xx rowName=', row:GetName())
  
  row:SetBackdropColor(0, 0, 0, 0)
  row:SetBackdropBorderColor(0, 0, 0, 0)
  
  if index > 1 then
    row:SetPoint("TOPLEFT", self.rows[index - 1], "BOTTOMLEFT")
  end

  --- @type ButtonObj
  local iconBtn = row.IconButton
  iconBtn:SetNormalTexture(eq.icon)
  --- @type FontStringObj
  local eqSetName = row.Label
  eqSetName:SetText(eq.name)

  row:Show()
  self.rows[index] = row


  --[[--- @type FrameObj
  local rowFrame   = self.ScrollFrame.ScrollChild
  print('xx rowKey=', rowKey, 'rowFrame=', rowFrame['Row1'])
  P = rowFrame
  local iconButton = rowFrame.IconButton
  print('xx iconButton=', pf(iconButton))]]

  return row
end

function S:UpdateScrollHeight(numRows)
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

function S:OnClickClose() self:Hide() end

