# PRCoords for R

People's Rectified Coordinates (PRCoords) is a cross-language implementation of
"public secret" Chinese coordinate obfuscation methods including GCJ-02 and
BD-09, along with general deobfuscation methods previously established in
ChinaMapShift, eviltransform, and geoChina.

This directory is the R port, packaged as the `prcoords` package.

The full README, the other language ports and the test vectors live in the
repository: [Artoria2e5/PRCoords](https://github.com/Artoria2e5/PRCoords).

GCJ-02 and BD-09 are what Chinese maps serve; go back to WGS-84 with:

```r
gcj_wgs(lat, lon)
bd_wgs(lat, lon)
gcj_wgs_bored(lat, lon)      # fixed-point refinement
bd_wgs_bored(lat, lon)
```

All transforms take vectors and return an N-by-2 matrix.  `check_china = FALSE`
skips the bounds test; `wgs_gcj` and `wgs_bd` go the other way.

## sf

`x` is an sf point layer in GCJ-02 (or BD-09):

```r
library(sf)
xy <- st_coordinates(x)              # X, Y
g <- gcj_wgs(xy[, "Y"], xy[, "X"])   # bd_wgs for BD-09
st_geometry(x) <- st_sfc(
  lapply(seq_len(nrow(g)), function(i) st_point(g[i, 2:1])), crs = 4326)
```

The result is WGS-84, so it is tagged EPSG:4326.

## terra

```r
library(terra)
xy <- crds(x)
g <- gcj_wgs(xy[, 2], xy[, 1])       # bd_wgs for BD-09
vect(g[, 2:1], crs = "EPSG:4326")
```

For rasters, transform cell centres and resample; there is no CRS shortcut.
