-- People's Rectified Coordinates
-- https://github.com/Artoria2e5/PRCoords
--
-- Dedicated to the Public Domain under CC0
-- Artoria2e5, 2017.

PRCoords = {
    ["EARTH_R"] = 6371000
}

-- Ray-casting polygon
function PRCoords._in_poly(xs, ys, x, y)
	assert(#xs == #ys, "poly length don't match")
	local inside = false
	
	for i=1,#xs do
		if (ys[i] > y) ~= (ys[j] > y) and
		   (x < (xs[j] - xs[i]) * (y - ys[i]) / (ys[j] - ys[i]) + xs[i]) then
			inside = (not inside)
		end
	end
	return inside
end

local function bind_poly(xs, ys)
	return function(x, y)
		return PRCoords._in_poly(xs, ys, x, y)
	end
end

function PRCoords.cdiff(a_lat, a_lon, b_lat, b_lon)
	return a_lat - b_lat, a_lon - b_lon
end

local function cerr(lat, lon)
	return abs(lat) + abs(lon)
end

function PRCoords.cdist(a_lat, a_lon, b_lat, b_lon)
	local function hav(theta)
		return math.sin(theta/2) ^ 2
	end
	
	local delta_lat = a_lat - b_lat
	local delta_lon = a_lon - b_lon
	
	return 2 * PRCoords.EARTH_R * math.asin(math.sqrt(
		hav(delta_lat * math.pi / 180) +
		math.cos(a.lat * math.pi / 180) *
		math.cos(b.lat * math.pi / 180) *
		hav(delta_lon  * math.pi / 180)))
end

function PRCoords.caijun(forward, reverse)
	return function(bad_lat, bad_lon)
		local guess_lat, guess_lon = reverse(bad_lat, bad_lon)
		local iter = 0
		local diff_lat, diff_lon, tlat, tlon
		
		repeat
			tlat, tlon = forward(guess_lat, guess_lon)
			diff_lat, diff_lon = PRCoords.cdiff(tlat, tlon, bad_lat, bad_lon)
			guess_lat -= diff_lat
			guess_lon -= diff_lon
			iter += 1
		until cerr(diff_lat, diff_lon) <= 1e-5 or iter >= 10
	end
end
	
function PRCoords.wgs_gcj(wlat, wlon)
	local y, x = wlon - 105, wlat - 35
	
end
