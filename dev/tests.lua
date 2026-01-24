x = {
  
function()
  local s = C_EquipmentSet
  for i = 1, 9 do
    local name = ('Test Set %s'):format(i)
    s.CreateEquipmentSet(name, 132093 + i)
  end
end,

function()
  local s = C_EquipmentSet
  for i = 1, 9 do s.DeleteEquipmentSet(i+1) end
end,

  function()
    local eq  = C_EquipmentSet
    --- @type table<number,number>
    local ids = eq.GetEquipmentSetIDs()
    local set = {}
    for i, id in ipairs(ids) do
      local name, iconFileID = eq.GetEquipmentSetInfo(id)
      table.insert(set, { name = name, icon = iconFileID })
    end
    return {
      ids  = ids,
      info = set,
    }
  end,
  
}
