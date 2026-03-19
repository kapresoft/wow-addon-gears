--- @type Namespace
local ns= select(2, ...)

--[[-------------------------------------------------------------------
Types
---------------------------------------------------------------------]]
--- @class SlotItemButton
--- @field popoutButton|nil ButtonObj Only on versions with Blizz Equipment Managers

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local strsub, pcall = strsub, pcall
local PaperDollItemsFrame, GetInventorySlotInfo = PaperDollItemsFrame, GetInventorySlotInfo

--[[-------------------------------------------------------------------
New Library
---------------------------------------------------------------------]]
--- @class CharacterFrameUtil
local S = {}; ns.O.CharacterFrameUtil = S
local p, pd, t, tf = ns:log('CharacterFrameUtil')

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
  if not ok then return nil end
  
  return result
end

--- See Also:: PaperDollFrame.xml # Frame/PaperDollItemsFrame
--- @param callbackFn fun(info:InventorySlotInfo, btn:ButtonObj, po:ButtonObj) | "function(info, btn, po) end"
function o:ForEachEquipmentSlot(callbackFn)
  local pdif = PaperDollItemsFrame
  if not (pdif and GetInventorySlotInfo) then return end
  
  --- @type table<number, SlotItemButton>
  local children = { pdif:GetChildren() }
  
  for _, slotItemButton in ipairs(children) do
    local parentName = slotItemButton:GetParent():GetName()
    if parentName == 'PaperDollItemsFrame' then
      local slotInfo = GetSlotInfo(slotItemButton)
      -- slotItemButton has a popoutButton
      if slotInfo then callbackFn(slotInfo, slotItemButton, slotItemButton.popoutButton) end
    end
  end
end
