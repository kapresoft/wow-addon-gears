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
    osx, osy = -34, -19
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

  local rowHeight = 48
  local spacing = 2
  local numRows = 9

  child:SetHeight(numRows * (rowHeight + spacing))

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

end

function S:OnClickClose() self:Hide() end

