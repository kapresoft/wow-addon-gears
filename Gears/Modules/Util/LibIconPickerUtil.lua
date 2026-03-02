--- @type Namespace
local ns = select(2, ...)
local L = ns:GetLocale()

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local iconPickerAddOn = 'LibIconPicker'
local LoadAddOn   = C_AddOns.LoadAddOn or LoadAddOn
local EnableAddOn = C_AddOns.EnableAddOn or EnableAddOn
local OKAY = OKAY

--[[-------------------------------------------------------------------
New Library
---------------------------------------------------------------------]]
--- @class LibIconPickerUtil
local S = {}; ns.O.LibIconPickerUtil = S
local p = ns:log('LibIconPickerUtil')
--- @type LibIconPickerUtil
local o = S;

StaticPopupDialogs["LibIconPicker_Missing"] = {
  text = L['LibIconPicker Missing'],
  button1 = OKAY, timeout = 0, whileDead = 1, hideOnEscape = 1,
}
--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
--- Get LibIconPicker instance
--- The global var `LibIconPicker` is available if the addon is already loaded.
--- @param callbackFn fun(lip:LibIconPicker) | "function(lip) end"
--- @return LibIconPicker
function o:Get(callbackFn)
  -- if embedded
  local lip = LibIconPicker
  if lip then callbackFn(lip); return end
  
  -- if on demand
  EnableAddOn(iconPickerAddOn, UnitName('player'))
  local loaded, reason = LoadAddOn(iconPickerAddOn)
  if loaded == true then callbackFn(lip); return end
  
  p(('LoadAddOn(%q) failed to load with reason=%q'):format(iconPickerAddOn, reason))
  StaticPopup_Show("LibIconPicker_Missing")
end



