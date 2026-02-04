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
--- @class __MainController
local S = {}; ns:AceEvent(S); ns:AceBucket(S)

--- @alias MainController __MainController | AceEvent | AceBucket

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
--- @type __MainController | MainController
local o = S

function o:OnPlayerLogin()
  self:SendMessage(ns:msg('OnInit'), self)
end

o:RegisterEvent('PLAYER_LOGIN', 'OnPlayerLogin')
