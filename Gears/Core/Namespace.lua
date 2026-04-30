--[[-------------------------------------------------------------------
Type: NamespaceObjects
---------------------------------------------------------------------]]
--- @class NamespaceObjects
--- @field GameVersion GameVersion
--- @field LibIconPickerUtil LibIconPickerUtil
--- @field CharacterFrameUtil CharacterFrameUtil
--- @field DatabaseSchema DatabaseSchema
--- @field EquipmentSlotFlyoutManager EquipmentSlotFlyoutManager
--- @field InventoryUtil InventoryUtil
--- @field ItemUtil ItemUtil
--- @field AceEvent AceEvent-3.0
--- @field AceBucket AceBucket-3.0
--- @field AceHook AceHook-3.0
--- @field AceLocale AceLocale-3.0
--- @field AceAddon AceAddon-3.0
--- @field AceDB AceDB-3.0
--- @field Table Kapresoft-Table-2-0
--- @field String Kapresoft-String-2-0

--[[-------------------------------------------------------------------
Aliases
---------------------------------------------------------------------]]
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
local GameVersionMixin = LibStub('Kapresoft-GameVersionMixin-2-0')
local AceLib = LibStub('Kapresoft-AceLib-2-0')

--- @type string
local addon

--- @class Namespace : Kapresoft-GameVersionMixin-2-0, Kapresoft-AceLib-2-0
--- @field __db DatabaseObj
--- @field O NamespaceObjects
--- @field gameVersion GameVersion
--- @field EvenTracePrinter EventTracePrinter
--- @field tracer EventTracerObj
--- @field private printer LibPrettyPrint_Printer
--- @field private logBuilder Gears_LogBuilderFn
--- @field p LibPrettyPrint_Printer The base printer
--- @field gears Gears_MainFrame
--- @field toggleButton ToggleButton
local ns

addon, ns = ...

Mixin(ns, GameVersionMixin, AceLib); ns.addon = addon; GEARS_NS = ns
ns.O = ns.O or {}

--- Matches *.toc SavedVariables definition
local DB_NAME = 'GEARS_DB'

--- @type NamespaceObjects
local O = ns.O or {}; ns.O = O

--[[-----------------------------------------------------------------------------
Type: Settings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class Gears_Settings
--- @field developer boolean if true: enables developer mode
--- @field enableTraceUI boolean if true: shows Blizz EventTrace UI on load
local settings = { developer = false, enableTraceUI = false }; ns.settings = settings


--- @return boolean
function ns:IsDev() return ns.settings.developer == true end

--[[-------------------------------------------------------------------
Logger Methods
---------------------------------------------------------------------]]
local function predicateFn() return ns:IsDev() end
do
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
    assert(type(printer) == 'table', '__CreateLogBuilder(printer): {printer} is missing')
    
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
NamespaceObjects: Ace-3.0
-------------------------------------------------------------------------------]]
do
  local obj = ns.O
  obj.AceEvent = LibStub('AceEvent-3.0')
  obj.AceBucket = LibStub('AceBucket-3.0')
  obj.AceHook = LibStub('AceHook-3.0')
  obj.AceLocale = LibStub('AceLocale-3.0')
  obj.AceAddon = LibStub('AceAddon-3.0')
  obj.AceDB = LibStub('AceDB-3.0')

end

--[[-------------------------------------------------------------------
Kapresoft Modules
---------------------------------------------------------------------]]
do
  local obj = ns.O
  obj.Table = LibStub('Kapresoft-Table-2-0')
  obj.String = LibStub('Kapresoft-String-2-0')
end

--[[-----------------------------------------------------------------------------
Namespace: Methods
-------------------------------------------------------------------------------]]
local function Namespace_Methods()
  
  local AceLocaleUtil = LibStub('Kapresoft-AceLocaleUtil-2-0')
  
  local function IsNilOrBlank(v) return v == nil or strtrim(v) == "" end
  
  ns.sformat        = string.format
  ns.settings       = settings
  ns.MAX_CHARS_SET_NAME = 32
  
  function ns.TRUE() return true end
  
  --- @param prefix string|nil
  --- @return Gears_TraceFn @Printer function that outputs plain values to Blizzard Trace UI (like print)
  function ns:traceFn(prefix)
    if not self.tracer then return function() end end
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
    assert(type(name) == 'string', 'ns:register(name, obj): {name} should be a string')
    assertsafe(type(obj) == 'table', 'ns:register(name, obj): {obj} should be a obj/table but was: %s', type(obj))
    O[name] = obj
    return obj
  end

  --- ### Usage:
  --- ```
  --- -- automatic casting provied there is an
  --- -- object with @class EquipmentSlotFlyoutManager
  --- local ESM = ns:obj('EquipmentSlotFlyoutManager')
  --- ```
  --- @generic T
  --- @param lib `T`
  --- @return table|T library
  function ns:obj(lib) return ns.O[lib] end

  --- @param mainFrame Gears_MainFrame
  function ns:RegisterMainFrame(mainFrame) ns.gears = mainFrame end
  
  --- @param rgbHex RGBHex|nil    @Optional
  --- @return fun(key:string) : string The color formatted key
  function ns:colorFn(rgbHex)
    return function(text)
      local c = CreateColorFromRGBHexString(rgbHex)
      assertsafe(type(c) == 'table', 'colorFn(rgbHex): Could not creat color from {rgbHex}: %s', tostring(rgbHex))
      return c:WrapTextInColorCode(text)
    end
  end
  
  function ns:msg(msgName)
    assert(not IsNilOrBlank(msgName), 'Message name is required.')
    return ('%s::%s'):format(ns.addon, msgName)
  end
  
  --- @return table<string, string>
  function ns:GetLocale() return AceLocaleUtil:GetLocale(ns.addon, ns:IsDev()) or {} end
  
  --- @return EventTracerObj
  function ns:NewTracer() return self.EvenTracePrinter:New(self.addon, predicateFn) end
  
  
  --- >Safe wrapper for PlaySound.
  --- >Returns two results: willPlay:boolean, soundHandle:boolean
  --- [Documentation](https://warcraft.wiki.gg/wiki/API_PlaySound)
  --- ##### Example:
  --- ```
  --- local willPlay, soundHandle = PlaySound(...)
  --- ```
  --- @param soundKitID number
  --- @param channel SoundChannel?        @The default is 'Effects' or 'SFX' (both are same)
  --- @param forceNoDuplicates boolean?
  --- @param runFinishCallback boolean?
  --- @return boolean?, number?
  function ns:PlaySound(soundKitID, channel, forceNoDuplicates, runFinishCallback)
    if not soundKitID then return end
    return PlaySound(soundKitID, channel, forceNoDuplicates, runFinishCallback)
  end

  --- @boolean
  function ns:HasBlizzEquipmentManager()
    return PaperDollFrame and PaperDollSidebarTab1
            and PaperDollFrame.EquipmentManagerPane
  end
  
  --- @return EquipmentSlotFlyoutManager
  function ns:esfm() return ns.O.EquipmentSlotFlyoutManager end
  
  --[[--------------------------------------------------------
  Database
  ------------------------------------------------------------]]
  function ns:InitDatabase() self.__db = ns.O.AceDB:New(DB_NAME, ns.O.DatabaseSchema:GetDefaultDatabase()) end
  --- @return DatabaseObj
  function ns:db() return self.__db end
  --- @return GlobalConfig
  function ns:g() return self:db().global end
  --- @return ProfileConfig
  function ns:p() return self:db().profile end

end; Namespace_Methods()


--[[-------------------------------------------------------------------
Init Tracer
---------------------------------------------------------------------]]
--- @param callbackFn fun() : void
function ns:InitTracer(callbackFn)
  if not predicateFn() then return end
  
  self.tracer = self:NewTracer()
  if not settings.enableTraceUI then self.tracer:HideUI()
  else self.tracer:ShowUI() end
  
  callbackFn()
end
