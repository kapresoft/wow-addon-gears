x = {
  
  function()
    local s = C_EquipmentSet
    s.CreateEquipmentSet('DPS', 132093 + 1)
    s.CreateEquipmentSet('Tank', 132093 + 2)
  end,
  
  function()
    local s   = C_EquipmentSet
    local ids = s.GetEquipmentSetIDs()
    if #ids <= 0 then return end
    for index, esid in ipairs(ids) do
      s.DeleteEquipmentSet(esid)
    end
  end,
  
  function()
    local s = C_EquipmentSet
    for i = 1, 9 do
      local name = ('Test Set %s'):format(i)
      s.CreateEquipmentSet(name, 132095 + i)
    end
  end,
  
  function()
    local s = C_EquipmentSet
    for i = 1, 9 do s.DeleteEquipmentSet(i + 1) end
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
