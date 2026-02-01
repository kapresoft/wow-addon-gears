--- @type Namespace
local ns = select(2, ...)
local cfu = ns.O.CharacterFrameUtil

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
--- @field owner PaperDollFrame
Gears_ToggleButtonMixin = {}
local p = ns:log('ToggleButtonMixin')

--- @type ToggleButtonMixin | ToggleButton
local o  = Gears_ToggleButtonMixin

--- Handles Clicks on the Original Blizz Equipment Gear tab
--- @param self ToggleButton
local function ToggleButton_BlizzEquipmentGearHook(self)
  if not PaperDollSidebarTab3 then return end
  PaperDollSidebarTab3:HookScript("OnClick", function(btn)
    if self:IsChecked() then
      self:__HideGearsIsShownBlizzEquipUI()
    end
  end)
end

--- @see Gears_MainFrameMixin#MainFrameMixin_OnPlayerLogin()
--- @param gearsMainFrame Gears_MainFrameMixin
function o:OnPlayerLogin(gearsMainFrame)
  ToggleButton_BlizzEquipmentGearHook(self)
end

function o:OnLoad()
  ns.toggleButton = self
  
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
  self:__ShowGears()
end

--- @param enable boolean
function o:EnableEquipmentSlots(enable)
  cfu:ForEachEquipmentSlot(function(s, btn, po)
    --p(('slot[%s]:'):format(s.name), s)
    if enable then po:Show() else po:Hide() end
  end)
end

function o:OnClick()
  GameTooltip:Hide()
  if self:IsChecked() then
    self:__ShowGears()
    
    -- in MoPs, there is an existing EquipmentManager,
    -- We will show character stats when this is the case
    -- so the player is not confused.
    -- todo next: Prompt the user to use Gears as main equipment manager?
    --    • then, replace EquipmentManager with Gears icon, click logic, etc.
    local emp = PaperDollFrame and PaperDollSidebarTab1 and PaperDollFrame.EquipmentManagerPane
    if emp and emp:IsShown() then
      PaperDollSidebarTab1:Click()
      self:EnableEquipmentSlots(true)
    end
    return
  end
  
  self:__HideGears()
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

function o:IsChecked() return self:GetChecked() end

function o:__ShowGears()
  PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
  ns.gears:Show()
  ns.gears.__stickyHide = false
  self:EnableEquipmentSlots(true)
end

function o:__HideGears()
  PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE)
  ns.gears:Hide()
  ns.gears.__stickyHide = true
  self:EnableEquipmentSlots(false)
end
function o:__HideGearsIsShownBlizzEquipUI()
  PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE)
  ns.gears:Hide()
  ns.gears.__stickyHide = true
  self:SetChecked(false)
  self:EnableEquipmentSlots(true)
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
