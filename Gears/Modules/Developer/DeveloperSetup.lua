--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local sformat, upper, date = string.format, string.upper, date

--- @type Namespace
local ns = select(2, ...)
local s = ns.settings
s.developer = true
--s.enableTraceUI = true
