--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Alias
---------------------------------------------------------------------]]
--- @alias ToggleButton ToggleButtonMixin|CheckButtonObj

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local TOGGLE_BUTTON_ICON = [[Interface\AddOns\Gears\Assets\gears-button-2]]
local TOOLTIP_DELAY = 0.35

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
  
  --- @type TextureObj
  local icon = self:CreateTexture(nil, 'OVERLAY')
  icon:SetSize(28, 28)
  icon:SetPoint('CENTER', self)
  icon:SetTexture(TOGGLE_BUTTON_ICON)
  icon:SetDrawLayer('OVERLAY', 1)
  self.Icon = icon
  
  self:Show()

end

function o:OnClick()
  GameTooltip:Hide()
  if self:GetChecked() then
    PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
    Gears_MainFrame:Show();
    return end
  PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE)
  Gears_MainFrame:Hide()
end

function o:OnEnter()
  if self:GetChecked() == true or not self:IsMouseOver() then return end
  
  local text = "Click to open Equipment"
  C_Timer.After(TOOLTIP_DELAY, function()
    if self:IsMouseOver() then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(text, 1, 1, 1)
      GameTooltip:Show()
    end
  end)
end

function o:OnLeave()
  GameTooltip:Hide()
end
