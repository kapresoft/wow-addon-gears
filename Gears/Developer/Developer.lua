
--- @type Namespace
local ns = select(2, ...)
local eq = C_EquipmentSet
local LibIconPickerUtil = ns.O.LibIconPickerUtil

local p, t = ns:log('Developer')

--- @class Gears_Developer
local o = {}; gdev = o

-- /dump gdev:item()
function o:item()
  local link = select(2, C_Item.GetItemInfo('ley staff'))
  --return C_Item.GetItemInfo(link)
  return ns.O.ItemUtil:GetItem(link)
end

function o:PickIcon()
  --- @type LibIconPicker_Options
  local opt = {
    icon = 132111, showTextInput = true,
    textInput = { label = 'Set Name:', value = 'xx' }
  }
  LibIconPickerUtil:Get(function(lip)
    lip:Open(function(sel)
      p('Sel:', sel)
    end, opt)
  end)
end

function o:eqDel(index)
  if not index then return self:eqIds() end
  
  local del = index
  local deleted = { eq.GetEquipmentSetInfo(del) }
  eq.DeleteEquipmentSet(del)
  return { deleted = deleted, remaining = self:eqIds() }
end

function o:eqIds()
  --- @type table<number,number>
  local ids    = eq.GetEquipmentSetIDs()
  local result = {}
  for i, id in ipairs(ids) do
    local name, iconFileID = eq.GetEquipmentSetInfo(id)
    table.insert(result, { id =id, name = name, icon = iconFileID })
  end
  return result
end

-- /dump gdev:resetAnnouncements()
function o:resetAnnouncements()
  ns:g().announcementsShown = {}
end


