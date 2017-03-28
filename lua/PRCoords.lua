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

function PRCoords.distance(a_lat, a_lon, b_lat, b_lon)
	local function hav(theta)
		return Math.pow(Math.sin(theta/2), 2)
	end
	
	local delta_lat = a_lat - b_lat
	local delta_lon = a_lon - b_lon
	
	return 2 * PRCoords.EARTH_R * math.asin(math.sqrt(
		hav(delta_lat * math.pi / 180) +
			math.cos(a.lat * math.pi / 180) *
			math.cos(b.lat * math.pi / 180) *
			hav(delta_lon  * math.pi / 180)))
end

