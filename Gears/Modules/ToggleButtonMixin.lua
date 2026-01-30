--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Alias
---------------------------------------------------------------------]]
--- @alias ToggleButton ToggleButtonMixin|CheckButtonObj

--[[-------------------------------------------------------------------
ToggleButtonMixin
---------------------------------------------------------------------]]
--- @class ToggleButtonMixin : CheckButton
Gears_ToggleButtonMixin = {}
local p = ns:log('ToggleButtonMixin')

--- @type ToggleButtonMixin | ToggleButton
local o  = Gears_ToggleButtonMixin

function o:OnLoad()
  self:SetParent(PaperDollFrame)
  self.owner = PaperDollFrame
  self.tooltipText = "Open Gears"
  self:Show()
end
function o:OnClick()
  p("OnClick::Checked:", self:GetChecked())
  if self:GetChecked() then
    Gears_MainFrame:Show(); return
  end
  Gears_MainFrame:Hide()
end
