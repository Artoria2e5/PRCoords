#!/usr/bin/env python3
"""
Generate test vectors for PRCoords for use by other implementations,
especially for the validation of more aggressive optimizations.

Using Python because it does fp math the dumb way and because file IO
isn't a pain.
"""

from prcoords import Coords, wgs_gcj, gcj_bd, wgs_bd
from array import array
from csv import writer, Dialect, QUOTE_NONE
from os.path import dirname, join, realpath

TESTVECS = join(dirname(realpath(__file__)), '..', 'TestVecs')

_IPOINTS = iter([
    105, 35,
    115.254019, 20.235733,
    121.456316, 26.504442,
    123.417261, 30.355685,
    124.289197, 39.761103,
    126.880509, 41.774504,
    127.887261, 41.370015,
    128.214602, 41.965359,
    129.698745, 42.452788,
    130.766139, 42.668534,
    131.282487, 45.037051,
    133.142361, 44.842986,
    134.882453, 48.370596,
    132.235531, 47.785403,
    130.980075, 47.804860,
    130.659026, 48.968383,
    127.860252, 50.043973,
    125.284310, 53.667091,
    120.619316, 53.100485,
    119.403751, 50.105903,
    117.070862, 49.690388,
    115.586019, 47.995542,
    118.599613, 47.927785,
    118.260771, 46.707335,
    113.534759, 44.735134,
    112.093739, 45.001999,
    111.431259, 43.489381,
    105.206324, 41.809510,
    96.485703, 42.778692,
    94.167961, 44.991668,
    91.130430, 45.192938,
    90.694601, 47.754437,
    87.356293, 49.232005,
    85.375791, 48.263928,
    85.876055, 47.109272,
    82.935423, 47.285727,
    81.929808, 45.506317,
    79.919457, 45.108122,
    79.841455, 42.178752,
    73.334917, 40.076332,
    73.241805, 39.062331,
    79.031902, 34.206413,
    78.738395, 31.578004,
    80.715812, 30.453822,
    81.821692, 30.585965,
    85.501663, 28.208463,
    92.096061, 27.754241,
    94.699781, 29.357171,
    96.079442, 29.429559,
    98.910308, 27.140660,
    97.404057, 24.494701,
    99.400021, 23.168966,
    100.697449, 21.475914,
    102.976870, 22.616482,
    105.476997, 23.244292,
    108.565621, 20.907735,
    107.730505, 18.193406,
    110.669856, 17.754550
])
POINTS = [Coords(y, x) for x, y in zip(_IPOINTS, _IPOINTS)]
ROWS = [(*p, *wgs_gcj(p), *gcj_bd(p), *wgs_bd(p)) for p in POINTS]

#: The deviation polynomial has a sqrt(abs(x)) term centred on 105E 35N, so the
#: field has an infinite derivative there. A vector on that cusp tests the exact
#: expression rather than the arithmetic, and no graded tolerance can tell it
#: from its neighbours. It gets its own set instead: a two-sided sweep down to
#: 1e-12 deg (finer decimals round to 105).
CUSP_LAT, CUSP_LON = 35, 105
CUSP_DELTAS = [0.0] + [sign * 10.0 ** -k
                       for k in range(2, 13)
                       for sign in (-1, 1)]
CUSP_POINTS = sorted((Coords(CUSP_LAT, CUSP_LON + d) for d in CUSP_DELTAS),
                     key=lambda p: p.lon)
CUSP_ROWS = [(*p, *wgs_gcj(p), *gcj_bd(p), *wgs_bd(p)) for p in CUSP_POINTS]
ACC_ROWS = [r for r in ROWS if (r[0], r[1]) != (CUSP_LAT, CUSP_LON)]
if (CUSP_LAT, CUSP_LON) not in [(r[0], r[1]) for r in ROWS]:
    raise SystemExit('no cusp vector: is 105 35 still in _IPOINTS?')

"""
struct point { double lat, lon; } // degs; 16 bytes
struct tv { point in, w_g, g_b, w_b; } // 64 bytes
"""
d = array('d')
for r in ACC_ROWS:
    d.extend(r)

d.tofile(open(join(TESTVECS, 'vecs.f64.bin'), 'wb'))

class tsv(Dialect):
    delimiter = '\t'
    doublequote = False
    escapechar = None
    quoting = QUOTE_NONE
    lineterminator = '\n'

HEADER = ["input_lat", "input_lon", "wgs_gcj_lat", "wgs_gcj_lon",
          "gcj_bd_lat", "gcj_bd_lon", "wgs_bd_lat", "wgs_bd_lon"]


def write_tsv(name, header, rows):
    # LF everywhere: these files travel between platforms.
    with open(join(TESTVECS, name), 'w', newline='\n') as f:
        c = writer(f, dialect=tsv)
        c.writerow(header)
        for r in rows:
            c.writerow(r)


# The accuracy vectors: the border of China, minus the cusp.
write_tsv('vec.tsv', HEADER, ACC_ROWS)

# Just the inputs, for implementations that would rather take a tiny file (or
# stdin) than the 8-column reference. py/checkvecs.py feeds this to --run.
write_tsv('inputs.tsv', HEADER[:2], ACC_ROWS)

# The cusp, for curiosity and sanity checks. See TestVecs/README.md.
write_tsv('cusp.tsv', HEADER, CUSP_ROWS)
write_tsv('cusp-inputs.tsv', HEADER[:2], CUSP_ROWS)
