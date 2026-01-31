--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Alias
---------------------------------------------------------------------]]
--- @alias ToggleButton ToggleButtonMixin|CheckButtonObj

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local TOGGLE_BUTTON_ICON = [[Interface\AddOns\Gears\Assets\gears-button-2b]]
local TOOLTIP_DELAY = 0.01
--- temp local
local L = {}
L['Open Gears Panel'] = 'Open Gears Panel'

--[[-------------------------------------------------------------------
ToggleButtonMixin
---------------------------------------------------------------------]]
--- @class ToggleButtonMixin : CheckButton
--- @field Icon TextureObj
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
  
  local checked = self:GetCheckedTexture()
  checked:SetVertexColor(0.2, 1.0, 0.4, 1.0)
  
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
    Gears_MainFrame:Show()
    return end
  PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE)
  Gears_MainFrame:Hide()
  --self:GetNormalTexture():SetAlpha(0.99)
end

function o:OnEnter()
  if self:GetChecked() then return end
  
  C_Timer.After(TOOLTIP_DELAY, function()
    if not self:IsMouseOver() then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L['Open Gears Panel'], 1, 1, 1)
    GameTooltip:Show()
  end)
end

function o:OnLeave()
  GameTooltip:Hide()
end

function o.AnchorToPaperDoll()
  if EngravingFrame and RuneFrameControlButton then
    --- @type CheckButtonObj
    local anch = RuneFrameControlButton
    --- @type CheckButtonObj
    local btn = Gears_ToggleButton
    btn:ClearAllPoints()
    btn:SetPoint('TOPRIGHT', anch, 'TOPLEFT', -2, 1)
    --anch:GetCheckedTexture():SetAlpha(0.6)
    --anch:GetCheckedTexture():SetBlendMode('ADD')
    
    
    --btn:SetPoint('TOPRIGHT', RuneFrameControlButton, 'TOPLEFT', -2, 0)
    --btn:SetPoint('TOPRIGHT', Gears_ToggleButton, 'TOPLEFT', -2, -4)
    --btn:SetPoint('TOPRIGHT', Gears_ToggleButton, 'TOPLEFT', -2, -1)
    --btn:GetCheckedTexture():SetAlpha(0.4)
    --btn:GetCheckedTexture():SetBlendMode('ADD')
  end
end
