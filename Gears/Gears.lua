--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

--- @type Namespace
local ns = select(2, ...)
local p, t = ns:log('AddOn')

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
function a:OnInitialize() ns:InitDatabase() end
function a:OnEnable() end
function a:OnDisable() end

--[[-------------------------------------------------------------------
Addon Methods
---------------------------------------------------------------------]]


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
