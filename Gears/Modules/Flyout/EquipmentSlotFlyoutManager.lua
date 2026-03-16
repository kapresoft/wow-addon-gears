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
--- @class EquipmentSlotFlyoutManager : AceEvent_3_0
local S = ns:AceEvent(); ns.O.EquipmentSlotFlyoutManager = S
local p, pd, t, tf = ns:log(libName)

--- @type table<SlotID, EquipmentSlotFlyout>
local flyoutsMap = {}

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFactory (Methods)
-------------------------------------------------------------------------------]]
--- @type EquipmentSlotFlyoutManager
local o = S

--- @param msg string
--- @param equipSetInfo EquipmentSetInfo
function o:OnEquipmentSetSelected(msg, equipSetInfo)
  ns.toggleButton:EnableEquipmentSlots(true)
  C_ClearIgnoredSlotsForSave()
  self:ForEachEquipSetSlots(equipSetInfo.id, function(flyout, slotBtn, ignored)
    flyout.widget:SyncIgnoredState(ignored)
  end)
end

function o:CreateSlotFlyouts()
  local esfm = Gears_EquipmentSlotFlyoutMixin
  cfu:ForEachEquipmentSlot(function(s, btn, po)
    local flyout = esfm:Create(s, btn)
    flyoutsMap[flyout:GetID()] = flyout
  end)
end

--- @param enable boolean
function o:SetFlyoutState(enable)
  if enable then return self:ShowFlyouts() end
  self:HideFlyouts()
end

function o:ShowFlyouts()
  self:ForEachFlyouts(function(flyout)
    local method = flyout.widget:IsCharacterSlotShown() and 'Show' or 'Hide'
    flyout[method](flyout)
  end)
end

function o:HideFlyouts()
  self:ForEachFlyouts(function(flyout) flyout:Hide() end)
end

-- Some character equipment slots may be hidden (class/spec dependent).
-- Hide the flyout when its corresponding slot is not visible.
function o:UpdateVisibility()
  self:ForEachFlyouts(function(flyout) flyout:Hide() end,
          function(f) return not f.widget:IsCharacterSlotShown() end)
end

--- This method doesn't care about equipment set IDs
--- @param callbackFn fun(flyout:EquipmentSlotFlyout, slotBtn:BlizzCharacterSlotItemButton, ignored:boolean) : void | "'function(slotFlyout, slotBtn, ignored) end'"
--- @param filterFn fun(flyout:EquipmentSlotFlyout) : boolean | "function(flyout) return true end"
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
  
  for _, slotFlyout in ipairs(flyoutsMap) do
    local slotID = slotFlyout:GetID()
    local ignored = ignoredSlots and ignoredSlots[slotID]
    callbackFn(slotFlyout, slotFlyout.widget.slotButton, ignored)
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
RegisterMessage
---------------------------------------------------------------------]]
o:RegisterMessage(ns:msg('EquipmentSetSelected'), 'OnEquipmentSetSelected')

