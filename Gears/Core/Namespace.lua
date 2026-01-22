local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local LoadAddOn = C_AddOns.LoadAddOn or LoadAddOn
local EVENT_TRACE_ADDON = 'Blizzard_EventTrace'

--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @class Namespace : CoreNamespace
--- @field private addonLogName string
--- @field private xml table
local ns = select(2, ...); GEARS_NS = ns
--local p = ns:Log('Namespace')
--C_Timer.After(1, function()
--    p('hello','there')
--end)

local K = ns.Kapresoft_LibUtil
K:MixinWithDefExc(ns, K.Objects.CoreNamespaceMixin, K.Objects.NamespaceAceLibraryMixin)
if not pformat then pformat = K.pformat; pfxformat = pformat end

ns.addonLogName   = 'GEARS'

--- Used in XML files to hook frame events: OnLoad and OnEvent
--- Example: <OnLoad>GEARS_XML:[TypeName]_OnLoad(self)</OnLoad>
ns.xml = {}; GEARS_XML = ns.xml

--- @type NamespaceObjects
local O = ns.O or {}; ns.O = O

--- @type Kapresoft_LibUtil_ColorDefinition
ns.consoleColors = {
    primary   = '2db9fb',
    secondary = 'fbeb2d',
    tertiary  = 'ffffff',
}
ns.ch = ns:NewConsoleHelper(ns.consoleColors)

--[[-----------------------------------------------------------------------------
Type: Settings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class LibIconPickerSettings
--- @field developer boolean if true: enables developer mode
local settings = { developer = false }

--[[-----------------------------------------------------------------------------
NamespaceObjects
-------------------------------------------------------------------------------]]
--- @param o NamespaceObjects
local function NSO(o)

end

--[[-----------------------------------------------------------------------------
Namespace: Methods
-------------------------------------------------------------------------------]]
--- @param n Namespace
local function NamespaceMethods(n)

    n.sformat = string.format
    n.fmt = LibPrettyPrint:Formatter()
    n.settings = settings
    n.eventBasename = string.upper(ns.addon)
    n.O = {}; NSO(ns.O)

    function ns:t(prefix, ...) return self:evt():t(prefix, ...) end
    function ns:tf(prefix, ...) return self:evt():t(prefix, ...) end
    function ns:td(...) return self:evt():t(...) end
    function ns:tdf(...) return self:evt():t(...) end

    function ns:evt()
        if not self.eventTracer then
            self.eventTracer = ns.O.EventTracePrinter:New(ns.addon, function() return self:IsDev() end)
        end
        return self.eventTracer
    end

    function ns:K() return ns.Kapresoft_LibUtil end

    --- @return boolean
    function n:IsDev() return ns.settings.developer == true end

--[[    --- @param name Name
    function n.evt(name, ...)
        if not n:IsDev() then return end
        local addOnName = EVENT_TRACE_ADDON
        if not IsAddOnLoaded(addOnName) then
            local success, reason = LoadAddOn(addOnName)
            if not success then
                return print(('%s:: Failed to load[%s], reason=%s'):format(
                             ns.addon, addOnName, reason))
            end
            --EventTrace:Hide()
        end

        --- @type EventTraceInstance
        local e       = EventTrace
        local evtName = ('%s_%s'):format(ns.eventBasename, string.upper(name))
        e:LogEvent(evtName, ...)

    end]]

end; NamespaceMethods(ns)

