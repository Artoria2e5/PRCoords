PRCoords
========
<!--
AGENT: 请注意相比直译，需要注意：
* 有些东西写明了我们不翻译。总之不要翻译有 wikipedia 的！
* 优先使用相对路径代替 /blob/... 优化跨镜像支持。
-->

[English](README.md) || [GitHub 主库] / [Gitee 镜像]

民正经纬（PRCoords）是 GCJ-02（国测局坐标）、BD-09（百度坐标）等中国“火星”坐标混淆方法的多语言实现，也包含 [ChinaMapShift][]、[eviltransform][]、[geoChina][] 里早已给出的通用反混淆方法。（把“把直线换成波浪线”这个过程叫作“转换”，委婉得有点过头了。）

关于中国地理数据限制的背景，此语言版本不多做翻译。

[ChinaMapShift]: https://gist.github.com/anonymous/e7c6f67555099180ce1ae8da4ba2c513
[geoChina]: https://github.com/caijun/geoChina/blob/master/R/cst.R
[eviltransform]: https://github.com/googollee/eviltransform
[GitHub 主库]: https://github.com/Artoria2e5/PRCoords
[Gitee 镜像]: https://gitee.com/artoria2e5/PRCoords

语言
----

- [x] JavaScript（[`npm install prcoords`](https://www.npmjs.com/package/prcoords)）[![](https://data.jsdelivr.com/v1/package/npm/prcoords/badge)](https://www.jsdelivr.com/package/npm/prcoords)
  * 网页演示：https://artoria2e5.github.io/PRCoords/demo
  * 现已支持 AMD，并为 Babel 和 TypeScript 提供仿 `__esModule` 互操作！
- [x] Python（[`pip install prcoords`](https://pypi.org/project/prcoords/)）
- [x] \(Obj-\)C/C++（C ABI）—— 简单的 Makefile，带 `install`
- [ ] Ruby
- [ ] C#
- [x] Haskell（`haskell/PRCoords.hs`）
- [x] Java 8+（`io.github.artoria2e5.prcoords`，可选 JNI 桥接到 C++ 核心）
- [x] Matlab/Octave
- [x] PGSQL
- [x] Typed Racket（`racket/`，包名 `prcoords`，Flonum 类型）
- [x] Go（`go/`，模块 `github.com/Artoria2e5/PRCoords`，包路径 `.../go`）
- [x] Lua 5.1+（`lua/PRCoords.lua`，一个普通的 `PRCoords` 表；`lua/mediawiki.lua` 是 Scribunto 外壳）
- [x] Swift 5+（`swift/`，SwiftPM 包 `prcoords`，产品 `PRCoords`，d4 sinpi 近似） [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FArtoria2e5%2FPRCoords%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Artoria2e5/PRCoords)

测试
----

[`TestVecs/`](TestVecs/) 存放由 Python 实现生成的参考向量，Python 实现是基准实现：CPython 做浮点运算的方式笨拙而忠实，所以它算出的数值容易在其他语言里复现。

各实现应提供一个 dumper：读入输入坐标，按参考实现的 8 列 TSV 布局输出，每个点一行。随后由 Python 工具 [`py/checkvecs.py`](py/checkvecs.py) 将 dump 与向量比对，报告每个变换的最大偏差：

```console
$ cpp/vecs TestVecs/inputs.tsv | python py/checkvecs.py - --profile badmath
$ python py/checkvecs.py --run "node js/vecs.js" --profile exact
```

`--profile` 选择与构建方式匹配的容差（`exact` 用于普通双精度，`badmath` 用于 `sinpi` 近似，`float` 和 `float-badmath` 用于 32 位浮点构建）。偏差多项式在 105E 35N 的原点正好落在场的一个尖点（cusp）上，因此单独连同邻域扫描一起放进 `TestVecs/cusp.tsv`，不参与评分。格式与各 profile 背后的数值见 [`TestVecs/README.md`](TestVecs/README.md)。

API
---

PRCoords 的 API 以专门的坐标结构为输入和输出。API 名称中，WGS-84 一般记作 `wgs`，GCJ-02 记作 `gcj`，BD-09（经纬度）记作 `bd`。

### 逆变换

这些混淆方法通常具有以下性质，以维持基本可用性：

1. `obfs(coord)` 大致接近 `coord`。
2. `obfs(a) - obfs(b)` 通常接近 `a - b`。（`a` 与 `b` 越近，效果越好。）

从“正向”混淆反推，也就是从 `obfs(coord)` 求 `coord`，一般有两种做法：

* **倒着算**：`obfs(coord)` 从不会离 `coord` 太远，所以直接用 `obfs(obfs(coord)) - obfs(coord)` 估计 `obfs(coord) - coord`。
* **迭代几下**：先设法得到一个粗略的 `guess`，再用性质 2 把剩余误差估计为 `obfs(guess) - obfs(coord)`，据此修正 `guess`。

这些方法的效果如何，可以看演示页上的 `ΔRoundtrip` 一项。除非是做档案整理，一般不必迭代。

### `is_in_china` 的粗略检查

PRCoords 通常只应作用于混淆后的输入数据，而这些数据主要是中国坐标。因此最初的实现里带了一个[非常非常粗略](https://news.ycombinator.com/item?id=10965506)的合理性检查，范围是墨卡托投影地图上的一个矩形。可以传入布尔值覆盖该检查；某些语言里也可能干脆没实现——那要看我有没有心情做这种傻事。

还有一个“insane”检查，试图逼近 Google 与百度的畸变范围，供 [IITC](https://iitc.me) 使用：[`js/insane_is_in_china.js`](https://github.com/Artoria2e5/PRCoords/blob/master/js/insane_is_in_china.js)。它本质上是对一个 70 个顶点的多边形做射线投射检查。至于某个点是否属于被依法折腾过的中国数据，仍应由调用方自己判断。

常见问题
--------

### 为什么又造一个轮子？

* 正确性：别人要么错了，要么已经删库。
* 公有领域：给一个“公开的秘密”申请版权，本来就说不通。
* 干净、以坐标对为基础的 API。
* 总得给这个阴阳怪气的名字找个用处。

### 这些系统能用 WKT 或 proj 字符串描述吗？

不能直接当作基准（datum）来描述，因为在这两种表示里，基准要么是“正常”的（三维中无非线性，可以用 Helmert 变换），要么是一大张网格表。

不过，可以用 `PROJCS` 的 `PROJECTION` 项把这种混淆描述成一个黑箱。由于 `PROJCS` 不能嵌套在另一个 `PROJCS` 里，我们没法表达 BD 的先后串联关系，只能把它写成一个看似无关的投影。

```js
PROJCS["Chinese BSM 2002, Pseudo-Ellipsoidal",
    GEOGCS["WGS 84", AUTHORITY["EPSG","4326"]],
    PROJECTION["CN_Obfs_GCJ_2002_Ellipsoidal"],
    AXIS["longitude",east],
    AXIS["latitude",north],
    UNIT["degree",0.0174532925199433,
      AUTHORITY["EPSG","9122"]],
    EXTENSION["PROJ4","+proj=gcjlonglat +units=deg +nadgrids=@null +wktext +no_defs"],
    AUTHORITY["EPSG","888000"]]

PROJCS["Baidu 2009, Pseudo-Ellipsoidal",
    GEOGCS["WGS 84", AUTHORITY["EPSG","4326"]],
    PROJECTION["CN_Obfs_Baidu_2009_Ellipsoidal"],
    AXIS["longitude",east],
    AXIS["latitude",north],
    UNIT["degree",0.0174532925199433,
      AUTHORITY["EPSG","9122"]],
    EXTENSION["PROJ4","+proj=bd09 +units=deg +nadgrids=@null +wktext +no_defs"],
    AUTHORITY["EPSG","888001"]]
```

网上还能见到一种“[百度墨卡托][BM]”（Baidu Mercator），幸好只用在他们的瓦片服务器附近。它的做法是把 BD-09 的经纬度当成克拉克 1866 椭球上的坐标。

  [BM]: https://github.com/gumblex/cntms/commit/bbde4006adeb92f48da1ff7d1f88da393d382f8a

```js
PROJCS["Baidu 2009, Pseudo-Mercator",
    GEOGCS["WGS 84", AUTHORITY["EPSG","4326"]],
    PROJECTION["CN_Obfs_Baidu_2009_Mercator"],
    AXIS["x",east],
    AXIS["y",north],
    UNIT["metre",1,
      AUTHORITY["EPSG","9001"]],
    EXTENSION["PROJ4","+proj=baidumerc +units=m +nadgrids=@null +wktext +no_defs"],
    AUTHORITY["EPSG","888002"]]
```

所有这些定义都用 `GEOGCS["WGS 84", AUTHORITY["EPSG","4326"]]` 和 `+nadgrids=@null` 来阻止任何基准转换。EPSG:88800x 这些编号是私用的扩展，取的是 888 在中文里的好彩头；可以把它想成当年的 EPSG:900913。

`proj4` 本身当然看不懂这些投影，但 proj4js 的开发者把扩展做得[非常容易](https://github.com/proj4js/proj4js/issues/358)。这里有个[例子](https://runkit.com/artoria2e5/proj4-plugin-prcoords)（备份在 [`docs/proj4_plugin.js`](https://github.com/Artoria2e5/PRCoords/blob/master/docs/proj4_plugin.js)，以防 RunKit 下线），演示如何给 proj4js 加上 PRCoords 支持。

### 该用快速浮点算数（`-ffast-math`）吗？

该用。最初的 GCJ-02（“EMQ”版）里有个伪随机分量，本身就会带来最多 1 米的误差。你不可能做得比它更糟。

C++ 实现里可以打开几个偷工减料的选项：
* 把 `PRCOORDS_NUM` 从 `double` 改成 `float`，得到 32 位浮点实现。
* 定义 `PRCOORDS_APPROX` 可启用 devmaster 用户 Nick 的 `sin(x*pi)` 快速近似。见 [cpp/badmath.hh](cpp/badmath.hh) 和 [cpp/bench_out](cpp/bench_out)。

实体版 PRCoords
---------------

你可以用[这份 PDF](https://commons.wikimedia.org/wiki/File:PRcoords_Cheatsheet.pdf)打印一份迷你版 PRCoords。我正在[issue #2](https://github.com/Artoria2e5/PRCoords/issues/2)里琢磨更好的方案。还有一个印着旧版 PDF 的帆布袋，[在 Teespring 上有售](https://teespring.com/miniprcoords-tote-v1)。

欢迎自行打印 PDF 并拿去卖 T 恤！它已放入公有领域，不用给我付钱。当然，你也随时可以在 [Patreon](https://www.patreon.com/artoria2e5) 上资助我的颠覆活动。

许可证
------

除另有说明外，本包内所有文件（包括这份 README）均以双许可证发布：

* [CC0 1.0 公有领域贡献语](https://creativecommons.org/publicdomain/zero/1.0/)
* [GNU 通用公共许可证（第 3 版或更高）](https://gnu.org/licenses/gpl.html)

这里的 GPL 纯粹是图一乐。双许可按“或”的条件生效，不必担心。

来源
----

* EMQ 的 [Algorithm.Coords.Converter](https://archive.is/20130815104734/emq.googlecode.com/svn/emq/src/Algorithm/Coords/Converter.java) 大概就是 GCJ 的*那个*泄密源。它是一个“用于演示 GIS 系统”的 JSP 项目，多半出自某个电网外包商。
  * GCJ 在两个轴上的偏移都带一点随机性：一次 `sin` 调用加一个 LCG。二者各带来最多 1 米误差。
* [on4wp7](https://archive.is/20150702191259/https://on4wp7.codeplex.com/SourceControl/changeset/view/21483%23353936)（2013）是最早把 GCJ（正向）实现合理化的版本。
* [ChinaMapShift][]（2014）想出了 GCJ 的快速迭代逆变换。我是先从 geoChina 那里知道的，然后在这里推广开。
* BD-09 的来源不太可靠，但 [pycoordtrans](https://github.com/zxteloiv/pycoordtrans)（2014）里似乎有。

另见
----

* [eviltransform][] 是这个问题最流行的跨语言方案之一。它的名字直接借自 [EvilTransform.cs](https://github.com/Leask/EvilTransform/blob/master/EvilTransform.cs)，那是“emq”里一份原始 Java 实现早期重构版，而“emq”是某个电网外包商的 GIS 演示项目。
  * 2016 年 6 月起，eviltransform 含有大量参数错误，会损害输出，BD-09 尤其严重。修正见 googollee/eviltransform[#43](https://github.com/googollee/eviltransform/issues/43)、[#53](https://github.com/googollee/eviltransform/pull/53) 和 [#44](https://github.com/googollee/eviltransform/issues/44)。截至 2019 年 6 月，这些问题仍未修复。
* caijun 的 [geoChina][] 是一份清晰简洁的 R 实现，采用了 ChinaMapShift 的迭代方法。
* [Ishisashi 的文章](https://chaoli.club/index.php/4777/0)也讨论了这个话题。他们还写了一个超强化版的演示。

最后，这里有一篇官方[新闻报道](https://archive.fo/20110804185923/http://cxzy.people.com.cn/GB/196034/14908095.html)，讲的是想出 GCJ-02 的那位 *\[哔——\]*。


<a href="https://artoria2e5.github.io/PRCoords/demo">
  <img src="https://Artoria2e5.github.io/PRCoords/Globe%2C_distorted_China.svg" width="100%" height="100%">
</a>
