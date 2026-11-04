-- Loads Gears/Core/Namespace.lua outside WoW (release build, no DeveloperSetup)
-- and checks that ns:log returns callable printer and tracer functions.
-- Usage: lua dev/test-noop-log.lua

_G.LibStub = function() return {} end
_G.Mixin = function(obj) return obj end
_G.strupper = string.upper
_G.strtrim = function(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end
_G.CreateColorFromRGBHexString = function() return {} end
_G.LibPrettyPrint = {
  Formatter = function() return {} end,
  Printer = function() return function() end end,
}

local ns = {}
assert(loadfile('Gears/Core/Namespace.lua'))('Gears', ns)

local p, t = ns:log('X')
for _, check in ipairs({ { 'printer', p }, { 'tracer', t } }) do
  local name, fn = check[1], check[2]
  if type(fn) ~= 'function' then
    error(('ns:log(\'X\') %s: expected function, got %s'):format(name, type(fn)))
  end
  fn('hello')
end

print('PASS: ns:log returns callable printer and tracer')
