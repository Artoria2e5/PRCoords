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

from math import asin, sin, cos, sqrt, atan2, radians, pi, pow
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
    '''Tuple of (latitude, longitude) in degrees, with some helper methods.'''
    def __add__(self, other):
        return Coords(self.lat + other.lat, self.lon + other.lon)

    def __sub__(self, other):
        return Coords(self.lat - other.lat, self.lon - other.lon)

    def __abs__(self):
        return sqrt(self.lat * self.lat + self.lon * self.lon)

    def distance(self, other):
        '''
        Distance for haversine method; suitable over short distances like
        conversion deviation checking
        '''
        hav = lambda theta: sin(theta / 2) ** 2

        delta = self - other
        return 2 * EARTH_R * asin(sqrt(
            hav(radians(delta.lat)) +
            cos(radians(self.lat)) *
            cos(radians(other.lat)) *
            hav(radians(delta.lon))
        ))

def sanity_in_china_p(coords):
    '''Roughly check if the coordinates are in China. GCJ-02 and BD-09 are only defined in China.'''
    return (0.8293 <= coords.lat <= 55.8271 and
            72.004 <= coords.lon <= 137.8347)

def wgs_gcj(wgs, check_china=True):
    '''Transform WGS-84 to GCJ-02.'''
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
        0.2 * sqrt(abs(x)) + (
            2 * sin(x * 6 * pi) + 2 * sin(x * 2 * pi) +
            2 * sin(y * pi) + 4 * sin(y / 3 * pi) +
            16 * sin(y / 12 * pi) + 32 * sin(y / 30 * pi)
        ) * 20 / 3)
    dLon_m = (300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
        0.1 * sqrt(abs(x)) + (
            2 * sin(x * 6 * pi) + 2 * sin(x * 2 * pi) +
            2 * sin(x * pi) + 4 * sin(x / 3 * pi) +
            15 * sin(x / 12 * pi) + 30 * sin(x / 30 * pi)
        ) * 20 / 3)

    radLat = radians(wgs.lat)
    magic = 1 - GCJ_EE * pow(sin(radLat), 2) # just a common expr

    # [[:en:Latitude#Length_of_a_degree_of_latitude]]
    lat_deg_arclen = radians((GCJ_A * (1 - GCJ_EE)) / pow(magic, 1.5))
    # [[:en:Longitude#Length_of_a_degree_of_longitude]]
    lon_deg_arclen = radians(GCJ_A * cos(radLat) / sqrt(magic))

    # The screwers pack their deviations into degrees and disappear.
    # Note how they are mixing WGS-84 and Krasovsky 1940 ellipsoids here...
    return Coords(wgs.lat + (dLat_m / lat_deg_arclen),
                  wgs.lon + (dLon_m / lon_deg_arclen))

def gcj_wgs(gcj, check_china=True):
    '''Transform GCJ-02 to WGS-84. Roundtrip ~2e-6 deg (meter-level).'''
    gcj = Coords(*gcj)
    return gcj - (wgs_gcj(gcj, check_china) - gcj)

def gcj_bd(gcj, _dummy=False):
    '''Transform GCJ-02 to BD-09.'''
    y, x = gcj

    # trivia: pycoordtrans actually describes how these values are calculated
    r = sqrt(x * x + y * y) + 0.00002 * sin(radians(y) * 3000)
    theta = atan2(y, x) + 0.000003 * cos(radians(x) * 3000)

    # Hard-coded default deviations again!
    return Coords(r * sin(theta) + BD_DLAT, r * cos(theta) + BD_DLON)

# Yes, we can implement a "precise" one too.
def bd_gcj(bd, _dummy=False):
    '''Transform BD-09 to GCJ-02. Roundtrip ~2e-7 deg (decimeter-level).'''
    bd = Coords(*bd)
    x = bd.lon - BD_DLON
    y = bd.lat - BD_DLAT

    # trivia: pycoordtrans actually describes how these values are calculated
    r = sqrt(x * x + y * y) - 0.00002 * sin(radians(y) * 3000)
    theta = atan2(y, x) - 0.000003 * cos(radians(x) * 3000)

    return Coords(r * sin(theta), r * cos(theta))

def bd_wgs(bd, check_china=True):
    '''Transform BD-09 to WGS-84. Roundtrip ~2e-6 deg (meter-level).'''
    return gcj_wgs(bd_gcj(bd), check_china)

def wgs_bd(bd, check_china=True):
    '''Transform WGS-84 to BD-09.'''
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

    rev_bored.__name__ = rev.__name__ + '_bored'
    rev_bored.__doc__ = rev.__doc__ + ' with iterative refinement for better accuracy.'
    return rev_bored

# Precise functions using caijun 2014 method
# 
# Why "bored"? Because they usually exceed source data accuracy -- the
# original GCJ implementation contains noise from a linear-modulo PRNG,
# and Baidu seems to do similar things with their API too.

gcj_wgs_bored = _bored(wgs_gcj, gcj_wgs)
bd_gcj_bored = _bored(gcj_bd, bd_gcj)
bd_wgs_bored = _bored(wgs_bd, bd_wgs)
