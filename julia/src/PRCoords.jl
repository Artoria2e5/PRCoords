module PRCoords

export Coords, in_china, distance
export wgs_gcj, wgs_gcj_nc, gcj_wgs, gcj_wgs_nc, gcj_bd, bd_gcj
export wgs_bd, wgs_bd_nc, bd_wgs, bd_wgs_nc
export gcj_wgs_bored, bd_gcj_bored, bd_wgs_bored

struct Coords
    lat::Float64
    lon::Float64
end

Base.:+(a::Coords, b::Coords) = Coords(a.lat + b.lat, a.lon + b.lon)
Base.:-(a::Coords, b::Coords) = Coords(a.lat - b.lat, a.lon - b.lon)
Base.abs(p::Coords) = sqrt(p.lat * p.lat + p.lon * p.lon)
Base.show(io::IO, p::Coords) = print(io, "Coords(", p.lat, ", ", p.lon, ")")

const GCJ_A = 6378245.0
const GCJ_EE = 0.00669342162296594323
const BD_DLAT = 0.006
const BD_DLON = 0.0065
const EARTH_R = 6371000.0
const PRC_EPS = 1e-5

in_china(p::Coords) =
    0.8293 <= p.lat <= 55.8271 && 72.004 <= p.lon <= 137.8347

function wgs_gcj_nc(p::Coords)
    x = p.lon - 105
    y = p.lat - 35
    dlat = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y +
        0.2 * sqrt(abs(x)) +
        (2 * sinpi(x * 6) + 2 * sinpi(x * 2) + 2 * sinpi(y) +
         4 * sinpi(y / 3) + 16 * sinpi(y / 12) + 32 * sinpi(y / 30)) * 20 / 3
    dlon = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
        0.1 * sqrt(abs(x)) +
        (2 * sinpi(x * 6) + 2 * sinpi(x * 2) + 2 * sinpi(x) +
         4 * sinpi(x / 3) + 15 * sinpi(x / 12) + 30 * sinpi(x / 30)) * 20 / 3
    magic = 1 - GCJ_EE * sinpi(p.lat / 180)^2
    Coords(
        p.lat + dlat / ((GCJ_A * (1 - GCJ_EE) / magic^1.5) * (pi / 180)),
        p.lon + dlon / ((GCJ_A * cospi(p.lat / 180) / sqrt(magic)) * (pi / 180))
    )
end

wgs_gcj(p::Coords; check_china::Bool = true) =
    check_china && !in_china(p) ? p : wgs_gcj_nc(p)

gcj_wgs_nc(p::Coords) = p - (wgs_gcj_nc(p) - p)

gcj_wgs(p::Coords; check_china::Bool = true) =
    check_china && !in_china(p) ? p : gcj_wgs_nc(p)

function gcj_bd(p::Coords)
    y, x = p.lat, p.lon
    r = sqrt(x * x + y * y) + 0.00002 * sinpi(y * 3000 / 180)
    theta = atan(y, x) + 0.000003 * cospi(x * 3000 / 180)
    Coords(r * sin(theta) + BD_DLAT, r * cos(theta) + BD_DLON)
end

function bd_gcj(p::Coords; check_china::Bool = true)
    x = p.lon - BD_DLON
    y = p.lat - BD_DLAT
    r = sqrt(x * x + y * y) - 0.00002 * sinpi(y * 3000 / 180)
    theta = atan(y, x) - 0.000003 * cospi(x * 3000 / 180)
    Coords(r * sin(theta), r * cos(theta))
end

wgs_bd_nc(p::Coords) = gcj_bd(wgs_gcj_nc(p))

wgs_bd(p::Coords; check_china::Bool = true) =
    check_china && !in_china(p) ? p : wgs_bd_nc(p)

bd_wgs_nc(p::Coords) = gcj_wgs_nc(bd_gcj(p))

bd_wgs(p::Coords; check_china::Bool = true) =
    check_china && !in_china(p) ? p : bd_wgs_nc(p)

function bored(fwd, rev)
    function (p::Coords; check_china::Bool = true)
        out = rev(p; check_china)
        diff = Coords(99, 99)
        for _ in 1:10
            abs(diff) <= PRC_EPS && break
            diff = fwd(out) - p
            out -= diff
        end
        out
    end
end

const gcj_wgs_bored = bored(wgs_gcj_nc, gcj_wgs)
const bd_gcj_bored = bored(gcj_bd, bd_gcj)
const bd_wgs_bored = bored(wgs_bd_nc, bd_wgs)

function distance(p::Coords, q::Coords)
    hav(d) = sinpi(d / 360)^2
    a = hav(p.lat - q.lat) +
        cospi(p.lat / 180) * cospi(q.lat / 180) * hav(p.lon - q.lon)
    2 * EARTH_R * asin(sqrt(a))
end

end
