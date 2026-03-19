--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots
local C_GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo

--[[-------------------------------------------------------------------
Data Bags
---------------------------------------------------------------------]]
local EQUIP_LOC_TO_SLOT_MAP = {
  INVTYPE_HEAD     = { INVSLOT_HEAD },
  INVTYPE_NECK     = { INVSLOT_NECK },
  INVTYPE_SHOULDER = { INVSLOT_SHOULDER },
  INVTYPE_CLOAK    = { INVSLOT_BACK },
  INVTYPE_CHEST    = { INVSLOT_CHEST },
  INVTYPE_ROBE     = { INVSLOT_CHEST },
  INVTYPE_WRIST    = { INVSLOT_WRIST },
  INVTYPE_HAND     = { INVSLOT_HAND },
  INVTYPE_WAIST    = { INVSLOT_WAIST },
  INVTYPE_LEGS     = { INVSLOT_LEGS },
  INVTYPE_FEET     = { INVSLOT_FEET },
  
  INVTYPE_FINGER   = { INVSLOT_FINGER1, INVSLOT_FINGER2 },
  INVTYPE_TRINKET  = { INVSLOT_TRINKET1, INVSLOT_TRINKET2 },
  
  INVTYPE_WEAPON        = { INVSLOT_MAINHAND, INVSLOT_OFFHAND },
  INVTYPE_WEAPONMAINHAND= { INVSLOT_MAINHAND },
  INVTYPE_WEAPONOFFHAND = { INVSLOT_OFFHAND },
  INVTYPE_2HWEAPON      = { INVSLOT_MAINHAND },
  INVTYPE_SHIELD        = { INVSLOT_OFFHAND },
  INVTYPE_HOLDABLE      = { INVSLOT_OFFHAND },
}

--[[-----------------------------------------------------------------------------
Module::InventoryUtil
-------------------------------------------------------------------------------]]
--- @see NamespaceObjects
local libName = 'InventoryUtil'
--- @class InventoryUtil
local S = {}; ns.O.InventoryUtil = S
local p, pd, t, tf = ns:log(libName)

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function itemUtil() return ns.O.ItemUtil end

--- @param slotID SlotID
--- @param itemData ItemInfoDetails
--- @return boolean
local function SlotMatches(slotID, itemData)
  local slots = itemData.equipLoc and EQUIP_LOC_TO_SLOT_MAP[itemData.equipLoc]
  if not slots then return false end
  for _, s in ipairs(slots) do
    if s == slotID then return true end
  end
  return false
end

--[[-----------------------------------------------------------------------------
Module::InventoryUtil (Methods)
-------------------------------------------------------------------------------]]
--- @type InventoryUtil
local o = S

--- @param slotID SlotID
--- @param callbackFn fun(info:ContainerItemInfo, item:ItemInfoDetails) : void | "'function(info, item) end'"
--- @return table<number, ItemInfoDetails> Item Data
function o:ForEachBagItemMatchingSlot(slotID, callbackFn)
  local itemUtil = itemUtil()
  self:ForEachBagItem(function(info)
    local link = info.hyperlink
    if IsEquippableItem(link) then
      local itemData = itemUtil:GetItem(link)
      if itemData and SlotMatches(slotID, itemData) then callbackFn(info, itemData) end
    end
  end)
end

--- @param callbackFn fun(info:ContainerItemInfo, item:ItemInfoDetails) : void | "'function(info, item) end'"
function o:ForEachSlotItemCandidate(slotID, callbackFn)
  self:ForEachBagItemMatchingSlot(slotID, callbackFn)
end

--- @param slotID SlotID
--- @return ItemInfoDetails[] Available items that matches the slot
function o:GetAvailableSlotItems(slotID)
  local items = {}
  self:ForEachSlotItemCandidate(slotID, function(info, item)
    table.insert(items, item)
  end)
  return items
end

---@param callback fun(info:ContainerItemInfo) : void
function o:ForEachBagItem(callback)
  for bag = 0, NUM_BAG_SLOTS do
    local numSlots = C_GetContainerNumSlots(bag)
    for slot = 1, numSlots do
      local info = C_GetContainerItemInfo(bag, slot)
      if info and info.hyperlink then
        info.bagID = bag
        info.slotIndex = slot
        callback(info)
      end
    end
  end
end
