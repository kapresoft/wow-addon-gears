--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local Table = ns.O.Table
local tbl_DeepCopy = Table.DeepCopy

--[[-------------------------------------------------------------------
Type Definitions
---------------------------------------------------------------------]]
--  ================================================
--- @class DatabaseObj : AceDBObject-3.0
--- @field global GlobalConfig
--- @field profile ProfileConfig
--- @field char table?
--- @field realm table?
--- @field factionrealm table?

--  ================================================
--- @class GlobalConfig
--- @field schemaVersion number
--- @field isInitialShowComplete boolean @True after Gears has been shown once on first PaperDoll open; used to prevent auto-show on subsequent opens

--  ================================================
--- @class ProfileConfig

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema
-------------------------------------------------------------------------------]]

--- @see NamespaceObjects
local libName = 'DatabaseSchema'

--- @class DatabaseSchema
local o = {}; ns.O.DatabaseSchema = o
local p, pd, t, tf = ns:log(libName)
--[[-------------------------------------------------------------------
Default Database
---------------------------------------------------------------------]]
local DB_VERSION = 1

--- @type DatabaseObj
local DEFAULT_DB = {
  global = { schemaVersion = DB_VERSION, isInitialShowComplete = false },
  profile = {},
  char = {},
}

--[[-----------------------------------------------------------------------------
Module::DatabaseSchema (Methods)
-------------------------------------------------------------------------------]]

--- @return DatabaseObj
function o:GetDefaultDatabase()
  local db = tbl_DeepCopy(DEFAULT_DB); return db
end
