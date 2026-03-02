--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, pd, t, tf = ns:log('Locale_frFR')

local L = ns:AceLocale():NewLocale(ns.addon, 'frFR'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L["Set Name"]              = "Nom de l’ensemble"
L['Left-click']            = 'Clic gauche'
L['Double-click']          = 'Double-clic'
L['Drag']                  = 'Glisser'
L['Available Actions']     = 'Actions disponibles'
L['Select']                = 'Sélectionner'
L['Equip']                 = 'Équiper'
L['Drag to an action bar'] = 'Glisser vers une barre d’action'
L['Equip While Combat']    = 'Les ensembles d’équipement ne peuvent pas être modifiés en combat.'

L['Open Gears Panel']           = 'Ouvrir le panneau Gears'
L['Create a new equipment set'] = 'Créer un nouvel ensemble d’équipement'
L['New Equipment Set']          = 'Nouvel ensemble d’équipement'
L['LibIconPicker Missing']      = 'Cette fonctionnalité nécessite LibIconPicker.|nVeuillez vous assurer que LibIconPicker est installé et activé, puis rechargez l’interface.'
