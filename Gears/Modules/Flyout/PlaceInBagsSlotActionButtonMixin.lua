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
local C_PickupContainerItem = C_Container and C_Container.PickupContainerItem

--[[-----------------------------------------------------------------------------
Module::PlaceInBagsSlotActionButtonMixin
-------------------------------------------------------------------------------]]
--- @see NamespaceObjects
local libName = 'PlaceInBagsSlotActionButtonMixin'
--- @class PlaceInBagsSlotActionButtonMixin
--- @field TemplateName string
--- @field widget PlaceInBagsActionButtonWidget
--- @field Icon TextureObj
--- @field GetParent fun(self:PlaceInBagsSlotActionButtonMixin) : FlyoutFrame
local S = {}; Gears_PlaceInBagsSlotActionButtonMixin = S
--- @see EquipmentSlotFlyout.xml/Button[@name='Gears_PlaceInBagsSlotActionButtonTemplate']
S.TemplateName = 'Gears_PlaceInBagsSlotActionButtonTemplate'

--
--- @alias PlaceInBagsSlotActionButton PlaceInBagsSlotActionButtonMixin | ButtonObj
--
local p, pd, t, tf = ns:log(libName)
--[[-------------------------------------------------------------------
Mixin:
---------------------------------------------------------------------]]
--- @class PlaceInBagsActionButtonWidgetMixin
--- @field frame PlaceInBagsSlotActionButton
--- @field slotFlyoutButton EquipmentSlotFlyout
local PlaceInBagsActionButtonWidgetMixin = {}
--
--- @alias PlaceInBagsActionButtonWidget PlaceInBagsActionButtonWidgetMixin
--
do
  --- @type PlaceInBagsActionButtonWidgetMixin | PlaceInBagsActionButtonWidget
  local w = PlaceInBagsActionButtonWidgetMixin
  
  --- @param frame PlaceInBagsSlotActionButton
  --- @param slotFlyoutButton EquipmentSlotFlyout
  function w:Init(frame, slotFlyoutButton)
    self.frame = frame
    self.slotFlyoutButton = slotFlyoutButton
  end
end

--[[-----------------------------------------------------------------------------
Module::PlaceInBagsSlotActionButtonMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type PlaceInBagsSlotActionButtonMixin | PlaceInBagsSlotActionButton
local o = Gears_PlaceInBagsSlotActionButtonMixin

function o:OnLoad()
  --- @type EquipmentSlotFlyout
  local slotFlyoutBtn = self:GetParent():GetParent()
  self.widget = CreateAndInitFromMixin(PlaceInBagsActionButtonWidgetMixin, self, slotFlyoutBtn)
end

-- /dump PickupInventoryItem(2); PutItemInBackpack()
-- /dump C_Container.GetContainerItemInfo(0, 1)
-- /dump C_Container.PickupContainerItem(0, 1)
function o:OnClick()
  ns:PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  
  local slotID = self:GetSlotID()
  
  -- nothing equipped
  local itemLink = GetInventoryItemLink('player', slotID)
  if not itemLink then self:GetParent():Hide(); return end
  
  local trace = true; if trace then
    t('OnClick', 'Item=', fmt(GetItemInfo(itemLink)))
  end
  
  -- move equipped item to bags
  PickupInventoryItem(slotID)
  self:PlaceInBag()
  
  -- close flyout
  self:GetParent():Hide()
end

--- Places the picked up item into the first available
--- bag slot (backpack → bags)
function o:PlaceInBag()
  -- try backpack first (bag 0)
  if not self:TryPlaceInBag(0) then
    -- bags 1 to NUM_BAG_SLOTS
    for bag = 1, NUM_BAG_SLOTS do
      if self:TryPlaceInBag(bag) then return end
    end
  end
  
  -- no space found, clear cursor to avoid stuck item
  ClearCursor()
end

--- @param bag number
--- @return boolean placed
function o:TryPlaceInBag(bag)
  local numSlots = C_GetContainerNumSlots(bag)
  if not numSlots or numSlots == 0 then return false end
  
  for slot = 1, numSlots do
    local info = C_GetContainerItemInfo(bag, slot)
    if not info then
      C_PickupContainerItem(bag, slot); return true
    end
  end
  
  return false
end


--- @return EquipmentSlotFlyout
function o:GetFlyout() return self:GetParent():GetParent() end
--- @return BlizzCharacterSlotItemButton
function o:GetCharItemSlot() return self:GetFlyout().widget.charSlotButton end
--- @return SlotID
function o:GetSlotID() return self:GetCharItemSlot():GetID() end
