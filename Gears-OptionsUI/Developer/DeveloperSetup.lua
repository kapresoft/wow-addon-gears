--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Gears_OptionsUI_Namespace
local ns = select(2, ...)

--- @type LibTraceKit-1.0
local LibTraceKit = LibStub('LibTraceKit-1.0')
assertsafe(type(LibTraceKit) ~= nil, 'Failed to reference LibTraceKit-1.0')

local libName = 'DeveloperSetup'
local cns, O = ns:cns()
local Str_IsBlank = O.String.IsBlank
local TRACE_DELIM = '_'

--[[-----------------------------------------------------------------------------
Base Tracer
-------------------------------------------------------------------------------]]
--- @param prefix string|any
--- @return Gears_TraceFn
local function traceFn(prefix)
  return LibTraceKit:New(ns.addon, prefix):WithDelimiter(TRACE_DELIM) --[[@as Gears_TraceFn ]]
end; local t = traceFn(libName)

--- Creates a print function
--- ### Example:
--- ```
--- local pr = printFn('DeveloperSetup')
--- pr('hello world)  -- prints to console {{Gears-OptionsUI::DeveloperSetup}} hello world
--- ```
--- @param moduleName Name
local function printerFn(moduleName)
  local printer = ns.printer
  if type(moduleName) ~= 'string' then return printer end
  local m = strtrim(moduleName)
  if Str_IsBlank(m) then return printer end
  return printer:WithSubPrefix(m)
end

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]
do
  local h = ns.logHolder
  h.printer = printerFn
  h.tracer = traceFn
end
