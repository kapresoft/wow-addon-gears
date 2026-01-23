--- @type Namespace
local ns = select(2, ...)
--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class SimpleLoggerColor
--- @field hex string
--- @field c ColorMixin
--- @field w fun(text:string) : string

--- @class LogColor
--- @field LOG_NAME SimpleLoggerColor
--- @field MOD_PREFIX SimpleLoggerColor
--- @field KEY SimpleLoggerColor
--- @field VALUE SimpleLoggerColor

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, date, unpack = string.format, date, unpack

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ADDON_LOG_NAME   = 'GRS'

local COLORS = {
    LOG_NAME   = 'ff32CF21',
    MOD_PREFIX = 'ff9CFF9C',
    KEY        = 'ffB8BA00',
    VALUE      = 'ffFFFFFF',
}

--- Color Definitions
(function()
    --- @param hex string
    local function Methods(hex)
        local o = {}; o.hex   = hex
        o.c = CreateColorFromHexString(o.hex)
        assert(o.c, sformat('Invalid hex color: %s', tostring(hex)))
        function o.w(text) return o.c:WrapTextInColorCode(text) end
        return o
    end;
    for c, hexColor in pairs(COLORS) do COLORS[c] = Methods(hexColor) end
end)()

--- @type LogColor
local C = COLORS
local logName = C.LOG_NAME.w(ADDON_LOG_NAME)

local function tpack(...) return { n = select("#", ...), ... } end
local function valToStr(tbl)
    if tbl == nil then return "nil" end
    if type(tbl) ~= "table" then return tostring(tbl) end
    if next(tbl) == nil then return "{}" end

    local out = {}
    for k, v in pairs(tbl) do
        local key   = C.KEY.w(tostring(k))
        local value = C.VALUE.w(tostring(v))
        out[#out + 1] = key .. "=" .. value
    end

    return "{ " .. table.concat(out, ", ") .. " }"
end
local formatter = pformat or valToStr

--- @alias LoggerFn fun(...: any) : void LoggerFn A callable logger function, behaves like print

--- Creates a scoped logger function with a fixed prefix.
--- The returned function behaves like `print`, but automatically
--- prefixes all output with the provided name.
---
--- ### Usage
--- ```
--- local p = ns:Log('Gears')
--- p('Selected:', val)
--- local tbl = { ['hello']='there'}
--- p('Table Val:', pformat(tbl))
--- ```
--- @param prefix Name The log prefix name
--- @return LoggerFn LoggerFn A callable logger function, behaves like print
function ns:Log(prefix)
    assert(type(prefix) == "string", "Prefix name must be a string.")
    if not ns:IsDev() then return function() end end

    local sPrefix = sformat("{{%s::%s}}:", logName, C.MOD_PREFIX.w(prefix))

    return function(...)
        local args = tpack(...)
        for i = 1, args.n do
            if type(args[i]) == "table" then
                args[i] = formatter(args[i])
            end
        end

        print("[" .. date("%H:%M:%S") .. "]", sPrefix, unpack(args, 1, args.n))
    end
end

