--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local libName = 'LibIconPicker'
-- The old GetAddOnEnableState requires the second arg 'character'
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState or GetAddOnEnableState
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

--- temp locale
local L = {}
L['LibIconPicker Missing'] = 'This feature requires LibIconPicker.|nPlease make sure LibIconPicker is installed and enabled, then reload the UI.'

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
  if LibIconPicker then callbackFn(LibIconPicker); return end
  
  -- if on demand
  EnableAddOn(libName, UnitName('player'))
  local loaded, reason = LoadAddOn(libName)
  if loaded == true then callbackFn(LibIconPicker); return end
  
  p(('LoadAddOn(%q) failed to load with reason=%q'):format(libName, reason))
  StaticPopup_Show("LibIconPicker_Missing")
end



