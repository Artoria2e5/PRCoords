-- Dump the eight-column test vector layout for py/checkvecs.py: input
-- lat, input lon, then wgs_gcj, gcj_bd and wgs_bd of the input pair.
-- Usage: lua lua/vecs.lua [inputs.tsv]

local here = (arg[0]:match("^(.*)[/\\]") or ".") .. "/PRCoords.lua"
local PRCoords = dofile(here)

local input = io.stdin
if arg[1] then
    local f, err = io.open(arg[1], "r")
    if not f then
        io.stderr:write("cannot open ", arg[1], ": ", err, "\n")
        os.exit(1)
    end
    input = f
end

for line in input:lines() do
    local lat_s, lon_s = line:match("^%s*([%d.eE+-]+)%s+([%d.eE+-]+)")
    if lat_s then
        local lat, lon = tonumber(lat_s), tonumber(lon_s)
        local wlat, wlon = PRCoords.wgs_gcj(lat, lon)
        local blat, blon = PRCoords.gcj_bd(lat, lon)
        local dlat, dlon = PRCoords.wgs_bd(lat, lon)
        print(string.format("%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g",
            lat, lon, wlat, wlon, blat, blon, dlat, dlon))
    end
end
