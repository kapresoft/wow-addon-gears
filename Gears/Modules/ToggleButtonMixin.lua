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
  
  local tex = [[interface/icons/inv_misc_gear_06]]
  --local tex = [[Interface\AddOns\Gears\Assets\gears-button]]
  --- @type TextureObj
  local icon = self:CreateTexture(nil, "ARTWORK")
  icon:SetSize(36, 36)
  icon:SetPoint("CENTER", self)
  icon:SetTexture(tex)
  self.Icon = icon
  
  -- green highlight
  local hl = self:GetHighlightTexture()
  hl:SetColorTexture(0.2, 1.0, 0.4, 0.25)
  self:SetScale(0.8)
  self:Show()
end
function o:OnClick()
  if self:GetChecked() then Gears_MainFrame:Show(); return end
  Gears_MainFrame:Hide()
end
