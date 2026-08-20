--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local sformat, upper, date = string.format, string.upper, date

--- @type Namespace
local ns = select(2, ...)
ns.settings.developer = true

--- @type LibTraceKit-1.0
local LibTraceKit = LibStub('LibTraceKit-1.0')
assertsafe(type(LibTraceKit) ~= nil, 'Failed to reference LibTraceKit-1.0')

local libName = 'DeveloperSetup'
local Str_IsBlank = ns.O.String.IsBlank
local TRACE_DELIM = '_'

--[[-----------------------------------------------------------------------------
Base Tracer
-------------------------------------------------------------------------------]]
local primaryC = ns:ColorFn(ns.colorDef.primary)

--- @param prefix string|any
--- @return Gears_TraceFn
local function traceFn(prefix)
  return LibTraceKit:New(ns.addon, prefix) :WithDelimiter(TRACE_DELIM) --[[@as Gears_TraceFn ]]
end; local t = traceFn(libName)

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
      t(libName, ('%s is available'):format(ds:GetName()), 'enabled=', dsEnabled)
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
end; LoadDevSuite()

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]
do
  --- Creates a print function
  --- ### Example:
  --- ```
  --- local pr = printFn('DeveloperSetup')
  --- pr('hello world)  -- prints to console {{Gears::DeveloperSetup}} hello world
  --- ```
  --- @param moduleName Name
  local function printerFn(moduleName)
    local printer = ns.printer
    if type(moduleName) ~= 'string' then return printer end
    local m = strtrim(moduleName)
    if Str_IsBlank(m) then return printer end
    return printer:WithSubPrefix(m)
  end

  local h = ns.logHolder
  h.printer = printerFn
  h.tracer = traceFn
end

