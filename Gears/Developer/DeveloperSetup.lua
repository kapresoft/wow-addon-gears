--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local sformat, upper, date = string.format, string.upper, date

--- @type Namespace
local ns = select(2, ...)
ns.settings.developer = true

local libName = 'DeveloperSetup'
local Str_IsBlank = ns.O.String.IsBlank

--[[-----------------------------------------------------------------------------
Base Tracer
-------------------------------------------------------------------------------]]
local primaryC = ns:ColorFn(ns.colorDef.primary)

function ns.tr(prefix, ...)
  local et = EventTrace; if not (et and et.LogEvent) then return end
  local c1, logNamePlain = primaryC, ns.logName
  local n = c1(logNamePlain)
  if not Str_IsBlank(prefix) then n = n .. '::' .. prefix end
  et:LogEvent(n, ...)
end

--[[-----------------------------------------------------------------------------
External Dependencies
-------------------------------------------------------------------------------]]
--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
local RELOAD_CONFIRMATION_DIALOG = 'GEARS_RELOAD_CONFIRMATION_DIALOG'
--- Usage: StaticPopup_Show(RELOAD_CONFIRMATION_DIALOG)
StaticPopupDialogs[RELOAD_CONFIRMATION_DIALOG] = {
    text = strupper(ns.addon) .. " dev mode requires DevSuite.\nA UI restart is needed to enable it.\n\nRestart now?",
    button1 = OKAY, button2 = CANCEL,
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = ReloadUI
}

local function LoadDevSuite()
  --- @type AceAddon
  local ds = DevSuite

  if type(ds) == 'table' and type(ds.IsEnabled) == 'function' then
    local dsEnabled = ds:IsEnabled()
    C_Timer.After(1, function()
      ns.tr(libName, ('%s is available'):format(ds:GetName()), 'enabled=', dsEnabled)
    end)
    if dsEnabled then return end
  end

  local AU = ns:AddonUtil()
  assert(type(AU) == 'table', 'Missing dependency: Kapresoft-AddonUtil-2-0')
  local DevSuite_AddOn = 'DevSuite'
  local devSuiteEnabled = AU:IsAddOnEnabled(DevSuite_AddOn)

  if not devSuiteEnabled then
    AU:EnableAddOnForCharacter(DevSuite_AddOn)
    devSuiteEnabled = AU:IsAddOnEnabled(DevSuite_AddOn)
    C_Timer.After(0.1, function() StaticPopup_Show(RELOAD_CONFIRMATION_DIALOG) end)
  end
  C_Timer.After(1, function() ns.tr(libName, 'DevSuite is enabled=', devSuiteEnabled == true) end)
end; LoadDevSuite()

--[[-----------------------------------------------------------------------------
Log Setup
-------------------------------------------------------------------------------]]
--- Creates a print function
--- ### Example:
--- ```
--- local pr = traceFn3('Util')
--- pr('hello world)  -- prints to console
--- ```
--- @param moduleName Name
local function printerFn(moduleName)
  local printer = ns.printer
  if type(moduleName) ~= 'string' then return printer end
  local m = strtrim(moduleName)
  if Str_IsBlank(m) then return printer end
  return printer:WithSubPrefix(m)
end

--- @param prefix string|any
--- @return Gears_TraceFn
local function traceFn(prefix)
  return function(...) local trfn = ns.tr; return trfn(prefix, ...) end
end

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]
do
  local h = ns.logHolder
  h.printer = printerFn
  h.tracer = traceFn
end

