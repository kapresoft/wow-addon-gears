--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]

--- @class NamespaceObjects
--- @field GameVersion GameVersion
--- @field LibIconPickerUtil LibIconPickerUtil
--- @field CharacterFrameUtil CharacterFrameUtil
--- @field DatabaseSchema DatabaseSchema
--- @field EquipmentSlotFlyoutManager EquipmentSlotFlyoutManager
--- @field InventoryUtil InventoryUtil
--- @field ItemUtil ItemUtil
--- @field AceEvent AceEvent-3.0
--- @field AceBucket AceBucket-3.0
--- @field AceHook AceHook-3.0
--- @field AceLocale AceLocale-3.0
--- @field AceAddon AceAddon-3.0
--- @field AceDB AceDB-3.0
--- @field Table Kapresoft-Table-2-0
--- @field String Kapresoft-String-2-0

--- @class Gears_LogHolder
--- @field printer fun(moduleName:Name) : Gears_PrintFn    @A simple logger function
--- @field tracer fun(moduleName:Name)  : Gears_TraceFn    @A simple trace function

--- @alias Gears_PrintFn LibPrettyPrint_PrintFn @Printer function that outputs plain values to Blizzard Trace UI (like print)
--- @alias Gears_TraceFn fun(...: any) : void   @Printer function that outputs plain values to Blizzard Trace UI (like print)

--[[-------------------------------------------------------------------
This file only for emmyLua and is not included in the deploy.
---------------------------------------------------------------------]]
--- @type ToggleButton
Gears_ToggleButton = {}

--- @type Gears_MainFrame
Gears_MainFrame = {}

--- @type Frame
PaperDollFrame = {}

--[[-------------------------------------------------------------------
InventorySlotInfo
---------------------------------------------------------------------]]
--- @class InventorySlotInfo
--- @field name Name The slot name
--- @field id number @See [InventorySlotID](https://warcraft.wiki.gg/wiki/InventorySlotID)
--- @field iconID IconIDOrPath
--- @field checkRelic boolean


--- @class BlizzCharacterSlotItemButton : Button
--- @field ignoreSlotOverlay Texture
--- @field popoutButton Button
--- @field gears Gears_BlizzCharacterSlotItemButton

--[[-------------------------------------------------------------------
Aliases
---------------------------------------------------------------------]]
--- @alias EquipSetID number @The EquipmentSet Identifier
--- @alias SlotID number @The equipment slot ID


