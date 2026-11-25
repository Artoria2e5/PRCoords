-- [[Module:PRCoords]]
-- MediaWiki front end for Module:PRCoords/inner (a copy of lua/PRCoords.lua).
--
-- This started as a copy of Module:ustring's dispatcher, which is built
-- around string arguments: s1, s2, ... escape the tonumber() conversion and
-- backslashes get stripped. Coordinates are numbers, so the positional
-- arguments here are simply coerced, and the multiple return values of a
-- transform are joined into one string, since Scribunto concatenates return
-- values without a separator.

local unpack = table.unpack or unpack
pcall(require, 'strict') -- Scribunto only; harmless elsewhere

local ok, p = pcall(require, 'Module:PRCoords/inner')
if not ok then
    p = require('PRCoords') -- for running outside MediaWiki
end

-- Positional arguments, or a lat=/lon= pair for template-style calls.
local function positional(fargs)
    local args = {}
    local i = 1
    while fargs[i] ~= nil do
        args[i] = tonumber(fargs[i]) or fargs[i]
        i = i + 1
    end
    if #args == 0 and fargs.lat and fargs.lon then
        args = {
            tonumber(fargs.lat) or fargs.lat,
            tonumber(fargs.lon) or fargs.lon,
        }
    end
    return args
end

local function render(results, sep)
    local parts = {}
    for i = 1, #results do
        parts[i] = tostring(results[i])
    end
    return table.concat(parts, sep or ', ')
end

return setmetatable({}, {
    __index = function(_, k)
        local what = p[k]
        if type(what) ~= 'function' then
            return what
        end
        return function(frame)
            local fargs = frame.args
            local results = { what(unpack(positional(fargs))) }
            local text = render(results, fargs.sep)
            if not fargs.tag then
                return text
            end
            local tagargs = {}
            for name, value in pairs(fargs) do
                if type(name) ~= 'number' and name ~= 'tag'
                    and name ~= 'sep' and name ~= 'lat' and name ~= 'lon' then
                    tagargs[name] = value
                end
            end
            return frame:extensionTag { name = fargs.tag, content = text,
                                        args = tagargs }
        end
    end
})
