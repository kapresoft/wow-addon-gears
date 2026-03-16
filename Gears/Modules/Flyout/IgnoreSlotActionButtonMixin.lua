--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local includeTex = [[Interface\PaperDollInfoFrame\Character-Plus]]
local ignoreTex = [[Interface\Buttons\UI-GroupLoot-Pass-Up]]
--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_IsSlotIgnoredForSave = C_EquipmentSet and C_EquipmentSet.IsSlotIgnoredForSave
local C_IgnoreSlotForSave = C_EquipmentSet and C_EquipmentSet.IgnoreSlotForSave
local C_UnignoreSlotForSave = C_EquipmentSet and C_EquipmentSet.UnignoreSlotForSave
local C_GetIgnoredSlots = C_EquipmentSet and C_EquipmentSet.GetIgnoredSlots

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotActionButtonMixin
-------------------------------------------------------------------------------]]
--- @see NamespaceObjects
local libName = 'IgnoreSlotActionButtonMixin'
--- @class IgnoreSlotActionButtonMixin
--- @field TemplateName string
--- @field widget ExcludeSlotActionButtonWidget
--- @field Icon TextureObj
--- @field GetParent fun(self:IgnoreSlotActionButtonMixin) : FlyoutFrame
local S = {}; Gears_IgnoreSlotActionButtonMixin = S
--- @see EquipmentSlotFlyout.xml/Button[@name='Gears_IgnoreSlotActionButtonTemplate']
S.TemplateName = 'Gears_IgnoreSlotActionButtonTemplate'
--
--- @alias IgnoreSlotActionButton IgnoreSlotActionButtonMixin | ButtonObj
--
local p, pd, t, tf = ns:log(libName)
--[[-------------------------------------------------------------------
Widget Methods
---------------------------------------------------------------------]]
---@param w ExcludeSlotActionButtonWidget
local function WidgetMethods(w)
  
  --- @return BlizzCharacterSlotItemButton
  function w:GetCharItemSlot() return w.frame:GetCharItemSlot() end
  --- @return SlotID
  function w:GetSlotID() return self.frame:GetCharItemSlot():GetID() end
  --- @return boolean
  function w:IsIgnored() return w.slotFlyoutButton.widget:IsIgnored() end
  --- @return TextureObj
  function w:GetIgnoreOverlay() return self:GetCharItemSlot().ignoreSlotOverlay end
  --- @param ignored boolean
  function w:UpdateActionTexture(ignored)
    local tex = ignored and includeTex or ignoreTex
    self.frame.Icon:SetTexture(tex)
    self:UpdateCharItemSlotIgnoredOverlay(ignored)
  end
  --- @param ignored boolean
  function w:SyncIgnoredState(ignored)
    local fnc = ignored and C_IgnoreSlotForSave or C_UnignoreSlotForSave
    fnc(self:GetSlotID())
    self:UpdateActionTexture(ignored)
  end
  --- @param ignored boolean
  function w:UpdateCharItemSlotIgnoredOverlay(ignored)
    local fn = ignored and 'Show' or 'Hide'
    local overlay = self:GetIgnoreOverlay(); overlay[fn](overlay)
  end
end

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotActionButtonMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type IgnoreSlotActionButtonMixin | IgnoreSlotActionButton
local o = Gears_IgnoreSlotActionButtonMixin

function o:OnLoad()
  local slotFlyoutBtn = self:GetFlyout()
  local charItemSlot = self:GetCharItemSlot()
  
  --- @type TextureObj
  local overlay = charItemSlot:CreateTexture(nil, "OVERLAY", nil, 7)
  overlay:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
  overlay:SetAllPoints(charItemSlot.icon or charItemSlot.IconTexture)
  overlay:SetAlpha(0.6)
  overlay:Hide()
  charItemSlot.ignoreSlotOverlay = overlay
  
  --- @class ExcludeSlotActionButtonWidget
  --- @field frame IgnoreSlotActionButton
  --- @field slotFlyoutButton EquipmentSlotFlyout
  local widget = {
    frame = self,
    slotFlyoutButton = slotFlyoutBtn
  }; WidgetMethods(widget); self.widget = widget
  
end

--- @return boolean The new ignored-for-save state
function o:ToggleState()
  local equipSet = ns.gears:GetSelected()
  local slotID = self:GetSlotID()
  local ignoredForSave = C_IsSlotIgnoredForSave(slotID) -- ignored but not yet saved
  local w = self.widget
  local slotText = ('%s::%s'):format(equipSet:__GetDebugName(), w.slotFlyoutButton:__GetDebugName())
  --t('OnClick::B4', slotText, 'IsSlotIgnoredForSave=', ignoredForSave)
  if ignoredForSave then C_UnignoreSlotForSave(slotID)
  else C_IgnoreSlotForSave(slotID) end
  
  return C_IsSlotIgnoredForSave(slotID)
end

--- C_EquipmentSet.IgnoreSlotForSave(slotID)
function o:OnClick()
  ns:PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  if not ns.gears:HasSelection() then return end
  local ignored = self:ToggleState()
  self.widget:UpdateActionTexture(ignored)
  ns.gears:GetSaveButton():SetEnabled(true)
  
  Gears_MainFrame:WithSelectedEquipmentSet(function(sel)
    local ignoredSlots = C_GetIgnoredSlots(sel.info.id)
    for slotID, ignored in pairs(ignoredSlots) do
      if C_IsSlotIgnoredForSave(slotID) then
        t('OnClick::IgnoredForSave', sel:__GetDebugName(), 'slotID=', slotID)
      end
    end
  end)
  
  
  self:GetParent():Hide()
end

--- @return EquipmentSlotFlyout
function o:GetFlyout() return self:GetParent():GetParent() end
--- @return BlizzCharacterSlotItemButton
function o:GetCharItemSlot() return self:GetFlyout().widget.slotButton end
--- @return SlotID
function o:GetSlotID() return self:GetCharItemSlot():GetID() end
