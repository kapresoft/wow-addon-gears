--- @type Namespace
local ns = select(2, ...)

--- @class EquipmentSetFrameMixin : Frame
Gears_EquipmentSetFrameMixin = {}
local S = Gears_EquipmentSetFrameMixin
local p = ns:Log('Gears_EquipmentSetFrame')

--- @param frame FrameObj
local function AnchorToPaperDoll(frame)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -34, -10)
  --frame:SetPoint("BOTTOMLEFT", PaperDollFrame, "BOTTOMRIGHT", 0, 0)
end

function S:OnLoad()

  C_Timer.After(1, function()
    p('xxx OnLoad() called...')
    p('Parent:', PaperDollFrame:GetParent():GetName())
  end)
  self:SetParent(PaperDollFrame:GetParent())
  self:SetBackdrop(BACKDROP_DARK_DIALOG_32_32)
  --self:SetScale(PaperDollFrame:GetScale())

  local _frame = self
--[[  hooksecurefunc("ToggleCharacter", function(tab)
    if tab == "PaperDollFrame" then
      -- ToggleCharacter called for PaperDollFrame
      AnchorToPaperDoll(_frame)
      self:Show()
      p('xxx PaperDollFrame just opened...')
    end
  end)]]

  PaperDollFrame:HookScript("OnShow", function()
    p('xxx OnShow():: PaperDollFrame...')
    AnchorToPaperDoll(_frame)
    self:Show()
  end)
  PaperDollFrame:HookScript("OnHide", function()
    p('xxx OnHide()::HookScript PaperDollFrame...')
    _frame:OnClickClose()
  end)


end

function S:OnClickClose() self:Hide() end

