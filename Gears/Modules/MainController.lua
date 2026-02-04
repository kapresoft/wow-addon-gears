--- @type Namespace
local ns = select(2, ...)

local p = ns:log('MainController')

C_Timer.After(1, function()
  p('xx loaded....')
end)
