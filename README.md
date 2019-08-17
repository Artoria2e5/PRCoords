PRCoords
========

People's Rectified Coordinates (PRCoords) is a cross-language implementation of "public secret" Chinese coordinate obfuscation methods including GCJ-02 and BD-09, along with general deobfuscation methods previously established in [ChinaMapShift][], [eviltransform][], and [geoChina][]. (Referring to the process of replacing straight lines with wavy ones as a "transform" is euphemism overdone.)

[ChinaMapShift]: https://gist.github.com/anonymous/e7c6f67555099180ce1ae8da4ba2c513
[geoChina]: https://github.com/caijun/geoChina/blob/master/R/cst.R
[eviltransform]: https://github.com/googollee/eviltransform

Languages
---------

- [x] JavaScript ([`npm install prcoords`](https://www.npmjs.com/package/prcoords)) [![](https://data.jsdelivr.com/v1/package/npm/prcoords/badge)](https://www.jsdelivr.com/package/npm/prcoords)
  * Web demo: https://artoria2e5.github.io/PRCoords/demo
- [x] Python ([`pip install prcoords`](https://pypi.org/project/prcoords/))
- [x] \(Obj-\)C/C++ (C structs)
  * [ ] Makefile with `install`
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

Why another wheel?
------------------

* Public Domain
* Clean API based on pairs of coordinates
* Need to find a place for this sarcastic name

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

* [Restrictions on geographic data in China](https://en.wikipedia.org/wiki/Restrictions_on_geographic_data_in_China#Coordinate_systems): this Wikipedia article outlines impacts and the "common secret" deobfuscation approach.
  * Chinese readers: see [中华人民共和国测绘限制](https://zh.wikipedia.org/wiki/中华人民共和国测绘限制).
* [eviltransform][] is among the most popular cross-language soltions to the problem. It borrows its name directly from [EvilTransform.cs](https://github.com/Leask/EvilTransform/blob/master/EvilTransform.cs), an early refactored version of a raw-flesh Java implementation found in "[emq](https://code.google.com/archive/p/emq/)", some sort of government contractor GIS demo project.
  * Since June 2016, eviltransform contains numerous parameter errors that compromise its output, especially for BD-09. See googollee/eviltransform[#43](https://github.com/googollee/eviltransform/issues/43), [#53](https://github.com/googollee/eviltransform/pull/53) and [#44](https://github.com/googollee/eviltransform/issues/44) for corrections. As of June 2019 these problems are not fixed.
* [geoChina][] by caijun is a clear, concise implementation written in R. It features the iterative method from ChinaMapShift.
* I am planning on moving some of the comments on the algorithm found in [my initial JavaScript implementation](https://zh.wikipedia.org/wiki/User:Artoria2e5/PRCoords.js) to the [GitHub Wiki](https://github.com/Artoria2e5/PRCoords/wiki). I don't think anyone is going to be interested in copying comments on these idiocy when translating my implementation to other languages.
** If you are doing a translation, consider only using the comments from the PDF.

Oh, and finally, here is an official [news report](https://archive.fo/20110804185923/http://cxzy.people.com.cn/GB/196034/14908095.html) on that particular *\[bleep\]* who came up with GCJ-02.


<a href="https://artoria2e5.github.io/PRCoords/demo">
  <img src="https://Artoria2e5.github.io/PRCoords/Globe%2C_distorted_China.svg" width="100%" height="100">
</a>
