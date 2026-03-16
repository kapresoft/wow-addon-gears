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
Constants: Slot Names
---------------------------------------------------------------------]]
--- @class CharacterFrameUtil_Constants
local C = { }

local SLOT_NAMES = {
  [INVSLOT_HEAD] = "HeadSlot",
  [INVSLOT_NECK] = "NeckSlot",
  [INVSLOT_SHOULDER] = "ShoulderSlot",
  [INVSLOT_BODY] = "ShirtSlot",
  [INVSLOT_CHEST] = "ChestSlot",
  [INVSLOT_WAIST] = "WaistSlot",
  [INVSLOT_LEGS] = "LegsSlot",
  [INVSLOT_FEET] = "FeetSlot",
  [INVSLOT_WRIST] = "WristSlot",
  [INVSLOT_HAND] = "HandsSlot",
  [INVSLOT_FINGER1] = "Finger0Slot",
  [INVSLOT_FINGER2] = "Finger1Slot",
  [INVSLOT_TRINKET1] = "Trinket0Slot",
  [INVSLOT_TRINKET2] = "Trinket1Slot",
  [INVSLOT_BACK] = "BackSlot",
  [INVSLOT_MAINHAND] = "MainHandSlot",
  [INVSLOT_OFFHAND] = "SecondaryHandSlot",
  [INVSLOT_RANGED] = "RangedSlot",
  [INVSLOT_TABARD] = "TabardSlot",
}
C.SlotNames = SLOT_NAMES
--[[-------------------------------------------------------------------
New Library
---------------------------------------------------------------------]]
--- @class CharacterFrameUtil
--- @field C CharacterFrameUtil_Constants
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

--- @class SlotItemButton
--- @field popoutButton|nil ButtonObj Only on versions with Blizz Equipment Managers

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
      if slotInfo then
        callbackFn(slotInfo, slotItemButton, slotItemButton.popoutButton)
      end
    end
  end
end
