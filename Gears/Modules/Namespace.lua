--[[-----------------------------------------------------------------------------
Type: Namespace
-------------------------------------------------------------------------------]]
--- @class NamespaceImpl
--- @field xml table
--- @field gameVersion GameVersion
--- @field tracer EventTracePrinter
--- @field p LibPrettyPrint_Printer The base printer
--- @field gears Gears_MainFrame
--- @field toggleButton ToggleButton
--- @type string

--[[-------------------------------------------------------------------
Type: NamespaceObjects
---------------------------------------------------------------------]]
--- @class NamespaceObjects
--- @field GameVersion GameVersion
--- @field LibIconPickerUtil LibIconPickerUtil
--- @field CharacterFrameUtil CharacterFrameUtil

--[[-------------------------------------------------------------------
Aliases
---------------------------------------------------------------------]]
--- @alias Namespace NamespaceImpl | GameVersionMixin

--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local strtrim = strtrim

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local addon
--- @type NamespaceImpl | Namespace
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
--- @field enableTraceUI boolean if true: shows Blizz EventTrace UI on load
local settings = { developer = false }; ns.settings = settings


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
    prefix = ns.addon, prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
    formatter = ns.fmt
  }, predicateFn)

  --- @param tracer EventTracePrinter
  function ns:RegisterTracer(tracer)
    self.tracer = tracer:New(ns.addon, predicateFn)
    if not (ns:IsDev() and settings.enableTraceUI) then
      self.tracer.evt:Hide()
    end
  end
  function ns:MixinGameVersion(gameVersion) Mixin(self, gameVersion) end
  --- @param moduleName Name
  --- @return LibPrettyPrint_Printer | LibPrettyPrint_PrintFn, fun(...), fun(...)
  function ns:log(moduleName)
    local printer = self.printer:WithSubPrefix(moduleName)
    local tracer1 = ns:traceFnWithFormatting(moduleName)
    local tracer2 = ns:traceFn(moduleName)
    return printer, tracer1, tracer2
  end
end

--[[-----------------------------------------------------------------------------
Namespace: Methods
-------------------------------------------------------------------------------]]
do
  --- @type AceEvent
  local AceEvent = LibStub("AceEvent-3.0")
  --- @type AceBucket
  local AceBucket = LibStub("AceBucket-3.0")
  
  local function IsNilOrBlank(v) return v == nil or strtrim(v) == "" end
  
  ns.sformat        = string.format
  ns.settings       = settings
  ns.O              = {}

  function ns:t(prefix, ...) return self.tracer(prefix, ...) end
  function ns:tf(prefix, ...) return self.tracer:tf(prefix, ...) end
  function ns:td(...) return self.tracer:td(...) end
  function ns:tdf(...) return self.tracer:tdf(...) end
  
  --- @param prefix string
  --- @return fun(...): any
  function ns:traceFn(prefix)
    return function(...) return self.tracer:t(prefix, ...) end
  end
  --- @param prefix string
  --- @return fun(...): any
  function ns:traceFnWithFormatting(prefix)
    return function(...) return self.tracer:tf(prefix, ...) end
  end

  --- @param name Name The module name; see NamespaceObjects
  --- @param obj any The namespace object
  function ns:register(name, obj)
    assert(name, 'Module name required')
    assert(obj, ('Module instance is invalid. val=%s'):format(tostring(obj)))
    O[name] = obj
    return obj
  end
  
  --- @param rgbHex RGBHex|nil    @Optional
  --- @return fun(key:string) : string The color formatted key
  function ns:colorFn(rgbHex)
    return function(text)
      local c = CreateColorFromRGBHexString(rgbHex)
      assert(c, ('Invalid RGBHex color: %s'):format(rgbHex))
      return c:WrapTextInColorCode(text)
    end
  end
  
  function ns:msg(msgName)
    assert(not IsNilOrBlank(msgName), 'Message name is required.')
    return ('%s::%s'):format(ns.addon, msgName)
  end
  
  --- @param targetObj any|nil An optional targetObj for embedding
  function ns:AceEvent(targetObj)
    if targetObj then return AceEvent:Embed(targetObj) end
    return AceEvent:Embed({})
  end
  
  --- @param targetObj any|nil An optional targetObj for embedding
  function ns:AceBucket(targetObj)
    if targetObj then return AceBucket:Embed(targetObj) end
    return AceBucket:Embed({})
  end
  
end

