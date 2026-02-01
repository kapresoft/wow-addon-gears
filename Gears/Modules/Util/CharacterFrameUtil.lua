--- @type Namespace
local ns= select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local strsub, pcall = strsub, pcall
local PaperDollItemsFrame, GetInventorySlotInfo = PaperDollItemsFrame, GetInventorySlotInfo
local c_error = ns:colorFn('FF513C')
local c_warn = ns:colorFn('FFAA6D')
--[[-------------------------------------------------------------------
New Library
---------------------------------------------------------------------]]
--- @class CharacterFrameUtil
local S = {}; ns.O.CharacterFrameUtil = S
local p = ns:log('CharacterFrameUtil')
--- @type CharacterFrameUtil
local o = S;

--- @param slotItemButton ButtonObj
--- @return InventorySlotInfo
local function GetSlotInfo(slotItemButton)
  local slotName = strsub(slotItemButton:GetName(), 10)
  --- @type InventorySlotInfo
  local ok, result = pcall(function()
    -- removes 'Character' in 'Character[SlotName]'
    local slot, icon, checkRelic = GetInventorySlotInfo(slotName)
    return { name = slotName, id = slot, iconID = icon, checkRelic = checkRelic }
  end)
  if not ok then
    p(('Slot[%s] not available:: %s'):format(slotName, c_warn(result)))
    return nil
  end
  return result
end

--- See Also:: PaperDollFrame.xml # Frame/PaperDollItemsFrame
--- @param callbackFn fun(info:InventorySlotInfo, btn:ButtonObj, po:ButtonObj) | "function(info, btn, po) end"
function o:ForEachEquipmentSlot(callbackFn)
  local pdif = PaperDollItemsFrame
  if not (pdif and GetInventorySlotInfo) then
    --p('ForEachEquipmentSlot::', c_error('PaperDollItemsFrame or GetInventorySlotInfo is not available.'))
    return
  end
  
  for _, slotItemButton in ipairs({ pdif:GetChildren() }) do
    local parentName = slotItemButton:GetParent():GetName()
    if parentName == 'PaperDollItemsFrame' then
      local slotInfo = GetSlotInfo(slotItemButton)
      -- slotItemButton has a popoutButton
      if slotInfo and slotItemButton.popoutButton then
        callbackFn(slotInfo, slotItemButton, slotItemButton.popoutButton)
      end
    end
  end
end
