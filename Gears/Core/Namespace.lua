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
--- @field private logHolder Gears_LogHolder
--- @field gears Gears_MainFrame
--- @field toggleButton ToggleButton
--- @field tr fun(prefix:string, ...:any)
--- @field colorDef Kapresoft-ColorDefinition-2-0
--- @field private logName Name @The prefix for all logs and traces
--- @field private printer LibPrettyPrint_Printer
local ns

addon, ns = ...

Mixin(ns, GameVersionMixin, AceLib); ns.addon = addon; GEARS_NS = ns
ns.O = ns.O or {}

--- Matches *.toc SavedVariables definition
local DB_NAME = 'GEARS_DB'
ns.logName = strupper(ns.addon)

--- @type NamespaceObjects
local O = ns.O or {}; ns.O = O

--[[-------------------------------------------------------------------
Base Colors
---------------------------------------------------------------------]]
local colorFormatter = LibStub('Kapresoft-ColorFormatter-2-0')

local prefixColor, subPrefixColor = '59A3FA', '9CFF9C'
ns.colorDef = {
  primary = CreateColorFromRGBHexString(prefixColor),
  secondary = CreateColorFromRGBHexString(subPrefixColor),
}

--[[-----------------------------------------------------------------------------
Logger and Tracer
-------------------------------------------------------------------------------]]
ns.logHolder = {}; do
  local h = ns.logHolder;
  local noop_fn =  function() end
  local noop_logFnBuilder = function(moduleName) return noop_fn end
  --- These are noop loggers and tracers for non-dev releases
  ns.tr, h.printer, h.tracer = noop_fn, noop_logFnBuilder, noop_logFnBuilder
end

--[[-----------------------------------------------------------------------------
Type: Settings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class Gears_Settings
--- @field developer boolean @if true: enables developer mode
local settings = { developer = false }; ns.settings = settings

--- @return boolean
function ns:IsDev() return ns.settings.developer == true end

--[[-------------------------------------------------------------------
Logger Methods
---------------------------------------------------------------------]]
local function predicateFn() return ns:IsDev() end
do
  ns.fmt     = LibPrettyPrint:Formatter({
    show_all = true, depth_limit = 3
  }); if not fmt then fmt = ns.fmt end
  
  ns.printer = LibPrettyPrint:Printer({
    prefix = ns.addon, prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
    formatter = ns.fmt
  }, predicateFn)
end

--[[-----------------------------------------------------------------------------
NamespaceObjects: Ace-3.0
-------------------------------------------------------------------------------]]
do
  -- todo: use AceLib
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
  
  --- @param rgbHex RGBHex?     @Optional
  --- @return cfFn, colorRGBA?
  function ns:ColorFn(rgbHex) return colorFormatter:ColorFn(rgbHex) end

  --- ### Usage
  ---  ```
  ---  -- @returns 'Gears::OnPlayerLogin'
  ---  local message = ns:msg('OnPlayerLogin')
  ---  ```
  --- @param msgName Name @The base message name; used for AceEvent messages
  --- @return string
  function ns:msg(msgName)
    assert(not IsNilOrBlank(msgName), 'Message name is required.')
    return ('%s::%s'):format(ns.addon, msgName)
  end

  function ns:AddonUtil() return LibStub('Kapresoft-AddonUtil-2-0') end

  --- @return table<string, string>
  function ns:GetLocale() return AceLocaleUtil:GetLocale(ns.addon, ns:IsDev()) or {} end
  
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

  --[[-------------------------------------------------------------------
  Loggers/Tracers:: NoOp in Official Releases
                    This is overridden in DeveloperSetup
  ---------------------------------------------------------------------]]
  --- Returns the print, delayed-print, tracer, formatted-tracer functions
  --- ```
  --- local p, t = ns:log('EventHandler')
  --- ```
  --- @see DeveloperSetup.lua
  --- @param moduleName Name  @The module name or any general prefix
  --- @return Gears_PrintFn
  --- @return Gears_TraceFn
  function ns:log(moduleName)
    local h = self.logHolder
    return h.printer(moduleName), h.tracer(moduleName)
  end

end; Namespace_Methods()

