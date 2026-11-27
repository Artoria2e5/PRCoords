# Changelog

## 1.1.1

- The Swift package is named `prcoords`; the `PRCoords` product and
  module names are unchanged.
- `Coords.description` prints `Coords(lat, lon)`, matching the unlabeled
  initializer, so the output is paste-able.

## 1.1.0

- Swift port added as a root SwiftPM package, `PRCoords` (Swift 5
  language mode), with the same d4 sinpi approximation as the C++ core.
- Lua port finished, with `deviation_m` as the metre-offset intermediate.

## 1.0.4

- Go port added, published as the `github.com/Artoria2e5/PRCoords/go`
  package of the new root Go module.
- Racket code became an installable package (collection `prcoords`) and
  the Haskell and Matlab ports gained their own vec dumpers.
- `Coords` now prints in each port's familiar form (record style in
  Java, a composite literal in Go, `(latlon ...)` in Racket).
- Plain `sqrt` replaces `hypot` for degree-sized deviations.

## 1.0.3

- First release of the Haskell port: WGS-84, GCJ-02 and BD-09 transforms,
  the Caijun refinement, and a `vecs` dumper for the cross-language vectors.
