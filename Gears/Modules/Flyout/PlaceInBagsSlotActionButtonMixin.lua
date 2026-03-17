--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

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

--[[-----------------------------------------------------------------------------
Module::PlaceInBagsSlotActionButtonMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type PlaceInBagsSlotActionButtonMixin | PlaceInBagsSlotActionButton
local o = Gears_PlaceInBagsSlotActionButtonMixin

function o:OnLoad()
  --- @type EquipmentSlotFlyout
  local slotFlyoutBtn = self:GetParent():GetParent()
  
  --- @class PlaceInBagsActionButtonWidget
  --- @field frame PlaceInBagsSlotActionButton
  --- @field slotFlyoutButton EquipmentSlotFlyout
  local widget = {
    frame = self,
    slotFlyoutButton = slotFlyoutBtn
  }; self.widget = widget
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
  PutItemInBackpack()
  
  -- close flyout
  self:GetParent():Hide()
end

--- @return EquipmentSlotFlyout
function o:GetFlyout() return self:GetParent():GetParent() end
--- @return BlizzCharacterSlotItemButton
function o:GetCharItemSlot() return self:GetFlyout().widget.slotButton end
--- @return SlotID
function o:GetSlotID() return self:GetCharItemSlot():GetID() end
