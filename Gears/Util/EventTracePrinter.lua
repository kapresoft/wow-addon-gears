local IsAddOnLoaded     = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local LoadAddOn         = C_AddOns.LoadAddOn or LoadAddOn
local EVENT_TRACE_ADDON = 'Blizzard_EventTrace'
local upperc            = string.upper
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]

--- @class EventTracePrinter
local o = {}; ns.EvenTracePrinter = o
o.__index = o
o.__type = 'EventTracePrinter'

--- @param self EventTracePrinter
o.__call = function(self, ...) self:t(...) end

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]

--- @class EventTracerObj : EventTracePrinter

--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
--- @return EventTracePrinter
function o:New(addon, predicateFn)
  --- @type EventTracerObj
  local tracer = setmetatable({}, o)
  tracer:__Init(addon, predicateFn)
  return tracer
end

-- light green
local c_base = ns:colorFn('88ff88')

--- @private
--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
function o:__Init(addon, predicateFn)
  assert(type(addon) == 'string', "__Init(addon, predicateFn): {addon} should be a string")

  self.logName     = addon
  self.eventBase   = upperc(c_base(addon))
  self.predicateFn = predicateFn or function() return true  end
  self.evt         = self:LoadEventTrace()
  if self.evt then self.evt:SetClampedToScreen(true) end
end

function o:ShowUI() self.evt:Show() end

function o:HideUI() self.evt:Hide() end

--- Trace with default prefix as the addon name
--- @param ... any
function o:td(...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(), ...)
end

--- Trace with default prefix as the addon name
--- @param ... any
function o:tdf(...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(), ns.fmt(...))
end

--- This is the default trace function
--- @param prefix Name
--- @param ... any
function o:t(prefix, ...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(prefix), ...)
end

--- @param prefix Name
--- @param ... any
function o:tf(prefix, ...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(prefix), ns.fmt(...))
end

--- @private
--- @return EventTrace?
function o:LoadEventTrace()
  local addOnName = EVENT_TRACE_ADDON
  if IsAddOnLoaded(addOnName) then return EventTrace end

  local success, reason = LoadAddOn(addOnName)
  if not success then
    print(('%s:: Failed to load [%s], reason=%s'):format( self.logName, addOnName, reason))
    return nil
  end
  assert(EventTrace, ('%s:: Failed to load [%s].'):format(self.logName, addOnName))
  return EventTrace
end

--- @param prefix Name|nil
function o:_EventName(prefix)
  if prefix == nil then return self.eventBase end
  return ("%s::%s"):format(self.eventBase, upperc(prefix))
end

--[[-------------------------------------------------------------------
Initialize Tracer
---------------------------------------------------------------------]]
ns:InitTracer(function()
  if not ns:IsDev() then return end
  local _, _, t = ns:log('EventTracePrinter')
  t('InitTracer', 'ns.tracer=', ns.tracer)
end)
