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

The result is WGS-84; tag the layer's spatial reference as EPSG:4326.

## CoordRefSystems

CoordRefSystems has no GCJ-02 datum; feed it numbers and retag the result:

```julia
# ] add CoordRefSystems Unitful
using CoordRefSystems, Unitful
p = LatLon(35.0055, 105.0033)          # GCJ-02 values
w = gcj_wgs(Coords(ustrip(p.lat), ustrip(p.lon)))
LatLon(w.lat, w.lon)                   # WGS-84
```
