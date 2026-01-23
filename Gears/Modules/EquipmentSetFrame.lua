--- @type Namespace
local ns = select(2, ...)

--- @class EquipmentSetFrameMixin : Frame
Gears_EquipmentSetFrameMixin = {}
local S = Gears_EquipmentSetFrameMixin
local p = ns:Log('Gears_EquipmentSetFrame')

--- @param frame FrameObj
local function AnchorToPaperDoll(frame)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -34, -12)
end

function S:OnLoad()

  -- set same parent so frame is scaled automatically
  self:SetParent(PaperDollFrame:GetParent())
  --self:SetBackdrop(BACKDROP_DARK_DIALOG_32_32)
  self:SetBackdrop(BACKDROP_TOAST_12_12)

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

