--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, pd, t, tf = ns:log('Locale_esES')

local L = ns:AceLocale():NewLocale(ns.addon, 'esES'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L["Set Name"]              = "Nombre del conjunto"
L['Left-click']            = 'Clic izquierdo'
L['Double-click']          = 'Doble clic'
L['Drag']                  = 'Arrastrar'
L['Available Actions']     = 'Acciones disponibles'
L['Select']                = 'Seleccionar'
L['Equip']                 = 'Equipar'
L['Drag to an action bar'] = 'Arrastrar a una barra de acción'
L['Equip While Combat']    = 'Los conjuntos de equipo no pueden cambiarse durante el combate.'

L['Open Gears Panel']           = 'Abrir el panel de Gears'
L['Create a new equipment set'] = 'Crear un nuevo conjunto de equipo'
L['New Equipment Set']          = 'Nuevo conjunto de equipo'
L['LibIconPicker Missing']      = 'Esta función requiere LibIconPicker.|nAsegúrate de que LibIconPicker esté instalado y habilitado, y luego recarga la interfaz.'
L['Include Slot']               = 'Incluir ranura'
L['Include Slot::DESC']         = 'Incluir esta ranura al guardar el conjunto de equipo'
L['Ignore Slot']                = 'Ignorar ranura'
L['Ignore Slot::DESC']          = 'Excluir esta ranura al guardar el conjunto de equipo'
L['Place item in bags']         = 'Colocar objeto en las bolsas'
L['Place item in bags::DESC']   = 'Mueve el objeto equipado al primer espacio disponible en las bolsas'
