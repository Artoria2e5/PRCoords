A smaller boundary for containment
==================================

`OSMB-5900e60dcdf2caa109f3783d2dcde9203161950c.geojson.xz` is an OSM
boundary export for the region, 152,796 points, and it is too detailed to
ship inside a port.  What a containment test needs is a polygon that says
yes on land and close to shore, no far away, and that never loses a coastal
town to simplification.

`simplify.py` derives that polygon:

    python simplify.py OSMB-....geojson.xz out.geojson      # xz works too

Holes are dropped.  A lake is still part of the region, and the original
file marks some islands as holes too, so keeping holes would deny them.

The simplification is Visvalingam-Whyatt, with the effective area limit
split by side.  Land borders use a small limit (4e-4 deg^2 by default).
The coast uses 0.04 deg^2, with two safeguards:

* a cape may only be cut if the chord stays within `--allow` (0.02 deg) of
  the original outline;
* after thinning, the coast is shifted seaward by `--grow` (0.2 deg).

The shift is what invents the new points: the result is not a subset of the
input.  The test therefore prefers to include a little water over excluding
a piece of land.

Two island groups east of the coast get land-grade detail inside small
`--keep LAT,LON,R` discs.  They are the only places where the coast is
sensitive enough to matter at this tolerance.

Results
-------

Defaults give 3,299 points, about 60 KB at four decimals (the input is
3.6 MB):

    python simplify.py OSMB-....geojson out4.geojson
    144916 -> 3120        # the main ring
    ...
    13 rings, 3299 points

Checks on that output:

* Beijing, Tianjin, Qingdao, Shanghai, Xiamen, Haikou, Beihai, Dalian,
  Yantai, Sanya, Lhasa and Urumqi stay inside;
* Seoul, Hanoi, Taipei, Ulaanbaatar, Vientiane and Bangkok stay outside;
* the polygon area only grows, by about 4 deg^2, all of it sea;
* 4 of the 3,410 coastal vertices end up outside, by at most 0.0015 deg
  (about 170 m), from the offset approximation.

The land border stays within about 4 km of the original.

Parameters
----------

| flag | default | meaning |
|------|---------|---------|
| `--precision` | 4 | decimals written |
| `--land-area` | 4e-4 | VW area limit on land, deg^2 |
| `--sea-area` | 0.04 | VW area limit on the coast, deg^2 |
| `--allow` | 0.02 | deepest cape cut, deg |
| `--grow` | 0.2 | seaward shift, deg |
| `--sea-lon` | 108.3 | coastline is east of here |
| `--sea-lat` | 40 | and south of here |
| `--keep LAT,LON,R` | two island groups | land-grade detail within R deg |

The coastline test is a crude box, but the data only has one coast and it
sits inside the box, so precision there is not important.
