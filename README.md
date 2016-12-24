PRCoords
========

People's Rectified Coordinates (PRCoords) is a cross-language implementation of "public secret" Chinese coordinate obfuscation methods including GCJ-02 and BD-09, along with general deobfuscation methods previously established in [pycoordtrans][], [eviltransform][], and [geoChina][].

[pycoordtrans]: https://github.com/zxteloiv/pycoordtrans
[geoChina]: https://github.com/caijun/geoChina/blob/master/R/cst.R
[eviltransform]: https://github.com/googollee/eviltransform

Languages
---------

- [x] JavaScript
  - [ ] Web demo
- [ ] Python
- [ ] \(Obj-\)C/C++
- [ ] Ruby
- [ ] Swift
- [ ] C#/UWP

For languages not yet supported, we recommend you to check for [eviltransform][] (MIT) or [geoChina][] (GPLv3, R) instead.

API
---

PRCoord's APIs operate on, and returns, dedicated structures for coordinates. In API names, we generally refer to WGS-84 as `wgs`, GCJ-02 as `gcj`, and BD-09 (lat-lon) as `bd`. 

Why another wheel?
------------------

* Public Domain
* Clean API based on pairs of coordinates
* Need to find a place for this sarcastic name

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
