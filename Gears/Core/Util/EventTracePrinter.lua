local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn or LoadAddOn
local EVENT_TRACE_ADDON = 'Blizzard_EventTrace'
local upperc = string.upper
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns      = select(2, ...)

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]
--- @class EventTracePrinter
local S = {}; ns.O.EventTracePrinter = S

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
--- @type EventTracePrinter
local o = S

--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
function o:New(addon, predicateFn)
    assert(addon, "The param addon is required.")

    ----- @type EventTraceInstance
    --local e       = EventTrace
    --local evtName = ('%s_%s'):format(ns.eventBasename, upperc(name))
    --e:LogEvent(evtName, ...)

    return CreateAndInitFromMixin(o, addon, predicateFn)
end

local DEVTOOLS_TYPE_COLOR="|cff88ff88";

local EVENT_BASE_COLOR = CreateColorFromRGBHexString('88ff88')
local function cbase(text) return EVENT_BASE_COLOR:WrapTextInColorCode(text) end

--- @private
--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
function o:Init(addon, predicateFn)
    self.logName     = addon
    self.eventBase   = upperc(cbase(addon))
    self.predicateFn = predicateFn
    self.evt         = self:LoadEventTrace()
end

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
--- @return EventTraceInstance
function o:LoadEventTrace()
    local addOnName = EVENT_TRACE_ADDON
    if IsAddOnLoaded(addOnName) then return EventTrace end

    local success, reason = LoadAddOn(addOnName)
    if not success then
        return print(('%s:: Failed to load [%s], reason=%s'):format(
                self.logName, addOnName, reason))
    end
    assert(EventTrace, ('%s:: Failed to load [%s].'):format(self.logName, addOnName))
    --EventTrace:Hide()
    return EventTrace
end

--- @param prefix Name|nil
function o:_EventName(prefix)
    if prefix == nil then return self.eventBase end
    return ("%s::%s"):format(self.eventBase, upperc(prefix))
end
