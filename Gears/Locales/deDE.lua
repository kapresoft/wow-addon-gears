--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, t = ns:log('Locale_deDE')

local L = ns:NewLocale('deDE'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L['Set Name']              = 'Name des Sets'
L['Currently Equipped']    = 'Aktuell angelegt'
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

L['Available commands:']                       = 'Verfügbare Befehle:'
L['displays the addon info']                   = 'zeigt die Addon-Informationen an'
L['equips the named or indexed equipment set'] = 'rüstet das benannte oder indizierte Ausrüstungsset aus'
L['Usage']                                     = 'Verwendung'
L['No such equipment set with name or index']  = 'Kein Ausrüstungsset mit diesem Namen oder Index'
L['Equipped:']                                 = 'Angelegt:'
L['Already Equipped:']                         = 'Bereits angelegt:'
L['shows the currently equipped set, if any']  = 'zeigt das aktuell angelegte Set an, falls vorhanden'
L['No equipment set is currently equipped']    = 'Derzeit ist kein Ausrüstungsset angelegt'
L['lists all equipment sets']                  = 'listet alle Ausrüstungssets auf'
L['No equipment sets found']                   = 'Keine Ausrüstungssets gefunden'
L['Equipment Sets:']                           = 'Ausrüstungssets:'
L['equipped']                                  = 'angelegt'

L['Select a set to enable slot actions'] = 'Wähle ein Set aus, um Slot-Aktionen zu aktivieren'
L['Include Slot']               = 'Slot einschließen'
L['Include Slot::DESC']         = 'Diesen Slot beim Speichern des Ausrüstungssets einschließen'
L['Ignore Slot']                = 'Slot ignorieren'
L['Ignore Slot::DESC']          = 'Diesen Slot beim Speichern des Ausrüstungssets ausschließen'
L['Place item in bags']         = 'Gegenstand in Taschen legen'
L['Place item in bags::DESC']   = 'Verschiebt den angelegten Gegenstand in den ersten verfügbaren Taschenplatz'
L['Shift-Click']                = 'Umschalt-Klick'
L['Ignore All Slots']           = 'Alle Slots ignorieren'
L['Include All Slots']          = 'Alle Slots einschließen'
