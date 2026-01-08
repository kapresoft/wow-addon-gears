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

--- @type GlobalObjects
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
    n.settings = settings
    n.O = {}; NSO(ns.O)

    function ns:K() return ns.Kapresoft_LibUtil end

    --- @return boolean
    function n:IsDev() return ns.settings.developer == true end

end; NamespaceMethods(ns)

