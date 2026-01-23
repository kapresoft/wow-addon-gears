-- Gears-OptionsUI/Init.lua
local gears = GEARS
if not gears then return end

--- @type string
local addon
--- @type any
local ns
addon, ns = ...

local p = GEARS_NS:Log(addon)

C_Timer.After(1, function()
    p('xxx Loaded....')
end)
