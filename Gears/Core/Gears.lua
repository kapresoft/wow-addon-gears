--- @type Namespace
local ns = select(2, ...)

local p = ns:Log('Gears')
C_Timer.After(1, function()
    p('loaded...')
end)
