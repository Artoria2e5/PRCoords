'''
People's Rectified [[T:Coord|Coordinates]]
@file Utils for inserting valid WGS-84 coords from GCJ-02/BD-09 input
@author User:Artoria2e5
@url https://github.com/Artoria2e5/PRCoords

@see [[:en:GCJ-02]]
@see https://github.com/caijun/geoChina (GPLv3)
@see https://github.com/googollee/eviltransform (MIT)
@see https://on4wp7.codeplex.com/SourceControl/changeset/view/21483#353936 (Anonymous)
@see https://github.com/zxteloiv/pycoordtrans (BSD-3)

@license CC0
To the greatest extent possible, this implementation of obfuscations designed
in hope that they will screw y'all up is dedicated into the public domain
under CC0 1.0 <https://creativecommons.org/publicdomain/zero/1.0/>.

Happy geotagging/ingressing/whatever.

To make my FSF membership shine brighter, this conversion implementation is
additionally licensed under GPLv3+:
@license GPLv3+
@copyright 2016 Mingye Wang (User:Artoria2e5)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import math
import warnings
import collections

# Krasovsky 1940 ellipsoid
# @const
GCJ_A = 6378245
GCJ_EE = 0.00669342162296594323 # f = 1/298.3; e^2 = 2*f - f**2

# Epsilon to use for "exact" iterations.
# Wanna troll? Use Number.EPSILON. 1e-13 in 15 calls for gcj.
# @const
PRC_EPS = 1e-5

# Baidu's artificial deviations
# @const
BD_DLAT = 0.0060
BD_DLON = 0.0065

# Mean Earth Radius
# @const
EARTH_R = 6371000

class Coords(collections.namedtuple('Coords', 'lat lon')):
    def __add__(self, other):
        return Coords(self.lat + other.lat, self.lon + other.lon)

    def __sub__(self, other):
        return Coords(self.lat - other.lat, self.lon - other.lon)

    def __abs__(self):
        return math.hypot(*self)

    def distance(self, other):
        '''
        Distance for haversine method; suitable over short distances like
        conversion deviation checking
        '''
        hav = lambda theta: math.sin(theta / 2) ** 2

        delta = self - other
        return 2 * EARTH_R * math.asin(math.sqrt(
            hav(math.radians(delta.lat)) +
            math.cos(math.radians(self.lat)) *
            math.cos(math.radians(other.lat)) *
            hav(math.radians(delta.lon))
        ))

def sanity_in_china_p(coords):
    return (0.8293 <= coords.lat <= 55.8271 and
            72.004 <= coords.lon <= 137.8347)

def wgs_gcj(wgs, check_china=True):
    wgs = Coords(*wgs)
    if check_china and not sanity_in_china_p(wgs):
        warnings.warn('Non-Chinese coords found, returning as-is: %r' % (wgs,))
        return wgs

    x, y = wgs.lon - 105, wgs.lat - 35

    # These distortion functions accept (x = lon - 105, y = lat - 35).
    # They return distortions in terms of arc lengths, in meters.

    # In other words, you can pretty much figure out how much you will be off
    # from WGS-84 just through evaulating them...
    #
    # For example, at the (mapped) center of China (105E, 35N), you get a
    # default deviation of <300, -100> meters.
    dLat_m = (-100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y +
        0.2 * math.sqrt(abs(x)) + (
            2 * math.sin(x * 6 * math.pi) + 2 * math.sin(x * 2 * math.pi) +
            2 * math.sin(y * math.pi) + 4 * math.sin(y / 3 * math.pi) +
            16 * math.sin(y / 12 * math.pi) + 32 * math.sin(y / 30 * math.pi)
        ) * 20 / 3)
    dLon_m = (300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
        0.1 * math.sqrt(abs(x)) + (
            2 * math.sin(x * 6 * math.pi) + 2 * math.sin(x * 2 * math.pi) +
            2 * math.sin(x * math.pi) + 4 * math.sin(x / 3 * math.pi) +
            15 * math.sin(x / 12 * math.pi) + 30 * math.sin(x / 30 * math.pi)
        ) * 20 / 3)

    radLat = math.radians(wgs.lat)
    magic = 1 - GCJ_EE * math.pow(math.sin(radLat), 2) # just a common expr

    # [[:en:Latitude#Length_of_a_degree_of_latitude]]
    lat_deg_arclen = math.radians((GCJ_A * (1 - GCJ_EE)) * math.pow(magic, 1.5))
    # [[:en:Longitude#Length_of_a_degree_of_longitude]]
    lon_deg_arclen = math.radians(GCJ_A * math.cos(radLat) / math.sqrt(magic))

    # The screwers pack their deviations into degrees and disappear.
    # Note how they are mixing WGS-84 and Krasovsky 1940 ellipsoids here...
    return Coords(wgs.lat + (dLat_m / lat_deg_arclen),
                  wgs.lon + (dLon_m / lon_deg_arclen))

def gcj_wgs(gcj, check_china=True):
    '''rev_transform_rough; accuracy ~2e-6 deg (meter-level)'''
    gcj = Coords(*gcj)
    return gcj - (wgs_gcj(gcj, check_china) - gcj)

def gcj_bd(gcj, _dummy=False):
    y, x = gcj

    # trivia: pycoordtrans actually describes how these values are calculated
    r = math.sqrt(x * x + y * y) + 0.00002 * math.sin(math.radians(y) * 3000)
    theta = math.atan2(y, x) + 0.000003 * math.cos(math.radians(x) * 3000)

    # Hard-coded default deviations again!
    return Coords(r * math.sin(theta) + BD_DLAT, r * math.cos(theta) + BD_DLON)

# Yes, we can implement a "precise" one too.
def bd_gcj(bd, _dummy=False):
    '''accuracy ~1e-7 deg (decimeter-level; exceeds usual data accuracy)'''
    bd = Coords(*bd)
    x = bd.lon - BD_DLON
    y = bd.lat - BD_DLAT

    # trivia: pycoordtrans actually describes how these values are calculated
    r = math.sqrt(x * x + y * y) - 0.00002 * math.sin(math.radians(y) * 3000)
    theta = math.atan2(y, x) - 0.000003 * math.cos(math.radians(x) * 3000)

    return Coords(r * math.sin(theta), r * math.cos(theta))

def bd_wgs(bd, check_china=True):
    return gcj_wgs(bd_gcj(bd), check_china)

def wgs_bd(bd, check_china=True):
    return gcj_bd(wgs_gcj(bd, check_china))

def _bored(fwd, rev):
    '''
    generic "bored function" factory, Caijun 2014
    gcj: 4 calls to wgs_gcj; ~0.1mm acc
    '''
    def rev_bored(bad, check_china=True):
        wgs = rev(bad)
        bad = Coords(*bad)
        diff = Coords(99, 99) # canary

        # Wait till we hit fixed point or get bored
        i = 0
        while i < 10 and abs(diff) > PRC_EPS:
            diff = fwd(wgs, False) - bad
            wgs = wgs - diff
            i += 1

        return wgs

    return rev_bored

# Precise functions using caijun 2014 method
# 
# Why "bored"? Because they usually exceed source data accuracy -- the
# original GCJ implementation contains noise from a linear-modulo PRNG,
# and Baidu seems to do similar things with their API too.

gcj_wgs_bored = _bored(wgs_gcj, gcj_wgs)
bd_gcj_bored = _bored(gcj_bd, bd_gcj)
bd_wgs_bored = _bored(wgs_bd, bd_wgs)
