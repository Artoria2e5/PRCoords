# Changelog

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
