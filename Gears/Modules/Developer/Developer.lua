local eq = C_EquipmentSet

--- @type Namespace
local ns = select(2, ...)

--- @class Gears_Developer
local o = {}; gdev = o

local p = ns:log('Developer')
C_Timer.After(0.7, function()
    p('Is-Dev:', ns:IsDev())
end)


function o:del1()
  local del = 4
  local ids = eq.GetEquipmentSetIDs()
  local info = { deleted={ eq.GetEquipmentSetInfo(del) }}
  --eq.DeleteEquipmentSet(del)
  return ids
end

function o:eqIds()
  --- @type table<number,number>
  local ids    = eq.GetEquipmentSetIDs()
  local result = {}
  for i, id in ipairs(ids) do
    local name, iconFileID = eq.GetEquipmentSetInfo(id)
    table.insert(result, { id =id, name = name, icon = iconFileID })
  end
  return result
end

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

