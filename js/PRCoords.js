;(function(){
"use strict"
// <nowiki>
/**
 * People's Rectified [[T:Coord|Coordinates]]
 * @file Utils for inserting valid WGS-84 coords from GCJ-02/BD-09 input
 * @author User:Artoria2e5
 * @url https://github.com/Artoria2e5/PRCoords
 * 
 * @see [[:en:GCJ-02]]
 * @see https://github.com/caijun/geoChina (GPLv3)
 * @see https://github.com/googollee/eviltransform (MIT)
 * @see https://on4wp7.codeplex.com/SourceControl/changeset/view/21483#353936 (Anonymous)
 * @see https://github.com/zxteloiv/pycoordtrans (BSD-3)
 * 
 * @license CC0
 * To the greatest extent possible, this implementation of obfuscations designed
 * in hope that they will screw y'all up is dedicated into the public domain
 * under CC0 1.0 <https://creativecommons.org/publicdomain/zero/1.0/>.
 *
 * Happy geotagging/ingressing/whatever.
 * 
 * To make my FSF membership shine brighter, this conversion implementation is
 * additionally licensed under GPLv3+:
 * @license GPLv3+
 * @copyright 2016 Mingye Wang (User:Artoria2e5)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// Krasovsky 1940 ellipsoid
/// @const
var GCJ_A = 6378245
var GCJ_EE = 0.00669342162296594323 // f = 1/298.3; e^2 = 2*f - f**2

/// Epsilon to use for "exact" iterations.
/// Wanna troll? Use Number.EPSILON. 1e-13 in 15 calls for gcj.
/// @const
var PRC_EPS = 1e-5

/// Baidu's artificial deviations
/// @const
var BD_DLAT = 0.0060
var BD_DLON = 0.0065

/// Mean Earth Radius
/// @const
var EARTH_R = 6371000

/// Distance for haversine method; suitable over short distances like
/// conversion deviation checking
function distance(a, b) {
	function hav(θ) {
		return Math.pow(Math.sin(θ/2), 2)
	}
	
	var Δ = _coord_diff(a, b)
	return 2 * EARTH_R * Math.asin(Math.sqrt(
		hav(Δ.lat * Math.PI / 180) +
			Math.cos(a.lat * Math.PI / 180) *
			Math.cos(b.lat * Math.PI / 180) *
			hav(Δ.lon  * Math.PI / 180)
	))
}

function sanity_in_china_p(coords) {
	return coords.lat >= 0.8293 && coords.lat <= 55.8271 &&
           coords.lon >= 72.004 && coords.lon <= 137.8347
}

function _coord_diff(a, b) {
	return {
		lat: a.lat - b.lat,
		lon: a.lon - b.lon,
	}
}

function wgs_gcj(wgs, checkChina = true) {
	if (checkChina && !sanity_in_china_p(wgs)) {
		console.warn(`Non-Chinese coords found, returning as-is: ` +
					 `(${wgs.lat}, ${wgs.lon})`)
		return wgs
	}
	
	var x = wgs.lon - 105, y = wgs.lat - 35
	
	// These distortion functions accept (x = lon - 105, y = lat - 35).
	// They return distortions in terms of arc lengths, in meters.
	//
	// In other words, you can pretty much figure out how much you will be off
	// from WGS-84 just through evaulating them...
	// 
	// For example, at the (mapped) center of China (105E, 35N), you get a
	// default deviation of <300, -100> meters.
	var dLat_m = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y +
		0.2 * Math.sqrt(Math.abs(x)) + (
	        2 * Math.sin(x * 6 * Math.PI) + 2 * Math.sin(x * 2 * Math.PI) +
	        2 * Math.sin(y * Math.PI) + 4 * Math.sin(y / 3 * Math.PI) +
	        16 * Math.sin(y / 12 * Math.PI) + 32 * Math.sin(y / 30 * Math.PI)
        ) * 20 / 3
	var dLon_m = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
		0.1 * Math.sqrt(Math.abs(x)) + (
        	2 * Math.sin(x * 6 * Math.PI) + 2 * Math.sin(x * 2 * Math.PI) +
	        2 * Math.sin(x * Math.PI) + 4 * Math.sin(x / 3 * Math.PI) +
	        15 * Math.sin(x / 12 * Math.PI) + 30 * Math.sin(x / 30 * Math.PI)
        ) * 20 / 3
    
    
    var radLat = wgs.lat / 180 * Math.PI
    var magic = 1 - GCJ_EE * Math.pow(Math.sin(radLat), 2) // just a common expr
    
    // [[:en:Latitude#Length_of_a_degree_of_latitude]]
    var lat_deg_arclen = (Math.PI / 180) * (GCJ_A * (1 - GCJ_EE)) / Math.pow(magic, 1.5)
    // [[:en:Longitude#Length_of_a_degree_of_longitude]]
    var lon_deg_arclen = (Math.PI / 180) * (GCJ_A * Math.cos(radLat) / Math.sqrt(magic))
    
    // The screwers pack their deviations into degrees and disappear.
    // Note how they are mixing WGS-84 and Krasovsky 1940 ellipsoids here...
    return {
    	lat: wgs.lat + (dLat_m / lat_deg_arclen),
    	lon: wgs.lon + (dLon_m / lon_deg_arclen),
    }
}

// rev_transform_rough; accuracy ~2e-6 deg (meter-level)
function gcj_wgs(gcj, checkChina = true) {
	return _coord_diff(gcj, _coord_diff(wgs_gcj(gcj, checkChina), gcj))
}

function gcj_bd(gcj, __dummy__ = false) {
	var x = gcj.lon
	var y = gcj.lat
	
	// trivia: pycoordtrans actually describes how these values are calculated
	var r = Math.sqrt(x * x + y * y) + 0.00002 * Math.sin(y * Math.PI * 3000 / 180)
	var θ = Math.atan2(y, x) + 0.000003 * Math.cos(x * Math.PI * 3000 / 180)
	
	// Hard-coded default deviations again!
	return {
		lat: r * Math.sin(θ) + BD_DLAT,
		lon: r * Math.cos(θ) + BD_DLON,
	}
}

// Yes, we can implement a "precise" one too.
// accuracy ~1e-7 deg (decimeter-level; exceeds usual data accuracy)
function bd_gcj(bd, __dummy__ = false) {
	var x = bd.lon - BD_DLON
	var y = bd.lat - BD_DLAT
	
	// trivia: pycoordtrans actually describes how these values are calculated
	var r = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * Math.PI * 3000 / 180)
	var θ = Math.atan2(y, x) - 0.000003 * Math.cos(x * Math.PI * 3000 / 180)
	
	return {
		lat: r * Math.sin(θ),
		lon: r * Math.cos(θ),
	}
}

function bd_wgs(bd, checkChina = true) {
	return gcj_wgs(bd_gcj(bd), checkChina)
}

function wgs_bd(bd, checkChina = true) {
	return gcj_bd(wgs_gcj(bd, checkChina))
}

// generic "bored function" factory, Caijun 2014
// gcj: 4 calls to wgs_gcj; ~0.1mm acc
function __bored__(fwd, rev) {
	return function rev_bored(heck, checkChina = true) {
		var curr = rev(heck, checkChina)
		var diff = {lat: Infinity, lon: Infinity}
		
		// Wait till we hit fixed point or get bored
		var i = 0
		while (Math.max(Math.abs(diff.lat), Math.abs(diff.lon)) > PRC_EPS && i++ < 10) {
			diff = _coord_diff(fwd(curr, checkChina), heck)
			curr = _coord_diff(curr, diff)
		}
		
		return curr
	}
}

var exports = {
	distance: distance,
	wgs_gcj: wgs_gcj,
	gcj_wgs: gcj_wgs,
	gcj_bd: gcj_bd,
	bd_gcj: bd_gcj,
	wgs_bd: wgs_bd,
	bd_wgs: bd_wgs,
	
	// Precise functions using caijun 2014 method
	//
	// Why "bored"? Because they usually exceed source data accuracy -- the
	// original GCJ implementation contains noise from a linear-modulo PRNG,
	// and Baidu seems to do similar things with their API too.
	__bored__: __bored__,
	gcj_wgs_bored: __bored__(wgs_gcj, gcj_wgs),
	bd_gcj_bored: __bored__(gcj_bd, bd_gcj),
	bd_wgs_bored: __bored__(wgs_bd, bd_wgs),
}

if (typeof module === "object" && module.exports) {
	module.exports = exports
} else if (typeof window !== "undefined") {
	window.PRCoords = exports
}
})();
