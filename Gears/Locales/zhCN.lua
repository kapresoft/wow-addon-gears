--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local p, t = ns:log('Locale_zhCN')

local L = ns:NewLocale('zhCN'); if not L then return end

--[[-------------------------------------------------------------------
Locale Values
---------------------------------------------------------------------]]
L['Set Name']              = '装备组名称'
L['Currently Equipped']    = '当前已装备'
L['Left-click']            = '左键点击'
L['Double-click']          = '双击'
L['Drag']                  = '拖动'
L['Available Actions']     = '可用操作'
L['Select']                = '选择'
L['Equip']                 = '装备'
L['Drag to an action bar'] = '拖动到快捷栏'
L['Equip While Combat']    = '战斗中无法更换装备组。'

L['Open Gears Panel']           = '打开 Gears 面板'
L['Create a new equipment set'] = '创建新的装备组'
L['New Equipment Set']          = '新装备组'
L['LibIconPicker Missing']      = '此功能需要 LibIconPicker。|n请确保已安装并启用 LibIconPicker，然后重新加载界面。'

L['Available commands:']                       = '可用命令：'
L['displays the addon info']                   = '显示插件信息'
L['equips the named or indexed equipment set'] = '按名称或索引装备指定的装备组'
L['Usage']                                     = '用法'
L['No such equipment set with name or index']  = '没有该名称或索引对应的装备组'
L['Equipped:']                                 = '已装备：'
L['Already Equipped:']                         = '已经装备：'
L['shows the currently equipped set, if any']  = '显示当前已装备的装备组（如有）'
L['No equipment set is currently equipped']    = '当前没有已装备的装备组'
L['lists all equipment sets']                  = '列出所有装备组'
L['No equipment sets found']                   = '未找到装备组'
L['Equipment Sets:']                           = '装备组：'
L['equipped']                                  = '已装备'

L['Select a set to enable slot actions'] = '选择一个装备组以启用槽位操作'
L['Include Slot']               = '包含槽位'
L['Include Slot::DESC']         = '保存装备组时包含此槽位'
L['Ignore Slot']                = '忽略槽位'
L['Ignore Slot::DESC']          = '保存装备组时排除此槽位'
L['Place item in bags']         = '将物品放入背包'
L['Place item in bags::DESC']   = '将已装备的物品移动到第一个可用的背包位置'
L['Shift-Click']                = 'Shift+点击'
L['Ignore All Slots']           = '忽略所有槽位'
L['Include All Slots']          = '包含所有槽位'
