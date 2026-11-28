A smaller boundary for containment
==================================

`OSMB-5900e60dcdf2caa109f3783d2dcde9203161950c.geojson.xz` is an OSM
boundary export for the region.  It has 152,796 points, too many to ship
inside a port.  A containment test needs much less: a polygon that says yes
on land and close to shore, no far away, and that does not lose a coastal
town to simplification.

`simplify.py` derives that polygon:

    python simplify.py OSMB-....geojson.xz out.geojson      # xz works too

Holes are dropped.  A lake is still part of the region, and the file also
marks some islands as holes, so keeping holes would put those places
outside.

The simplification is Visvalingam-Whyatt, with the effective area limit
split by side.  Land borders use a small limit (4e-4 deg^2 by default).
The coast uses 0.04 deg^2, with two safeguards:

* a cape may only be cut if the chord stays within `--allow` (0.02 deg) of
  the original outline;
* after thinning, the coast is shifted seaward by `--grow` (0.2 deg).

The shift invents new points, so the result is not a subset of the input.
The test prefers a little extra water to a missing piece of land.

Two island groups east of the coast keep land-grade detail inside small
`--keep LAT,LON,R` discs; they are the only parts of the coast where the
finer limit matters.

Results
-------

Defaults give 3,299 points, about 60 KB at four decimals (the input is
3.6 MB):

    python simplify.py OSMB-....geojson out4.geojson
    144916 -> 3120        # the main ring
    ...
    13 rings, 3299 points

Checks on that output:

* the source and the output agree on the side of 30 border towns: Dandong,
  Hunchun, Suifenhe, Heihe, Mohe, Manzhouli, Erenhot, Khorgos, Alashankou,
  Tashkurgan, Yadong, Zhangmu, Ruili, Wanding, Mohan, Hekou, Pingxiang and
  Dongxing inside; Sinuiju, Kraskino, Pogranichny, Blagoveshchensk,
  Zabaikalsk, Zamyn-Uud, Zharkent, Dostyk, Muse, Boten, Lao Cai and Mong Cai
  outside;
* the polygon area only grows, by about 4 deg^2, all of it sea;
* 4 of the 3,410 coastal vertices end up outside, by at most 0.0015 deg
  (about 170 m), from the offset approximation;
* the land border stays within about 4 km of the original.

Big cities are not on the list; they sit hundreds of kilometres from the
border, where any polygon passes.  The coordinates are in `towns.tsv`.

Coarser presets
---------------

A much smaller polygon works if the test only needs to answer "in the
country, not close to the border".  At these tolerances the default box is
too small: only the coast south of 40 N would get sea treatment, and the
northern coast would be cut as a land border.  Both presets move the box to
`--sea-lon 117 --sea-lat 41`, which also puts the short river border in the
northeast on the coast side.  The measurements use three decimals; the
0.001 deg grid is 110 m, far below the chord error.  Flip rates come from
jittering every source boundary vertex by 0.3 deg.

About 300 points, 292 after rounding, 7 rings, 4.9 KB:

    python simplify.py OSMB-....geojson.xz b300.geojson --precision 3 \
        --land-area 0.05 --sea-area 2 --allow 0.3 --grow 0.1 \
        --sea-lon 117 --sea-lat 41

| measure | value |
|---------|-------|
| points | 292 (main ring 264) |
| area | +2.4 deg^2, +0.25% |
| median deviation | 0.025 deg |
| p90 / p99 / max | 0.10 / 1.12 / 2.10 deg |
| flips, boundary jitter | 2.6% false negative, 3.5% false positive |
| border towns | 22 of 30 agree |
| island rings | 6 of 12 survive |

One chord skips the Bohai/Liaodong coast: the bay and the sea north of the
chord count as land, and the 3,718 source vertices in that region sit
0.9 deg from the outline at the median, 2.1 deg at worst.  Everywhere else,
the southern coast included, the deviation stays under 0.38 deg (median
0.04).  A `--keep` disc can hold the bay, at the cost of going over the
300-point budget.

Near 128 points, 125 after rounding, 3 rings, 2.1 KB:

    python simplify.py OSMB-....geojson.xz b128.geojson --precision 3 \
        --land-area 0.3 --sea-area 3 --allow 0.5 --grow 0.2 \
        --sea-lon 117 --sea-lat 41

| measure | value |
|---------|-------|
| points | 125 (main ring 117) |
| area | -2.3 deg^2, islands lost |
| median / p90 / max | 0.063 / 0.22 / 0.68 deg |
| flips, boundary jitter | 5.6% false negative, 6.4% false positive |
| island rings | 2 of 12 survive |
| border towns | 18 of 30 agree |

The land border becomes chords a few tenths of a degree long, ten of the
twelve island rings fall below the four-point floor, and the polygon loses
more area than it gains.  Five kilobytes is already small, so 300 is the
better stopping point if size is the only concern.

Neither preset is safe near a border.  The ~300 version puts eight of the
30 towns on the wrong side (Suifenhe and Sinuiju, plus Blagoveshchensk,
Zabaikalsk, Zamyn-Uud, Muse, Boten and Mong Cai); the ~125 version, twelve.
Most are river borders, where a chord across a bend can leave the
neighbour's bank inside the polygon or the town's own bank outside.  The
3,299-point default agrees everywhere.  Use a coarse preset far from the
border, or add `--keep` discs where the border matters.

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
