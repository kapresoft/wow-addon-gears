--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

local libName = 'MainController'
local p = ns:log(libName)
local t = ns:traceFnWithFormatting(libName)

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]
--- @class MainController : AceEvent-3.0, AceBucket-3.0
local S = ns:AceEmbed({}, 'AceEvent-3.0', 'AceBucket-3.0');

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
local o = S

function o:OnPlayerLogin()
  self:SendMessage(ns:msg('OnInit'), self)
end

o:RegisterEvent('PLAYER_LOGIN', 'OnPlayerLogin')
