--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local cfu = ns.O.CharacterFrameUtil

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFactory
-------------------------------------------------------------------------------]]
--- @see NamespaceObjects
local libName = 'EquipmentSlotFactory'
--- @class EquipmentSlotFactory
local S = {}; ns.O.EquipmentSlotFactory = S
local p, pd, t, tf = ns:log(libName)

--- @type EquipmentSlotFlyout[]
local flyouts = {}

--[[-----------------------------------------------------------------------------
Module::EquipmentSlotFactory (Methods)
-------------------------------------------------------------------------------]]
--- @type EquipmentSlotFactory
local o = S

--- /dump PaperDollFrame.HeadSlotFlyout
--- @param slotInfo InventorySlotInfo
--- @param slotButton ButtonObj
--- @return EquipmentSlotFlyout
function o:Create(slotInfo, slotButton)
  --- @type EquipmentSlotFlyout
  local slotFlyout = CreateFrame('Button', nil, PaperDollFrame, 'GearsEquipmentSlotFlyoutTemplate', slotInfo.id)
  local name = slotInfo.name .. 'Flyout'
  slotFlyout:SetParentKey(name)
  --- @class EquipmentSlotFlyoutWidget
  --- @field frame EquipmentSlotFlyout
  local widget = {
    frame = slotFlyout,
    characterSlot = slotButton,
  }; slotFlyout.widget = widget
  do
    --- @return boolean
    function widget:IsCharacterSlotShown()
      return self.characterSlot and self.characterSlot:IsShown()
    end
  end
  
  slotFlyout:ClearAllPoints()
  local ofsx, ofsy = -2, 0
  if ns:HasBlizzEquipmentManager() then ofsx = -10 end
  slotFlyout:SetPoint('LEFT', widget.characterSlot, 'RIGHT', ofsx, ofsy)
  
  return slotFlyout
end

function o:CreateSlotFlyouts()
  cfu:ForEachEquipmentSlot(function(s, btn, po)
    local flyout = self:Create(s, btn)
    table.insert(flyouts, flyout)
  end)
end

--- @param enable boolean
function o:SetFlyoutState(enable)
  if enable then return self:ShowFlyouts() end
  self:HideFlyouts()
end

function o:ShowFlyouts()
  if not flyouts or #flyouts <= 0 then return end
  for _, fo in ipairs(flyouts) do
    local method = fo.widget:IsCharacterSlotShown() and 'Show' or 'Hide'
    fo[method](fo) -- example method call:  fo.Show(fo) 'fo' for self
  end
end

function o:HideFlyouts()
  self:ForEachFlyouts(function(flyout) flyout:Hide() end)
end

-- Some character equipment slots may be hidden (class/spec dependent).
-- Hide the flyout when its corresponding slot is not visible.
function o:UpdateVisibility()
  self:ForEachFlyouts(function(flyout)
    local charSlot = flyout.widget.characterSlot
    if not charSlot:IsShown() then flyout:Hide() end
  end)
end

--- @param callbackFn fun(flyout:EquipmentSlotFlyout) : void
function o:ForEachFlyouts(callbackFn)
  if not flyouts or #flyouts <= 0 then return end
  for _, fo in ipairs(flyouts) do callbackFn(fo) end
end
