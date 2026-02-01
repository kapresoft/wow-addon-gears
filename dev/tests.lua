x = {
  
  function()
    local s = C_EquipmentSet
    s.CreateEquipmentSet('DPS', 132093 + 1)
    s.CreateEquipmentSet('Tank', 132093 + 2)
  end,
  
  function()
    local s = C_EquipmentSet
    -- 0, 1
    s.SaveEquipmentSet(1)
  end,
  
  function()
    local s = C_EquipmentSet
    -- 0, 1
    s.PickupEquipmentSet(1)
  end,
  
  function()
    local eq = C_EquipmentSet
    local del = 3
    local info = { deleted={ eq.GetEquipmentSetInfo(del) }}
    eq.DeleteEquipmentSet(del)
    return info
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
  function()
    for _, child in ipairs({ PaperDollItemsFrame:GetChildren() }) do
      local parentName = child:GetParent():GetName()
        if parentName == 'PaperDollItemsFrame' then
        local name = child:GetName()
        -- removes 'Character'
        local slotName = strsub(name,10)
        local info = { GetInventorySlotInfo(slotName) }
        print('name:', name, 'info:', pf(info))
      end
    end
  end,
  function()
    -- /dump CharacterHandsSlot.popoutButton
    -- /dump CharacterFrameExpandButton:IsCollapsed()
    --return CharacterFrameExpandButton:IsCollapsed()
    local s = CharacterHandsSlotPopoutButton
    --s:SetEnabled(true)
    --s:Show()
  end,
  function()
    -- CharacterHandsSlot
    -- /dump GetInventorySlotInfo('HandsSlot')
    for slotID = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
      local slotName = GetInventorySlotInfo(slotID)
      print('slotName:', slotName)
      local slotFrame = _G["Character"..slotName]
      local popout = _G["Character"..slotName.."PopoutButton"]
      
      if popout then
        popout:Show() -- or Hide()
      end
    end
  end,
function()
  for slotID = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
    for _, frame in pairs({CharacterFrame.NineSlice:GetChildren()}) do
      print('id:', slotID, 'name:', frame:GetName())
      if frame.GetID and frame:GetID() == slotID then
        --HandleSlot(frame)
      end
    end
  end
end
  
}
