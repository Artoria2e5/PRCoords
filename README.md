PRCoords
========

People's Rectified Coordinates (PRCoords) is a cross-language implementation of "public secret" Chinese coordinate obfuscation methods including GCJ-02 and BD-09, along with general deobfuscation methods previously established in [pycoordtrans][], [eviltransform][], and [geoChina][]. (Referring to the process of replacing straight lines with wavy ones as a "transform" is euphemism overdone.)

[pycoordtrans]: https://github.com/zxteloiv/pycoordtrans
[geoChina]: https://github.com/caijun/geoChina/blob/master/R/cst.R
[eviltransform]: https://github.com/googollee/eviltransform

Languages
---------

- [x] JavaScript
  * Web demo: https://artoria2e5.github.io/PRCoords/demo ([JS Bin canary](http://jsbin.com/zonafut))
  * [ ] Publish to NPM
- [x] Python
- [x] \(Obj-\)C/C++ (C structs)
- [ ] Ruby
- [ ] Swift
- [ ] C#
- [x] Haskell (GCJ only; data structure incomplete)
  * need to move googollee/eviltransform#54 here sometime.
- [ ] Java
- [ ] Matlab/Octave
  * too lazy to split the files. also expand "caijun"
- [x] PGSQL (GCJ only)
- [ ] Typed Racket
  * is it done?

(should I split them into submodules?)

For languages not yet supported, we recommend you to check for [eviltransform][] (MIT) or [geoChina][] (GPLv3, R) instead.

API
---

PRCoord's APIs operate on, and returns, dedicated structures for coordinates. In API names, we generally refer to WGS-84 as `wgs`, GCJ-02 as `gcj`, and BD-09 (lat-lon) as `bd`. 

### Notes on "in China" sanity check

Typically PRCoords is only supposed to be ran on obfuscated input data, which
are primarily Chinese coordinates. For this reason, initial implementations
include this [very very rough](https://news.ycombinator.com/item?id=10965506)
sanity check that spans a rectangle region on a mercator-projected map.
This check can be overridden by passing a boolean value, or may be not at all
implemented in certain implemnetations if I am not in the right mood for doing
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

You can print out a minimal copy of PRCoords with [this PDF file](https://commons.wikimedia.org/wiki/File:PRcoords_Cheatsheet.pdf). I am working on some better options [in issue #2](https://github.com/Artoria2e5/PRCoords/issues/2).

License
-------

Unless otherwise mentioned, all files in this package is dual-licensed under:

* [CC0 1.0 Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/)
* [GNU General Public License (version 3 or up)](https://gnu.org/licenses/gpl.html)

GPL is only included for fun here.

See also
--------

* [Restrictions on geographic data in China](https://en.wikipedia.org/wiki/Restrictions_on_geographic_data_in_China#Coordinate_systems): This Wikipedia article outlines impacts and the "common secret" deobfuscation approach.
* [pycoordtrans][] is a raw-flesh-level implementation that reveals certain trivial details of Baidu's transformation.
* [eviltransform][] is among the most popular cross-language soltions to the problem. It borrows its name directly from [EvilTransform.cs](https://github.com/Leask/EvilTransform/blob/master/EvilTransform.cs), an early refactored version of a raw-flesh Java implementation.
* [geoChina][] by caijun is a clear, concise implementation written in R. It features a much faster iterative method for precise conversion reproduced here
* I am planning on moving some of the comments on the algorithm found in [my initial JavaScript implementation](https://zh.wikipedia.org/wiki/User:Artoria2e5/PRCoords.js) to the [GitHub Wiki](https://github.com/Artoria2e5/PRCoords/wiki). I don't think anyone is going to be interested in copying comments on these idiocy when translating my implementation to other languages.

Oh, and finally, here is an official [news report](https://archive.fo/20110804185923/http://cxzy.people.com.cn/GB/196034/14908095.html) on that particular *\[bleep\]* who came up with GCJ-02.


<a href="https://artoria2e5.github.io/PRCoords/demo">
  <img src="https://Artoria2e5.github.io/PRCoords/Globe%2C_distorted_China.svg" width="100%" height="100">
</a>
