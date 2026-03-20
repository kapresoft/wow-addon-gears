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

--[[-------------------------------------------------------------------
New Locale Items Below (Needs translation)
---------------------------------------------------------------------]]
L['Select a set to enable slot actions'] = 'Select a set to enable slot actions'
L['Include Slot']             = 'Include Slot'
L['Include Slot::DESC']       = 'Include this slot when saving the equipment set'
L['Ignore Slot']              = 'Ignore Slot'
L['Ignore Slot::DESC']        = 'Exclude this slot when saving the equipment set'
L['Place item in bags']       = 'Place item in bags'
L['Place item in bags::DESC'] = 'Moves equipped item to first available bag slot'

