--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, pd, t, tf = ns:log('Locale_enUS')

local L = ns:AceLocale():NewLocale(ns.addon, 'enUS', true); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L['Set Name']              = true
L['Left-click']            = 'Left-click'
L['Double-click']          = 'Double-click'
L['Drag']                  = 'Drag'
L['Available Actions']     = 'Available Actions'
L['Select']                = 'Select'
L['Equip']                 = 'Equip'
L['Drag to an action bar'] = 'Drag to an action bar'
L['Equip While Combat']    = 'Equipment sets cannot be changed during combat.'

L['Open Gears Panel']           = 'Open Gears Panel'
L['Create a new equipment set'] = 'Create a new equipment set'
L['New Equipment Set']          = 'New Equipment Set'
L['LibIconPicker Missing']      = 'This feature requires LibIconPicker.|nPlease make sure LibIconPicker is installed and enabled, then reload the UI.'
