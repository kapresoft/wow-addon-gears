--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, t = ns:log('Locale_frFR')

local L = ns:NewLocale('frFR'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L["Set Name"]              = "Nom de l’ensemble"
L['Currently Equipped']    = 'Actuellement équipé'
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

L['Available commands:']                       = 'Commandes disponibles :'
L['displays the addon info']                   = "affiche les informations de l'addon"
L['equips the named or indexed equipment set'] = "équipe l'ensemble d'équipement nommé ou indexé"
L['Usage']                                     = 'Utilisation'
L['No such equipment set with name or index']  = "Aucun ensemble d'équipement avec ce nom ou cet index"
L['Equipped:']                                 = 'Équipé :'
L['Already Equipped:']                         = 'Déjà équipé :'
L['shows the currently equipped set, if any']  = 'affiche le set actuellement équipé, le cas échéant'
L['No equipment set is currently equipped']    = "Aucun ensemble d'équipement n'est actuellement équipé"
L['lists all equipment sets']                  = "liste tous les ensembles d'équipement"
L['No equipment sets found']                   = "Aucun ensemble d'équipement trouvé"
L['Equipment Sets:']                           = "Ensembles d'équipement :"
L['equipped']                                  = 'équipé'

L['Select a set to enable slot actions'] = 'Sélectionnez un set pour activer les actions d’emplacement'
L['Include Slot']               = 'Inclure l’emplacement'
L['Include Slot::DESC']         = 'Inclure cet emplacement lors de l’enregistrement de l’ensemble d’équipement'
L['Ignore Slot']                = 'Ignorer l’emplacement'
L['Ignore Slot::DESC']          = 'Exclure cet emplacement lors de l’enregistrement de l’ensemble d’équipement'
L['Place item in bags']         = 'Placer l’objet dans les sacs'
L['Place item in bags::DESC']   = 'Déplace l’objet équipé vers le premier emplacement disponible dans les sacs'
L['Shift-Click']                = 'Maj-clic'
L['Ignore All Slots']           = 'Ignorer tous les emplacements'
L['Include All Slots']          = 'Inclure tous les emplacements'
