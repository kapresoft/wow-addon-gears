--- @type Namespace
local ns = select(2, ...)
local L = ns:GetLocale()
local cfu = ns.O.CharacterFrameUtil
local esf = ns.O.EquipmentSlotFlyoutManager

--[[-------------------------------------------------------------------
Alias
---------------------------------------------------------------------]]
--- @alias ToggleButton ToggleButtonMixin | CheckButtonObj| AceEvent

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local TOGGLE_BUTTON_ICON = [[Interface\AddOns\Gears\Assets\gears-button-2b]]
local TOOLTIP_DELAY = 0.01

--- The equipment manager tab on advanced versions of wow like MoP, Retail, etc.
--- @type FrameObj
local PaperDollSidebarTab3 = PaperDollSidebarTab3

local libName = 'ToggleButton'
local p, pd, t, tf = ns:log(libName)

--- todo next: move ecs methods on it's own lua file? publish events on open/close

--[[-------------------------------------------------------------------
ToggleButtonMixin
---------------------------------------------------------------------]]
--- @class ToggleButtonMixin : CheckButton
--- @field Icon TextureObj
--- @field owner PaperDollFrame
--- @field private __ecsFrame FrameObj The ECS_StatsFrame (Extended Character Stats addon)
--- @field private __ecsButton ButtonObj The ECS_ToggleButton (Extended Character Stats addon)
--- @field private __blizzEquipHooked boolean
--- @field private __ecsOnClickHooked boolean
--- @field private __ecsToggleButtonHooked boolean
Gears_ToggleButtonMixin = {};

--- @type ToggleButtonMixin | ToggleButton
local o  = Gears_ToggleButtonMixin; ns:AceEvent(o)

--- Handles Clicks on the Original Blizz Equipment Gear tab
--- @param self ToggleButton
local function ToggleButtonMixin_BlizzEquipmentGearHook(self)
  if not PaperDollSidebarTab3 or self.__blizzEquipHooked then return end
  self.__blizzEquipHooked = true
  PaperDollSidebarTab3:HookScript("OnClick", function(btn) self:OnClick_BlizzEquipmentPanel() end)
end

function o:OnLoad()
  ns.toggleButton = self
  
  self:SetParent(PaperDollFrame)
  self.owner = PaperDollFrame
  
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
  
  self:RegisterMessage(ns:msg('OnAfterInit'), 'OnAfterInit')
  self:RegisterMessage(ns:msg('OnShowPaperDollFrame'), 'OnShowPaperDollFrame_Message')
  
  self:Show()
end

--- Gears will be shown by default on PaperDollFrame::Open
--- @param evt Name
--- @param gearsMainFrame Gears_MainFrameMixin
function o:OnAfterInit(evt, gearsMainFrame)
  self.__ecsFrame, self.__ecsButton = ECS_StatsFrame, ECS_ToggleButton
  t('OnAfterInit', ('ecsFrame=%s, ecsBtn=%s'):format(tostring(self.__ecsFrame), tostring(self.__ecsButton)))
  
  ToggleButtonMixin_BlizzEquipmentGearHook(self)
  
  self:Click()
end

--- @param self ToggleButtonMixin|ToggleButton
local function ToggleButtonMixin_ECS_ToggleButton_Hook(self)
  if not self.__ecsButton or self.__ecsToggleButtonHooked then return end
  self.__ecsButton:HookScript("OnClick", function(btn)
    self:OnClick_ECS_ToggleButton()
  end)
  self.__ecsToggleButtonHooked = true
end

--- @param evt Name
--- @param gearsMainFrame Gears_MainFrameMixin
--- @param pdf PaperDollFrame|FrameObj
function o:OnShowPaperDollFrame_Message(evt, gearsMainFrame, pdf)
  ToggleButtonMixin_BlizzEquipmentGearHook(self)
  ToggleButtonMixin_ECS_ToggleButton_Hook(self)
  esf:UpdateVisibility()
end

--- If Gears is shown, hide it
function o:OnClick_ECS_ToggleButton()
  if self:IsChecked() then self:Click() end
end

--- @param enable boolean
function o:EnableEquipmentSlots(enable)
  if not ns.gears:HasSelection() then return end
  
  if not self:__HasBlizzEquipManager() then
    esf:SetFlyoutState(enable); return
  end
  
  local fn = enable and "Show" or "Hide"
  cfu:ForEachEquipmentSlot(function(s, btn, blizzFlyout)
    if blizzFlyout then blizzFlyout[fn](blizzFlyout) end
  end)
end

-- Clicks are always sticky
function o:OnClick()

  GameTooltip:Hide()
  if self:IsChecked() then
    self:__ShowGears()
    -- in MoPs, there is an existing EquipmentManager,
    -- We will show character stats when this is the case
    -- so the player is not confused.
    -- todo next: Prompt the user to use Gears as main equipment manager?
    --    • then, replace EquipmentManager with Gears icon, click logic, etc.
    if self:__BlizzEquipManagerIsShown() then
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

function o:OnLeave() GameTooltip:Hide() end

function o:IsChecked() return self:GetChecked() end

function o:__ShowGears()
  ns:PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
  ns.gears:Show()
  self:EnableEquipmentSlots(true)
  self:__HideECS()
end

function o:__HideGears()
  ns:PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE)
  ns.gears:Hide()
  self:EnableEquipmentSlots(false)
end

function o:__HideECS() return self.__ecsFrame and self.__ecsFrame:Hide() end

--- Hide 'Gears' panel if Blizz EquipmentSet Panel is shown
function o:OnClick_BlizzEquipmentPanel()
  if not self:IsChecked() then return end
  
  ns:PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE)
  ns.gears:Hide()
  self:SetChecked(false)
  self:EnableEquipmentSlots(true)
end

function o:AnchorToPaperDoll()
  if not (EngravingFrame and RuneFrameControlButton) then return end
  
  --- @type CheckButtonObj
  local anch = RuneFrameControlButton
  --- @type CheckButtonObj
  local btn  = Gears_ToggleButton
  btn:ClearAllPoints()
  btn:SetPoint('TOPRIGHT', anch, 'TOPLEFT', -2, 1)
end

--- @return FrameObj Container
function o:__GetBlizzEquipManager()
  return PaperDollFrame and PaperDollSidebarTab1 and PaperDollFrame.EquipmentManagerPane
end

--- @return boolean
function o:__BlizzEquipManagerIsShown()
  local em = self:__GetBlizzEquipManager(); return em and em:IsShown()
end

--- @boolean
function o:__HasBlizzEquipManager() return self:__GetBlizzEquipManager() ~= nil end
