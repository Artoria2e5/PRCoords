using Printf
include(joinpath(@__DIR__, "src", "PRCoords.jl"))
using .PRCoords

io = isempty(ARGS) ? stdin : open(ARGS[1])
for line in eachline(io)
    parts = split(line)
    length(parts) < 2 && continue
    lat = tryparse(Float64, parts[1])
    lon = tryparse(Float64, parts[2])
    (lat === nothing || lon === nothing) && continue
    p = Coords(lat, lon)
    w = wgs_gcj(p)
    g = gcj_bd(p)
    b = wgs_bd(p)
    @printf("%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\n",
            lat, lon, w.lat, w.lon, g.lat, g.lon, b.lat, b.lon)
end
isempty(ARGS) || close(io)
