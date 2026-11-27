# PRCoords for R

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
  lapply(seq_len(nrow(g)), function(i) st_point(g[i, 2:1])), crs = NA)
```

GCJ-02 is not an EPSG CRS, so the result is deliberately `crs = NA`.

## terra

```r
library(terra)
xy <- crds(x)
g <- gcj_wgs(xy[, 2], xy[, 1])       # bd_wgs for BD-09
vect(g[, 2:1], crs = NA)
```

For rasters, transform cell centres and resample; there is no CRS shortcut.
