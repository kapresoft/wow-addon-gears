--- @type Namespace
local ns = select(2, ...)
local p, pd, t, tf = ns:log('Gears')

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
AddOn
-------------------------------------------------------------------------------]]
--
--- @alias Gears Gears__ | AddonModuleObj_3_0_Type1
--
--- @class Gears__ : AceAddon_3_0
local A = ns.O.AceAddon:NewAddon(ns.addon, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
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
  t('OnAddOnReady', 'isInitialLogin=', isInitialLogin, 'isReloadingUi=', isReloadingUi)
  self:SendMessage('GEARS::ADDON_READY', isInitialLogin, isReloadingUi)
end; a:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnAddOnReady')
