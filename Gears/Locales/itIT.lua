--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, t = ns:log('Locale_itIT')

local L = ns:NewLocale('itIT'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L['Set Name']              = 'Nome del set'
L['Currently Equipped']    = 'Attualmente equipaggiato'
L['Left-click']            = 'Clic sinistro'
L['Double-click']          = 'Doppio clic'
L['Drag']                  = 'Trascina'
L['Available Actions']     = 'Azioni disponibili'
L['Select']                = 'Seleziona'
L['Equip']                 = 'Equipaggia'
L['Drag to an action bar'] = "Trascina su una barra azione"
L['Equip While Combat']    = 'I set di equipaggiamento non possono essere cambiati durante il combattimento.'

L['Open Gears Panel']           = 'Apri il pannello Gears'
L['Create a new equipment set'] = 'Crea un nuovo set di equipaggiamento'
L['New Equipment Set']          = 'Nuovo set di equipaggiamento'
L['LibIconPicker Missing']      = 'Questa funzione richiede LibIconPicker.|nAssicurati che LibIconPicker sia installato e attivato, quindi ricarica l’interfaccia.'

L['Available commands:']                       = 'Comandi disponibili:'
L['displays the addon info']                   = "mostra le informazioni sull'addon"
L['equips the named or indexed equipment set'] = 'equipaggia il set di equipaggiamento indicato per nome o indice'
L['Usage']                                     = 'Utilizzo'
L['No such equipment set with name or index']  = 'Nessun set di equipaggiamento con questo nome o indice'
L['Equipped:']                                 = 'Equipaggiato:'
L['Already Equipped:']                         = 'Già equipaggiato:'
L['shows the currently equipped set, if any']  = 'mostra il set attualmente equipaggiato, se presente'
L['No equipment set is currently equipped']    = 'Nessun set di equipaggiamento è attualmente equipaggiato'
L['lists all equipment sets']                  = 'elenca tutti i set di equipaggiamento'
L['No equipment sets found']                   = 'Nessun set di equipaggiamento trovato'
L['Equipment Sets:']                           = 'Set di equipaggiamento:'
L['equipped']                                  = 'equipaggiato'

L['Select a set to enable slot actions'] = 'Seleziona un set per abilitare le azioni sugli slot'
L['Include Slot']               = 'Includi slot'
L['Include Slot::DESC']         = 'Includi questo slot quando salvi il set di equipaggiamento'
L['Ignore Slot']                = 'Ignora slot'
L['Ignore Slot::DESC']          = 'Escludi questo slot quando salvi il set di equipaggiamento'
L['Place item in bags']         = 'Metti l’oggetto nelle borse'
L['Place item in bags::DESC']   = "Sposta l'oggetto equipaggiato nel primo slot borsa disponibile"
L['Shift-Click']                = 'Maiusc-clic'
L['Ignore All Slots']           = 'Ignora tutti gli slot'
L['Include All Slots']          = 'Includi tutti gli slot'
