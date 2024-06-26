PRCoords
========

People's Rectified Coordinates (PRCoords) is a cross-language implementation of "public secret" Chinese coordinate obfuscation methods including GCJ-02 and BD-09, along with general deobfuscation methods previously established in [ChinaMapShift][], [eviltransform][], and [geoChina][]. (Referring to the process of replacing straight lines with wavy ones as a "transform" is euphemism overdone.)

For a background on China's geographic obfuscation, see [Restrictions on geographic data in China](https://en.wikipedia.org/wiki/Restrictions_on_geographic_data_in_China#Coordinate_systems) and [中华人民共和国测绘限制](https://zh.wikipedia.org/wiki/中华人民共和国测绘限制) on Wikipedia.

[ChinaMapShift]: https://gist.github.com/anonymous/e7c6f67555099180ce1ae8da4ba2c513
[geoChina]: https://github.com/caijun/geoChina/blob/master/R/cst.R
[eviltransform]: https://github.com/googollee/eviltransform

Languages
---------

- [x] JavaScript ([`npm install prcoords`](https://www.npmjs.com/package/prcoords)) [![](https://data.jsdelivr.com/v1/package/npm/prcoords/badge)](https://www.jsdelivr.com/package/npm/prcoords)
  * Web demo: https://artoria2e5.github.io/PRCoords/demo
  * Now with AMD support and faux `__esModule` interop for Babel and TypeScript!
- [x] Python ([`pip install prcoords`](https://pypi.org/project/prcoords/))
- [x] \(Obj-\)C/C++ (C ABI)
  * [x] Makefile with `install`
- [ ] Ruby
- [ ] Swift
- [ ] C#
- [x] Haskell (GCJ only; data structure incomplete)
  * need to move googollee/eviltransform#54 here sometime.
- [ ] Java
- [ ] Matlab/Octave
  * too lazy to split the files. also expand "caijun"
- [x] PGSQL
- [ ] Typed Racket
  * is it done?

(should I split them into submodules?)

For languages not yet supported, we recommend you to check for [eviltransform][] (MIT) or [geoChina][] (GPLv3, R) instead.

API
---

PRCoord's APIs operate on, and returns, dedicated structures for coordinates. In API names, we generally refer to WGS-84 as `wgs`, GCJ-02 as `gcj`, and BD-09 (lat-lon) as `bd`. 

### Inverse functions

The obfuscations generally have these properties to maintain basic usefulness:

1. `obfs(coord)` is sort of close to `coord`.
2. `obfs(a) - obfs(b)` is usually close to `a - b`. (The closer `a` and `b` are
   to each other, the better it works.)

In general two approaches of inverting the "forward" obfuscations, or working from
`obfs(coord)` to `coord`, are implemented:

* _Run it backwards_: `obfs(coord)` is never too far from `coord`, so just use
  `obfs(obfs(coord)) - obfs(coord)` to estimate `obfs(coord) - coord`.
* _Iterate a bit_: Get a rough `guess` somehow, and just use property 2 to estimate
  the remaining error as `obfs(guess) - obfs(coord)` and correct the `guess`.

You can read on the demo page about how well these methods work from the `ΔRoundtrip`
entry. Unless you are doing archival work, you generally don't have to iterate.

### The "in China" sanity check

Typically PRCoords is only supposed to be ran on obfuscated input data, which
are primarily Chinese coordinates. For this reason, initial implementations
include this [very very rough](https://news.ycombinator.com/item?id=10965506)
sanity check that spans a rectangular region on a mercator-projected map.
This check can be overridden by passing a boolean value, or may be not at all
implemented in certain languages if I am not in the right mood for doing
silly things.

There is an "insane" sanity check intended to approximate the range of Google
and Baidu's distortion, intended for use by [IITC](https://iitc.me):
[`js/insane_is_in_china.js`](https://github.com/Artoria2e5/PRCoords/blob/master/js/insane_is_in_china.js).
It is basically a ray-casting polygon check with 70 vertices. You, as the
caller, should still be responsible for telling whether a point is part of the
gov-screwed Chinese data.

FAQ
---

### Why another wheel?

* Correctness
* Public Domain
* Clean API based on pairs of coordinates
* Need to find a place for this sarcastic name

### Can the systems be described as WKT or proj-strings?

Not directly as a datum, because in both representations a datum is either
"sane" (no non-linearity in 3D, Helmert possible) or a big table of grids.

It should be possible to describe the two CS with a `PROJECTION` entry as
a `PROJCS`. Since a `PROJCS` cannot be nested in another, the BD
transformation must be described using WGS84 and a fuzed GCJ-BD projection.
The situation is similar with [Baidu "Meractor"](https://github.com/gumblex/cntms/commit/bbde4006adeb92f48da1ff7d1f88da393d382f8a).

<details>
<summary>Speculative WKT/PROJ4</summary>

```js
PROJCS["Baidu 2009, Pseudo-Mercator",
    GEOGCS["WGS 84",
        DATUM["WGS_1984",
            SPHEROID["WGS 84",6378137,298.257223563,
                AUTHORITY["EPSG","7030"]],
            AUTHORITY["EPSG","6326"]],
        PRIMEM["Greenwich",0,
            AUTHORITY["EPSG","8901"]],
        UNIT["degree",0.0174532925199433,
            AUTHORITY["EPSG","9122"]],
        AUTHORITY["EPSG","4326"]],
    PROJECTION["CN_Obfs_Baidu_2009_Mercator"],
    AXIS["x",east],
    AXIS["y",north],
    UNIT["metre",1,
      AUTHORITY["EPSG","9001"]],
    EXTENSION["PROJ4","+proj=baidumerc +units=m +nadgrids=@null +wktext +no_defs"],
    AUTHORITY["EPSG","888002"]]

PROJCS["Chinese BSM 2002, Pseudo-Ellipsoidal",
    GEOGCS["WGS 84", AUTHORITY["EPSG","4326"]],
    PROJECTION["CN_Obfs_GCJ_2002_Ellipsoidal"],
    AXIS["longitude",east],
    AXIS["latitude",north],
    UNIT["degree",0.0174532925199433,
      AUTHORITY["EPSG","9122"]],
    EXTENSION["PROJ4","+proj=gcjlonglat +units=deg +nadgrids=@null +wktext +no_defs"],
    AUTHORITY["EPSG","888000"]]
```
</details>

The good people at proj4js has made their stuff [very easy to extend](https://github.com/proj4js/proj4js/issues/358). Here is [an example](https://runkit.com/artoria2e5/proj4-plugin-prcoords).

### Should I use fast fp math?

Yes. Nobody knows what the original looks like anyways, so what's wrong with letting the compiler recombine a bit more? You can't be more off
than the one-meter random error (in "EMQ") anyways.

Or tinker with 32-bit floats and fixed-point numbers. Or try approximation tools like [Sollya](http://sollya.gforge.inria.fr/) or [MC++](https://omega-icl.github.io/mcpp/). Really, just search on the Internet for "\<language\> Taylor Chebyshev Model". You only need less than 1e-6 error on a [not-very-large slice](https://github.com/Artoria2e5/PRCoords/blob/a3a8bb8/js/PRCoords.js#L91) of the Earth anyways.

I threw TaylorModels.jl at GCJ-02, and got ~~decent~~ results out of it. Still too lazy to put it in code though. Check out [approx/approx.ipynb](https://github.com/Artoria2e5/PRCoords/blob/master/approx/approx.ipynb). (Nope, not decent. Gotta do it properly some day, just don't use the notebook and expect it to work!)

I tried another route with the C++ version using a devmaster user Nick's `sinpi()` approximation. It seems to be good enough for 1e-6: check out [cpp/bench_out](https://github.com/Artoria2e5/PRCoords/tree/master/cpp/bench_out) and [cpp/badmath.hh](https://github.com/Artoria2e5/PRCoords/blob/master/cpp/badmath.hh).

Physical PRCoords
-----------------

You can print out a minimal copy of PRCoords with [this PDF file](https://commons.wikimedia.org/wiki/File:PRcoords_Cheatsheet.pdf). I am working on some better options [in issue #2](https://github.com/Artoria2e5/PRCoords/issues/2). A fairly simple tote bag with an older version of the PDF is [available from Teespring](https://teespring.com/miniprcoords-tote-v1).

Feel free to print and sell t-shirts with the PDF file! It is put in the Public Domain, so you don't have to pay me for that. You can always fund my subversive activities on [Patreon](https://www.patreon.com/artoria2e5) though.

License
-------

Unless otherwise mentioned, all files in this package, including this README file,
are dual-licensed under:

* [CC0 1.0 Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/)
* [GNU General Public License (version 3 or up)](https://gnu.org/licenses/gpl.html)

GPL is only included for fun here.

Sources
-------

* [Algorithm.Coords.Converter](https://archive.is/20130815104734/emq.googlecode.com/svn/emq/src/Algorithm/Coords/Converter.java) from [EMQ](https://code.google.com/archive/p/emq/) ([GitHub mirror](https://github.com/richardyu-au/emq)) is probably *the* GCJ leak. It is a JSP project "for demonstrating GIS systems", probably done by some government contractor.
  * There is some randomness in the GCJ deltas on both axes: one `sin` invocation and one LCG. Each add a maximum of 1 meter of error.
* [on4wp7](https://archive.is/20150702191259/https://on4wp7.codeplex.com/SourceControl/changeset/view/21483%23353936) (2013) is the earliest rationalized GCJ (forward) implementation. No randomness is attempted.
* [ChinaMapShift][] (2014) figured out the quick iterative inverse for GCJ. I learned about it via geoChina first and generalized it here.
* BD-09 is not very well sourced, but [pycoordtrans](https://github.com/zxteloiv/pycoordtrans) (2014) seems to have it.

See also
--------

* [eviltransform][] is among the most popular cross-language soltions to the problem. It borrows its name directly from [EvilTransform.cs](https://github.com/Leask/EvilTransform/blob/master/EvilTransform.cs), an early refactored version of a raw-flesh Java implementation found in "[emq](https://code.google.com/archive/p/emq/)", some sort of government contractor GIS demo project.
  * Since June 2016, eviltransform contains numerous parameter errors that compromise its output, especially for BD-09. See googollee/eviltransform[#43](https://github.com/googollee/eviltransform/issues/43), [#53](https://github.com/googollee/eviltransform/pull/53) and [#44](https://github.com/googollee/eviltransform/issues/44) for corrections. As of June 2019 these problems are not fixed.
* [geoChina][] by caijun is a clear, concise implementation written in R. It features the iterative method from ChinaMapShift.
* I am planning on moving some of the comments on the algorithm found in [my initial JavaScript implementation](https://zh.wikipedia.org/wiki/User:Artoria2e5/PRCoords.js) to the [GitHub Wiki](https://github.com/Artoria2e5/PRCoords/wiki). I don't think anyone is going to be interested in copying comments on these idiocy when translating my implementation to other languages.
  * If you are doing a translation, consider only using the comments from the PDF.
* [Ishisashi's writeup](https://chaoli.club/index.php/4777/0) on this subject. They wrote a super enhanced version of the demo too.

Oh, and finally, here is an official [news report](https://archive.fo/20110804185923/http://cxzy.people.com.cn/GB/196034/14908095.html) on that particular *\[bleep\]* who came up with GCJ-02.


<a href="https://artoria2e5.github.io/PRCoords/demo">
  <img src="https://Artoria2e5.github.io/PRCoords/Globe%2C_distorted_China.svg" width="100%" height="100">
</a>
