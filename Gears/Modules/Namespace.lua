--[[-----------------------------------------------------------------------------
Type: Namespace
-------------------------------------------------------------------------------]]
--- @class NamespaceImpl
--- @field xml table
--- @field O NamespaceObjects
--- @field gameVersion GameVersion
--- @field tracer EventTracePrinter
--- @field private printer LibPrettyPrint_Printer
--- @field private logBuilder Gears_LogBuilderFn
--- @field p LibPrettyPrint_Printer The base printer
--- @field gears Gears_MainFrame
--- @field toggleButton ToggleButton

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
--- @alias Gears_TraceFn fun(...: any) : void @Printer function that outputs plain values to Blizzard Trace UI (like print)
--- @alias Gears_TraceFnFormatted fun(...: any) : void @Printer function that outputs formatted values to Blizzard Trace UI (like print)
--- @alias Gears_LogBuilderFn fun(moduleName:string) : LibPrettyPrint_PrintFn, LibPrettyPrint_PrintFn, Gears_TraceFn, Gears_TraceFnFormatted

--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local strtrim = strtrim

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type string
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
--- @class Gears_Settings
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
  local function DelayedCall(delay, fn, ...)
    assert(type(delay) == 'number' and delay > 0)
    return function(...)
      local args = { ... }
      C_Timer.After(delay, function() fn(unpack(args)) end)
    end
  end
  
  ns.fmt     = LibPrettyPrint:Formatter({
    show_all = true, depth_limit = 3
  }); if not fmt then fmt = ns.fmt end
  
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
  --- @return LibPrettyPrint_Printer, LibPrettyPrint_PrintFn, Gears_TraceFn, Gears_TraceFnFormatted
  function ns:log(moduleName)
    if not self.logBuilder then self.logBuilder = self:__CreateLogBuilder(self.printer) end
    return self.logBuilder(moduleName)
  end
  
  --- @protected
  --- @param printer LibPrettyPrint_Printer
  --- @return Gears_LogBuilderFn
  function ns:__CreateLogBuilder(printer)
    assert(printer, 'Printer is required.')
    
    --- @param moduleName Name
    local function builderFn(moduleName)
      local m = moduleName
      local pr = printer
      if type(m) == 'string' then m = strtrim(m)
      else m = nil end
      
      if m and #m > 0 then pr = printer:WithSubPrefix(m) end
      
      local printerDelayed = DelayedCall(1, pr)
      local tracer1 = self:traceFn(m)
      local tracer2 = self:traceFnWithFormatting(m)
      return pr, printerDelayed, tracer1, tracer2
    end
    
    return builderFn
  end
end

--[[-----------------------------------------------------------------------------
Namespace: Methods
-------------------------------------------------------------------------------]]
do
  --- @type AceEvent_3_0
  local AceEvent = LibStub("AceEvent-3.0")
  --- @type AceBucket_3_0
  local AceBucket = LibStub("AceBucket-3.0")
  --- @type AceLocale_3_0
  local AceLocale = LibStub('AceLocale-3.0')
  --- @type Kapresoft_AceLocaleUtil_2_0
  local AceLocaleUtil = LibStub('Kapresoft-AceLocaleUtil-2.0')
  
  local function IsNilOrBlank(v) return v == nil or strtrim(v) == "" end
  
  ns.sformat        = string.format
  ns.settings       = settings
  ns.O              = {}
  ns.MAX_CHARS_SET_NAME = 32

  --- @param prefix string|nil
  --- @return Gears_TraceFn @Printer function that outputs plain values to Blizzard Trace UI (like print)
  function ns:traceFn(prefix)
    if not self.tracer then return function()  end end
    if type(prefix) ~= 'string' then
      return function(...) return self.tracer:td(...) end
    end
    return function(...) return self.tracer:t(strtrim(prefix), ...) end
  end
  --- @param prefix string
  --- @return Gears_TraceFnFormatted @Printer function that outputs formatted values to Blizzard Trace UI (like print)
  function ns:traceFnWithFormatting(prefix)
    if not self.tracer then return function()  end end
    if type(prefix) ~= 'string' then
      return function(...) return self.tracer:tdf(...) end
    end
    return function(...) return self.tracer:tf(strtrim(prefix), ...) end
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
  
  --- @return AceLocale_3_0
  function ns:AceLocale() return AceLocale end
  
  --- @return table<string, string>
  function ns:GetLocale() return AceLocaleUtil:GetLocale(ns.addon, ns:IsDev()) end
  
  --- >Safe wrapper for PlaySound.
  --- >Returns two results: willPlay:boolean, soundHandle:boolean
  --- [Documentation](https://warcraft.wiki.gg/wiki/API_PlaySound)
  --- ##### Example:
  --- ```
  --- local willPlay, soundHandle = PlaySound(...)
  --- ```
  --- @param soundKitID number
  --- @param channel SoundChannel|Optional The default is 'Effects' or 'SFX' (both are same)
  --- @param forceNoDuplicates boolean|Optional
  --- @param runFinishCallback boolean|Optional
  --- @return boolean, number
  function ns:PlaySound(soundKitID, channel, forceNoDuplicates, runFinishCallback)
    if not soundKitID then return end
    return PlaySound(soundKitID, channel, forceNoDuplicates, runFinishCallback)
  end
  
end

