-- People's Rectified Coordinates
-- https://github.com/Artoria2e5/PRCoords
--
-- Dedicated to the Public Domain under CC0
-- Artoria2e5, 2017.
--
-- Lua 5.1 or newer.

local PRCoords = {
    EARTH_R = 6371000,

    -- Krasovsky 1940, the ellipsoid GCJ-02 pretends to use.
    GCJ_A = 6378245,
    GCJ_EE = 0.00669342162296594323, -- f = 1/298.3; e^2 = 2*f - f^2

    -- Baidu's artificial deviations.
    BD_DLAT = 0.0060,
    BD_DLON = 0.0065,

    -- Caijun refinement stops when the residual is this small, in degrees.
    PRC_EPS = 1e-5,
}

local sin, cos, sqrt, abs, rad, pi = math.sin, math.cos, math.sqrt,
    math.abs, math.rad, math.pi

-- math.atan takes (y, x) from 5.3 on; math.atan2 fills that role before.
local atan2 = math.atan2 or math.atan

local function sinpi(x)
    return sin(pi * x)
end

local function cospi(x)
    return cos(pi * x)
end

function PRCoords.in_china(lat, lon)
    return 0.8293 <= lat and lat <= 55.8271 and
        72.004 <= lon and lon <= 137.8347
end

-- The distortions at (lat, lon), in metres of arc. GCJ-02 is specified as a
-- polynomial in x = lon - 105 and y = lat - 35, and the metres are what the
-- polynomials actually produce; converting to degrees is the caller's job.
function PRCoords.deviation_m(lat, lon)
    local x, y = lon - 105, lat - 35

    local dlat_m = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y +
        0.2 * sqrt(abs(x)) +
        (2 * sinpi(6 * x) + 2 * sinpi(2 * x) + 2 * sinpi(y) +
         4 * sinpi(y / 3) + 16 * sinpi(y / 12) + 32 * sinpi(y / 30)) * 20 / 3

    local dlon_m = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
        0.1 * sqrt(abs(x)) +
        (2 * sinpi(6 * x) + 2 * sinpi(2 * x) + 2 * sinpi(x) +
         4 * sinpi(x / 3) + 15 * sinpi(x / 12) + 30 * sinpi(x / 30)) * 20 / 3

    return dlat_m, dlon_m
end

-- The deviation in degrees for a WGS-84 point.
local function delta(lat, lon)
    local dlat_m, dlon_m = PRCoords.deviation_m(lat, lon)

    local radlat = rad(lat)
    local magic = 1 - PRCoords.GCJ_EE * sin(radlat) ^ 2
    local lat_deg_arclen = rad(PRCoords.GCJ_A * (1 - PRCoords.GCJ_EE) /
        magic ^ 1.5)
    local lon_deg_arclen = rad(PRCoords.GCJ_A * cos(radlat) / sqrt(magic))

    return dlat_m / lat_deg_arclen, dlon_m / lon_deg_arclen
end

function PRCoords.wgs_gcj(wlat, wlon, check_china)
    if (check_china == nil or check_china) and
        not PRCoords.in_china(wlat, wlon) then
        return wlat, wlon
    end
    local dlat, dlon = delta(wlat, wlon)
    return wlat + dlat, wlon + dlon
end

function PRCoords.gcj_wgs(gcj_lat, gcj_lon, check_china)
    local wlat, wlon = PRCoords.wgs_gcj(gcj_lat, gcj_lon, check_china)
    return 2 * gcj_lat - wlat, 2 * gcj_lon - wlon
end

function PRCoords.gcj_bd(gcj_lat, gcj_lon)
    local y, x = gcj_lat, gcj_lon

    local r = sqrt(x * x + y * y) + 0.00002 * sinpi(y * 3000 / 180)
    local theta = atan2(y, x) + 0.000003 * cospi(x * 3000 / 180)

    return r * sin(theta) + PRCoords.BD_DLAT,
        r * cos(theta) + PRCoords.BD_DLON
end

function PRCoords.bd_gcj(bd_lat, bd_lon)
    local x, y = bd_lon - PRCoords.BD_DLON, bd_lat - PRCoords.BD_DLAT

    local r = sqrt(x * x + y * y) - 0.00002 * sinpi(y * 3000 / 180)
    local theta = atan2(y, x) - 0.000003 * cospi(x * 3000 / 180)

    return r * sin(theta), r * cos(theta)
end

function PRCoords.bd_wgs(bd_lat, bd_lon, check_china)
    local g_lat, g_lon = PRCoords.bd_gcj(bd_lat, bd_lon)
    return PRCoords.gcj_wgs(g_lat, g_lon, check_china)
end

function PRCoords.wgs_bd(wlat, wlon, check_china)
    local g_lat, g_lon = PRCoords.wgs_gcj(wlat, wlon, check_china)
    return PRCoords.gcj_bd(g_lat, g_lon)
end

-- Caijun 2014 fixed-point refinement, called "bored" because the result
-- outruns the noise in the source data anyway.
local function bored(fwd, rev)
    return function(bad_lat, bad_lon, check_china)
        local wlat, wlon = rev(bad_lat, bad_lon, check_china)
        local diff_lat, diff_lon = 99, 99
        local i = 0

        while i < 10 and sqrt(diff_lat * diff_lat + diff_lon * diff_lon) >
            PRCoords.PRC_EPS do
            local tlat, tlon = fwd(wlat, wlon, false)
            diff_lat, diff_lon = tlat - bad_lat, tlon - bad_lon
            wlat, wlon = wlat - diff_lat, wlon - diff_lon
            i = i + 1
        end

        return wlat, wlon
    end
end

PRCoords.gcj_wgs_bored = bored(PRCoords.wgs_gcj, PRCoords.gcj_wgs)
PRCoords.bd_gcj_bored = bored(PRCoords.gcj_bd, PRCoords.bd_gcj)
PRCoords.bd_wgs_bored = bored(PRCoords.wgs_bd, PRCoords.bd_wgs)

function PRCoords.cdiff(a_lat, a_lon, b_lat, b_lon)
    return a_lat - b_lat, a_lon - b_lon
end

-- Haversine distance, fine over the short distances seen when checking
-- conversion deviations.
function PRCoords.distance(a_lat, a_lon, b_lat, b_lon)
    local function hav(theta)
        return sin(theta / 2) ^ 2
    end

    local dlat, dlon = a_lat - b_lat, a_lon - b_lon

    return 2 * PRCoords.EARTH_R * math.asin(sqrt(
        hav(rad(dlat)) +
        cos(rad(a_lat)) * cos(rad(b_lat)) * hav(rad(dlon))))
end

PRCoords.cdist = PRCoords.distance

return PRCoords
