--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, pd, t, tf = ns:log('Locale_ruRU')

local L = ns:AceLocale():NewLocale(ns.addon, 'ruRU'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L["Set Name"]              = "Название комплекта"
L['Left-click']            = 'Левый щелчок'
L['Double-click']          = 'Двойной щелчок'
L['Drag']                  = 'Перетащить'
L['Available Actions']     = 'Доступные действия'
L['Select']                = 'Выбрать'
L['Equip']                 = 'Надеть'
L['Drag to an action bar'] = 'Перетащите на панель действий'
L['Equip While Combat']    = 'Комплекты экипировки нельзя менять во время боя.'

L['Open Gears Panel']           = 'Открыть панель Gears'
L['Create a new equipment set'] = 'Создать новый комплект экипировки'
L['New Equipment Set']          = 'Новый комплект экипировки'
L['LibIconPicker Missing']      = 'Для этой функции требуется LibIconPicker.|nУбедитесь, что LibIconPicker установлен и включён, затем перезагрузите интерфейс.'

