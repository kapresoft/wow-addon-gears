-- Gears-OptionsUI/Init.lua
local gears = GEARS; if not gears then return end

--- @type Gears_OptionsUI_Namespace
local ns = select(2, ...)
local p, t = ns:log()
local cns, O, L = ns:cns()

local AceConfig = cns:AceConfig()
local AceConfigDialog = cns:AceConfigDialog()

local CONSOLE_COMMAND_OPTIONS = 'gears-options'

--[[-----------------------------------------------------------------------------
AddOn
-------------------------------------------------------------------------------]]
--- @class Gears_OptionsUI : AceAddon-3.0, AceEvent-3.0
local o = cns:AceAddon():NewAddon(ns.addon, 'AceEvent-3.0')
GEARS_OPTIONSUI = o

--[[-----------------------------------------------------------------------------
Options Table
-------------------------------------------------------------------------------]]
--- @return AceConfig.OptionsTable
local function CreateOptions()
  return {
    type = 'group',
    name = cns:GetVersion(),
    args = {
      general = {
        type = 'group',
        name = L['General'],
        order = 1,
        args = {
          announceEquip = {
            type = 'toggle',
            width = 'full',
            order = 1,
            name = L['Announce Equip in Chat'],
            desc = L['Announce Equip in Chat::DESC'],
            get = function() return cns:g().announceEquip end,
            set = function(_, val) cns:g().announceEquip = val end,
          },
        },
      },
    },
  }
end

function o:RegisterOptions()
  AceConfig:RegisterOptionsTable(cns.addon, CreateOptions(), { CONSOLE_COMMAND_OPTIONS })
end

--[[-------------------------------------------------------------------
Lifecycle Methods
---------------------------------------------------------------------]]
function o:OnInitialize() self:RegisterOptions() end
function o:OnEnable() self:SendMessage(ns:msg('OnEnable'), self) end
