--- @type Namespace
local ns = select(2, ...)

--- @class Developer
local o = {}

local p = ns:log('Developer')
C_Timer.After(0.7, function()
    p('Is-Dev:', ns:IsDev())
end)


function o:trace()
    local fmt = ns.fmt
    local e = ns:evt()
    --local p = ns.evt
    --local data = { hello='there', xfn=function() print('hello') end }
    --p('settings_isdev',  ns:IsDev(), ns.addon, pformat:B()(ns))
    e:td('val', 'there')
    e:tdf('val_formatted', 'there')
    e:t('debug', 'hello', 'world', { 'hello', 'world' }, "is-dev=", ns:IsDev(), 'ns.O=', ns.O)
    e:tf('debug_formatted', 'hello', 'world', { 'hello', 'world' }, "is-dev=", ns:IsDev(), 'ns.O=', fmt(ns.O))
end

gdev = o
