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
  
  
  -- green highlight
  --- @type TextureObj
  local hl  = self:GetHighlightTexture()
  hl:SetColorTexture(0.2, 1.0, 0.4, 0.25)
  hl:ClearAllPoints()
  hl:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
  hl:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
  self:SetScale(0.9)
  
  local tex  = [[Interface\AddOns\Gears\Assets\gears-button-2]]
  --- @type TextureObj
  local icon = self:CreateTexture(nil, 'OVERLAY')
  icon:SetSize(28, 28)
  icon:SetPoint('CENTER', self)
  icon:SetTexture(tex)
  icon:SetDrawLayer('OVERLAY', 1)
  self.Icon = icon
  
  self:Show()

end
function o:OnClick()
  if self:GetChecked() then Gears_MainFrame:Show(); return end
  Gears_MainFrame:Hide()
end
