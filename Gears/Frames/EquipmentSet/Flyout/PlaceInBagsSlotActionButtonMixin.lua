--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local L = ns:GetLocale()

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
Mixin: PlaceInBagsActionButtonWidgetMixin
---------------------------------------------------------------------]]
--- @class PlaceInBagsActionButtonWidgetMixin
--- @field frame PlaceInBagsSlotActionButton
--- @field slotFlyoutButton EquipmentSlotFlyout
local PlaceInBagsActionButtonWidgetMixin = {}
--
--- @alias PlaceInBagsActionButtonWidget PlaceInBagsActionButtonWidgetMixin
--
--[[-------------------------------------------------------------------
Methods: PlaceInBagsActionButtonWidgetMixin
---------------------------------------------------------------------]]
--- @type PlaceInBagsActionButtonWidgetMixin | PlaceInBagsActionButtonWidget
local w = PlaceInBagsActionButtonWidgetMixin

--- @param frame PlaceInBagsSlotActionButton
--- @param slotFlyoutButton EquipmentSlotFlyout
function w:Init(frame, slotFlyoutButton)
  self.frame = frame
  self.slotFlyoutButton = slotFlyoutButton
  self:SetupTooltip()
end

function w:SetupTooltip()
  local c_white = ns:colorFn('afafaf')
  
  self.frame:SetScript('OnEnter', function(btn)
    GameTooltip:SetOwner(btn, 'ANCHOR_RIGHT')
    GameTooltip:SetText(L['Place item in bags'])
    GameTooltip:AddLine(c_white(L['Place item in bags::DESC']))
    GameTooltip:Show()
  end)
  self.frame:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
end

--[[-----------------------------------------------------------------------------
Module::PlaceInBagsSlotActionButtonMixin (Methods)
-------------------------------------------------------------------------------]]
--- @type PlaceInBagsSlotActionButtonMixin | PlaceInBagsSlotActionButton
local o = Gears_PlaceInBagsSlotActionButtonMixin

function o:OnLoad()
  self:SetParentKey('PlaceInBagsActionButton')
  self.Icon:SetTexture([[Interface\Icons\INV_Misc_Bag_09]])
  
  --- @type EquipmentSlotFlyout
  local slotFlyoutBtn = self:GetParent():GetParent()
  self.widget = CreateAndInitFromMixin(PlaceInBagsActionButtonWidgetMixin, self, slotFlyoutBtn)
end

function o:OnClick()
  if InCombatLockdown() then return end
  
  ns:PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  
  local slotID = self:GetSlotID()
  
  -- nothing equipped
  local itemLink = GetInventoryItemLink('player', slotID)
  if not itemLink then self:GetParent():Hide(); return end
  
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
