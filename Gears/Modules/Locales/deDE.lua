--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, pd, t, tf = ns:log('Locale_deDE')

local L = ns:AceLocale():NewLocale(ns.addon, 'deDE'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L['Set Name']              = 'Name des Sets'
L['Left-click']            = 'Linksklick'
L['Double-click']          = 'Doppelklick'
L['Drag']                  = 'Ziehen'
L['Available Actions']     = 'Verfügbare Aktionen'
L['Select']                = 'Auswählen'
L['Equip']                 = 'Anlegen'
L['Drag to an action bar'] = 'Auf eine Aktionsleiste ziehen'
L['Equip While Combat']    = 'Ausrüstungssets können im Kampf nicht geändert werden.'

L['Open Gears Panel']           = 'Gears-Fenster öffnen'
L['Create a new equipment set'] = 'Ein neues Ausrüstungsset erstellen'
L['New Equipment Set']          = 'Neues Ausrüstungsset'
L['LibIconPicker Missing']      = 'Diese Funktion erfordert LibIconPicker.|nBitte stelle sicher, dass LibIconPicker installiert und aktiviert ist, und lade dann die Benutzeroberfläche neu.'
