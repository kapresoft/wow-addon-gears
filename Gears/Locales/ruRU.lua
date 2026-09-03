--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, t = ns:log('Locale_ruRU')

local L = ns:NewLocale('ruRU'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L["Set Name"]              = "Название комплекта"
L['Currently Equipped']    = 'Сейчас надето'
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

L['Available commands:']                       = 'Доступные команды:'
L['displays the addon info']                   = 'показывает информацию об аддоне'
L['equips the named or indexed equipment set'] = 'экипирует комплект по имени или индексу'
L['Usage']                                     = 'Использование'
L['No such equipment set with name or index']  = 'Нет комплекта экипировки с таким именем или индексом'
L['Equipped:']                                 = 'Надето:'
L['Already Equipped:']                         = 'Уже надето:'
L['shows the currently equipped set, if any']  = 'показывает текущий надетый комплект, если есть'
L['No equipment set is currently equipped']    = 'Сейчас не надет ни один комплект экипировки'
L['lists all equipment sets']                  = 'выводит список всех комплектов экипировки'
L['No equipment sets found']                   = 'Комплекты экипировки не найдены'
L['Equipment Sets:']                           = 'Комплекты экипировки:'
L['equipped']                                  = 'надето'

L['Select a set to enable slot actions'] = 'Выберите комплект, чтобы включить действия слотов'
L['Include Slot']               = 'Включить слот'
L['Include Slot::DESC']         = 'Включить этот слот при сохранении набора экипировки'
L['Ignore Slot']                = 'Игнорировать слот'
L['Ignore Slot::DESC']          = 'Исключить этот слот при сохранении набора экипировки'
L['Place item in bags']         = 'Поместить предмет в сумки'
L['Place item in bags::DESC']   = 'Перемещает экипированный предмет в первый доступный слот сумки'
L['Shift-Click']                = 'Shift + щелчок'
L['Ignore All Slots']           = 'Игнорировать все слоты'
L['Include All Slots']          = 'Включить все слоты'
