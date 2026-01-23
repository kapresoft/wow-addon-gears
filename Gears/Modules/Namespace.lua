--[[-----------------------------------------------------------------------------
Type: Namespace
-------------------------------------------------------------------------------]]
--- @class Namespace
--- @field private eventTraceName string
--- @field private xml table
--- @field p LibPrettyPrint_Printer The base printer
--- @type string

--[[-------------------------------------------------------------------
Start
---------------------------------------------------------------------]]
local addon
--- @type Namespace
local ns
addon, ns = ...; ns.addon = addon; GEARS_NS = ns


--- Used in XML files to hook frame events: OnLoad and OnEvent
--- Example: <OnLoad>GEARS_XML:[TypeName]_OnLoad(self)</OnLoad>
ns.xml = {}; GEARS_XML = ns.xml

--- @type NamespaceObjects
local O = ns.O or {}; ns.O = O

--[[-----------------------------------------------------------------------------
Type: Settings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class LibIconPickerSettings
--- @field developer boolean if true: enables developer mode
local settings = { developer = false }

--- @return boolean
function ns:IsDev() return ns.settings.developer == true end

--[[-------------------------------------------------------------------
Logger Methods
---------------------------------------------------------------------]]
local function predicateFn() return ns:IsDev() end
do
  ns.fmt     = LibPrettyPrint:Formatter({
    show_all = true, depth_limit = 3
  })
  ns.printer = LibPrettyPrint:Printer({
    prefix = ns.addon, prefix_color = '132CF2', sub_prefix_color = '9CFF9C',
    formatter = ns.fmt
  }, predicateFn)

  --- @param moduleName Name
  --- @return LibPrettyPrint_Printer
  function ns:Log(moduleName)
    return self.printer:WithSubPrefix(moduleName)
  end
end

local p  = ns:Log('Namespace')
print('xxx p:', p)

--[[-----------------------------------------------------------------------------
NamespaceObjects
-------------------------------------------------------------------------------]]
--- @param o NamespaceObjects
local function NSO(o)

end

--[[-----------------------------------------------------------------------------
Namespace: Methods
-------------------------------------------------------------------------------]]
do
  ns.eventTraceName = 'GEARS'
  ns.sformat        = string.format
  ns.settings       = settings
  ns.eventBasename  = string.upper(ns.addon)
  ns.O              = {}; NSO(ns.O)

  function ns:t(prefix, ...) return self:evt():t(prefix, ...) end
  function ns:tf(prefix, ...) return self:evt():t(prefix, ...) end
  function ns:td(...) return self:evt():t(...) end
  function ns:tdf(...) return self:evt():t(...) end

  --- @return EventTracePrinter
  function ns:evt()
    if not self.eventTracer then
      self.eventTracer = ns.O.EventTracePrinter:New(ns.addon, predicateFn)
    end
    return self.eventTracer
  end

  function ns:K() return ns.Kapresoft_LibUtil end

end

C_Timer.After(2, function()
  ns:td('hello', 'there')
  ns:tdf('hello', 'there')
end)
