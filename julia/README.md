# PRCoords for Julia

GCJ-02 and BD-09 are what Chinese maps serve; go back to WGS-84 with:

```julia
using PRCoords
p = Coords(35.0055, 105.0033)   # GCJ-02
gcj_wgs(p)
bd_wgs(p)
gcj_wgs_bored(p)                # fixed-point refinement
bd_wgs_bored(p)
```

All take `Coords`.  `check_china = false` skips the bounds test; `wgs_gcj` and
`wgs_bd` go the other way.

## ArchGDAL

`geom` is a point in GCJ-02 (or BD-09):

```julia
using ArchGDAL, GeoInterface
geom = ArchGDAL.fromWKT("POINT (105.0033 35.0055)")
lon, lat = GeoInterface.coordinates(geom)
p = gcj_wgs(Coords(lat, lon))       # bd_wgs for BD-09
ArchGDAL.createpoint(p.lon, p.lat)
```

GCJ-02 is not an EPSG CRS; keep the source CRS explicitly if you need one.
