--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

--- @type Namespace
local ns = select(2, ...)
local p, t = ns:log('AddOn')

local L = ns:GetLocale()
local cu1 = ns:ColorFn(ns.colorDef.util2)

--- @type { cmd: string, desc: string }[] @Available slash commands, in display order
local slashCommands = {
  { cmd = 'info', desc = L['displays the addon info'] },
}

local addonInfoUtil__
--- @return Kapresoft-AddonInfoUtil-2-0
local function addonInfoUtil()
  if not addonInfoUtil__ then addonInfoUtil__ = ns:AddonInfoUtil():New(ns.addon) end
  return addonInfoUtil__
end

--[[-----------------------------------------------------------------------------
AddOn
-------------------------------------------------------------------------------]]

--- @class Gears : AceAddon-3.0, AceEvent-3.0, AceBucket-3.0, AceConsole-3.0
local A = ns:AceAddon():NewAddon(ns.addon, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
GEARS = A

--- @type Gears
local a = A

--[[-------------------------------------------------------------------
Lifecycle Methods
---------------------------------------------------------------------]]
function a:OnInitialize()
  ns:InitDatabase()
  self:RegisterChatCommand('gears', 'OnSlashCommand')
end
function a:OnEnable() end
function a:OnDisable() end

--[[-------------------------------------------------------------------
Addon Methods
---------------------------------------------------------------------]]
function a:PrintSlashCommandHelp()
  self:Print(L['Available commands:'])
  for _, c in ipairs(slashCommands) do
    self:Print(('  %s - %s'):format(cu1(c.cmd), c.desc))
  end
end

--- @param input string
function a:OnSlashCommand(input)
  local cmd = input:match('^(%S*)')
  if cmd == 'info' then
    self:Print(addonInfoUtil():GetInfoSlashCommandText())
  else
    self:PrintSlashCommandHelp()
  end
end

--[[-------------------------------------------------------------------
Event Hooks
---------------------------------------------------------------------]]
function a:OnAddOnReady(evt, isInitialLogin, isReloadingUi)
  --@do-not-package@
  t('OnAddOnReady', 'isInitialLogin=', isInitialLogin,
      'isReloadingUi=', isReloadingUi, 'GameVersion=', ns.gameVersion,
      'IsDev=', ns:IsDev())
  --@end-do-not-package@
  self:SendMessage(ns:msg('ADDON_READY'), isInitialLogin, isReloadingUi)
end; a:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnAddOnReady')
