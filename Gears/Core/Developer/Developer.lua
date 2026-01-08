--- @type Namespace
local ns = select(2, ...)

local D = {}

local p = ns:Log('Developer')
C_Timer.After(0.7, function()
    p('Is-Dev:', ns:IsDev())
end)
