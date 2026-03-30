--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local cfu = ns.O.CharacterFrameUtil
local Tbl_IsEmpty = ns.O.Table.IsEmpty

--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_GetIgnoredSlots = C_EquipmentSet and C_EquipmentSet.GetIgnoredSlots
local C_ClearIgnoredSlotsForSave = C_EquipmentSet and C_EquipmentSet.ClearIgnoredSlotsForSave

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFlyoutManager
-------------------------------------------------------------------------------]]
--- @see NamespaceObjects
local libName = 'EquipmentSlotFlyoutManager'
--- @class EquipmentSlotFlyoutManager__
local S = ns:AceEvent(); ns.O.EquipmentSlotFlyoutManager = S
S = ns.O.AceHook:Embed(S)
local p, pd, t, tf = ns:log(libName)
--
--- @alias EquipmentSlotFlyoutManager EquipmentSlotFlyoutManager__ | AceEvent_3_0 | AceHook_3_0
--
--- @type table<SlotID, EquipmentSlotFlyout>
local flyoutsMap = {}

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFactory (Methods)
-------------------------------------------------------------------------------]]
--- @type EquipmentSlotFlyoutManager__ | EquipmentSlotFlyoutManager
local o = S

--- @param msg string
--- @param equipSetInfo EquipmentSetInfo
function o:OnEquipmentSetSelected(msg, equipSetInfo)
  self:EnableEquipmentSlots(true)
  C_ClearIgnoredSlotsForSave()
  self:ForEachEquipSetSlots(equipSetInfo.id, function(flyout, slotBtn, ignored)
    flyout.widget:SyncIgnoredState(ignored)
  end)
end

--- @param slotBtn BlizzCharacterSlotItemButton
function o:OnSlotEnter(slotBtn)
  if InCombatLockdown() then return end
  local slotID = slotBtn:GetID()
  self.__hoverSlotID = slotID
  local flyout = flyoutsMap[slotID]; if not flyout then return end
  if not IsAltKeyDown() then return end
  
  if flyout.widget:IsExpanded() then return end
  
  flyout.widget:SetInteractionMode(true)
  flyout.widget:OpenPopup()
end

--- @param slotBtn BlizzCharacterSlotItemButton
function o:OnSlotLeave(slotBtn)
  if InCombatLockdown() then return end
  local slotID = slotBtn:GetID()
  local flyout = flyoutsMap[slotID]
  if not (IsAltKeyDown() and flyout) then return end
  
  C_Timer.After(0.081, function()
    if self.__hoverSlotID ~= slotID then return end
    if not slotBtn:IsMouseOver()
            and not flyout:IsMouseOver()
            and not flyout.Flyout:IsMouseOver() then
      if ns.gears:IsShown() then return end
      flyout.widget:ClosePopup(false, false)
    end
  end)
end

function o:CreateSlotFlyouts()
  local esfm = Gears_EquipmentSlotFlyoutMixin
  
  if not self.__tooltipHooked then
    self.__tooltipHooked = true
    GameTooltip:HookScript("OnTooltipSetItem", function(tt)
      local owner = tt:GetOwner(); if not owner then return end
      if IsAltKeyDown() and owner.__Gears_flyout then tt:Hide() end
    end)
  end

  cfu:ForEachEquipmentSlot(function(s, btn, po)
    local flyout = esfm:Create(s, btn)
    flyoutsMap[flyout:GetID()] = flyout
    self:HookScript(btn, 'OnEnter', 'OnSlotEnter')
    self:HookScript(btn, 'OnLeave', 'OnSlotLeave')
  end)
end

--- @param enable boolean
function o:EnableEquipmentSlots(enable)
  if enable then return self:ShowFlyouts() end
  self:HideFlyouts()
end

function o:ShowFlyouts()
  self:ForEachFlyouts(function(flyout)
    flyout.widget:ShowSlotGroup()
  end)
end

function o:HideFlyouts()
  if ns.gears:HasSelection() and ns.gears:IsShown() then return end
  self:ForEachFlyouts(function(flyout)
    flyout.widget:ClosePopup(true)
  end)
end

--- This method doesn't care about equipment set IDs
--- @param callbackFn fun(flyout:EquipmentSlotFlyout, slotBtn:BlizzCharacterSlotItemButton, ignored:boolean) : void | "'function(slotFlyout, slotBtn, ignored) end'"
--- @param filterFn fun(flyout:EquipmentSlotFlyout) : boolean | "'function(flyout) return true end'"
function o:ForEachFlyouts(callbackFn, filterFn)
  if Tbl_IsEmpty(flyoutsMap) or not callbackFn then return end
  
  local filter = filterFn or ns.TRUE
  for _, flyout in pairs(flyoutsMap) do
    if filter(flyout) then callbackFn(flyout) end
  end
end

--- Slots by EquipmentSetID
--- @param equipSetID EquipSetID
--- @param callbackFn fun(slotFlyout:EquipmentSlotFlyout, slotBtn:BlizzCharacterSlotItemButton, ignored:boolean) : void | "'function(slotFlyout, slotBtn, ignored) end'"
function o:ForEachEquipSetSlots(equipSetID, callbackFn)
  if not (callbackFn) then return end
  
  local ignoredSlots = C_GetIgnoredSlots(equipSetID)
  
  for _, slotFlyout in pairs(flyoutsMap) do
    local slotID = slotFlyout:GetID()
    local ignored = ignoredSlots and ignoredSlots[slotID]
    callbackFn(slotFlyout, slotFlyout.widget.charSlotButton, ignored)
  end
end

--- Slots by EquipmentSetID
--- @param equipSetID EquipSetID
--- @param callbackFn fun(slotFlyout:EquipmentSlotFlyout, slotBtn:BlizzCharacterSlotItemButton) : void | "'function(slotFlyout, slotBtn) end'"
function o:ForEachEquipSetIgnoredSlots(equipSetID, callbackFn)
  self:ForEachEquipSetSlots(equipSetID, function(slotFlyout, slotBtn, ignored)
    if ignored and slotFlyout then callbackFn(slotFlyout, slotBtn) end
  end)
end

--[[-------------------------------------------------------------------
Event Handlers
---------------------------------------------------------------------]]
function o:OnEnterCombat()
  local btn = Gears_ToggleButton
  if not ns.gears:IsPaperDollFrameVisible() then return end
  if not btn:IsChecked() then self:HideFlyouts(); return end
  btn:Click()
end

--[[-------------------------------------------------------------------
Callbacks
---------------------------------------------------------------------]]
o:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnEnterCombat')
o:RegisterMessage(ns:msg('EquipmentSetSelected'), 'OnEquipmentSetSelected')
