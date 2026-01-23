--[[-----------------------------------------------------------------------------
Type: Namespace
-------------------------------------------------------------------------------]]
--- @class Namespace
--- @field private eventTraceName string
--- @field private xml table
--- @field gameVersion GameVersion
--- @field tracer EventTracePrinter
--- @field p LibPrettyPrint_Printer The base printer
--- @type string

--[[-------------------------------------------------------------------
Type: NamespaceObjects
---------------------------------------------------------------------]]
--- @class NamespaceObjects
--- @field GameVersion GameVersion

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
do
  local function predicateFn() return ns:IsDev() end
  ns.fmt     = LibPrettyPrint:Formatter({
    show_all = true, depth_limit = 3
  })
  ns.printer = LibPrettyPrint:Printer({
    prefix = ns.addon, prefix_color = '132CF2', sub_prefix_color = '9CFF9C',
    formatter = ns.fmt
  }, predicateFn)

  --- @param tracer EventTracePrinter
  function ns:RegisterTracer(tracer) self.tracer = tracer:New(ns.addon, predicateFn) end
  function ns:MixinGameVersion(gameVersion) Mixin(self, gameVersion) end

  --- @param moduleName Name
  --- @return LibPrettyPrint_Printer
  function ns:Log(moduleName) return self.printer:WithSubPrefix(moduleName) end
end

local p  = ns:Log('Namespace')

--[[-----------------------------------------------------------------------------
Namespace: Methods
-------------------------------------------------------------------------------]]
do
  ns.eventTraceName = 'GEARS'
  ns.sformat        = string.format
  ns.settings       = settings
  ns.eventBasename  = string.upper(ns.addon)
  ns.O              = {}

  function ns:t(prefix, ...) return self.tracer(prefix, ...) end
  function ns:tf(prefix, ...) return self.tracer:tf(prefix, ...) end
  function ns:td(prefix, ...) return self.tracer:td(...) end
  function ns:tdf(prefix, ...) return self.tracer:tdf(...) end

  --- @param name Name The module name; see NamespaceObjects
  --- @param obj any The namespace object
  function ns:register(name, obj)
    assert(name, 'Module name required')
    assert(obj, ('Module instance is invalid. val=%s'):format(tostring(obj)))
    O[name] = obj
    return obj
  end

end
