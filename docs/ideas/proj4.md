# Putting PRCoords into PROJ

Plan only.  Target PROJ 9.9.0 (2026-09-15).  There is no plugin ABI in `src/`, so until
upstream takes it, this is a fork.

Decided 2026-11-27: model GCJ as a coordinate operation, let the README's WKT1 and
EPSG:888000 strings die, and ask upstream anyway.

## Two operations

| +proj   | maps                                              | form |
|---------|---------------------------------------------------|------|
| `gcj02` | WGS-84 <-> GCJ-02, identity outside the China box | `PJ_TRANSFORMATION`, radians |
| `bd09`  | GCJ-02 <-> BD-09                                  | `PJ_TRANSFORMATION`, radians |

WGS-84 to BD-09 is the pipeline of the two.  BD-09 Mercator appends
`+proj=merc +a=6378206.4 +b=6356583.8` (Clark 1866).  `bd09` stays the GCJ->BD primitive
because that is the definition, and pipelines compose without special cases.

Shape them like `geogoffset` (`src/transformations/affine.cpp`): `PJ_TRANSFORMATION(name,
need_ellps)` (`src/proj_internal.h:891`) with `P->left = P->right = PJ_IO_UNITS_RADIANS`.

A projection cannot do this honestly: it must emit linear units, so degree output means
faking a projected CRS with `+units=deg` (the unit exists, `src/units.cpp:47`).  That was
the old README trick, and it makes QGIS show a projected CRS with degree axes.  Dropping
it costs a few documented strings.

## CRS layer

WKT2 text, shipped with the docs.  A conversion may name
`PROJ-based operation method: +proj=...`, which PROJ parses into a `PROJBasedOperation`
(`src/iso19111/io.cpp:5901`, `:5922`):

```wkt
GEOGCRS["GCJ-02",
  BASEGEOGCRS["WGS 84", ...],
  DERIVINGCONVERSION["GCJ-02",
    METHOD["PROJ-based operation method: +proj=gcj02 +ellps=WGS84"]],
  CS[ellipsoidal, 2, ...], AXIS[...], ANGLEUNIT["degree", ...]]
```

BD-09 uses `+proj=pipeline +step +proj=gcj02 +step +proj=bd09`.  BD-09 Mercator is a
`PROJCRS` with that pipeline plus the merc step.  No authority code, no `proj.db` row.

The README's WKT1 blocks will not come back to life: `EXTENSION["PROJ4", ...]` is
special-cased only for `ob_tran` (`io.cpp:5760`).  The FAQ gets rewritten in both
languages.

## Math

Shared core, one file.

- Krasovsky 1940 constants and the two 12-sine polynomials are hardcoded.  The CRS
  ellipsoid never enters, so `+ellps=GRS80` must produce identical numbers.
- `sinpi(x) = sin(x*pi)`.  The d4 fit costs 0.1 mm and stays optional in the C port;
  PROJ uses libm.
- Inverse by fixed point, 3 to 5 iterations, 1e-12 deg.  `_bored` at 1e-5 deg is
  meter-ish.
- Identity outside 0.8293..55.8271 N, 72.004..137.8347 E.  That is the Python/JS box
  with Hainan; the C++ header's 16.7414 cut is not used.  No parameter, and the ~300 m
  edge jump gets documented.
- Longitude stays unwrapped; the polynomial is absolute in lon-105.
- z passes through.  `bd09` skips the China check.

## C port first

`c/prcoords.{h,c}`, `c/vecs.c`, `c/smoke.c`, `c/Makefile`; C99, same symbols as
`cpp/prcoords.h`, so the JNI bridge and ctypes/cffi can bind either.  Knobs:
`PRCOORDS_NUM` and `PRCOORDS_SINPI=std|d4`.

Run `py/checkvecs.py` over the dump before touching PROJ.  The 60 vectors catch a
mistyped coefficient faster than reading does.

## PROJ patch

- `src/transformations/gcj02.cpp`: two `PROJ_HEAD`s, two `PJ_TRANSFORMATION`s, static
  helpers, MIT header with a provenance note
- `src/lib_proj.cmake`: one line in `SRC_LIBPROJ_TRANSFORMATIONS`
- `src/pj_list.h`: two lines
- `docs/source/operations/transformations/{gcj02,bd09}.rst` and index entries
- `test/gie/prcoords.gie` plus one `proj_add_gie_test` line; wrap in a pipeline with
  `unitconvert` so gie reads degrees
- `test/unit/test_prcoords.cpp`: border vectors, ellipsoid invariance, outside identity
- nothing in `data/sql`

## proj4j

proj4j is a PROJ 4 port: one projection per CRS, one datum hop, no pipelines, no derived
CRS, no WKT2.  GCJ there can only be a pseudo-projection, and BD-09 has to be a single
composite class.  That is acceptable because proj4j has no `proj.db`, no authority codes
and no WKT2 to pollute.

The degree trick is native: `Projection.project(double lam, double phi, dst)` receives
radians, and `projectRadians` multiplies by RTD when `unit == Units.DEGREES`
(`Projection.java:279`).  `+units=deg` parses (`Proj4Parser.java:145`), and
`LongLatProjection` is the precedent.  No `wrap()` like the proj4js plugin.

Registration is the gap.  `Registry.register` is private (`Registry.java:120`), so this
is a fork plus one line in `initialize()`, or hand-built
`CoordinateReferenceSystem(..., new Gcj02Projection())` objects.  Reuse
`java/src/.../PRCoords.java`; expect about 100 lines.

## Spike

Build 9.9.0 and answer four questions.

1. Does `proj_create`/`projinfo`/`cs2cs` accept the WKT2 derived GEOGCRS, and is the
   WGS84 to GCJ pipeline free of datum shifts?
2. Does the BD-09 Mercator PROJCRS work the same way?
3. Does QGIS take the WKT as a custom CRS?
4. Do `+proj=pipeline +step +proj=gcj02 +step +proj=merc ...` and `proj_trans` compose
   as expected?

If derived CRSs fail: pipeline-only docs first, then the pseudo-projection as a private
fallback.

## Acceptance

60 border vectors within 1e-10 deg forward, cusp sweep reproduced, round trip below
1e-11 deg, identity outside, BD09MC matching 11689750 and 4139877, `proj -l` listing
both names, docs build, tests and clang-format clean.

## Upstream

Issue first, PR second, branch rebased per release.  The pitch: a coordinate operation
with no authority code, existing to undo a mandated obfuscation, changing nothing until
someone asks for it.  Answers ready for "not a real transformation" (`geogoffset` is not
either), "politically sensitive" (document it), "accuracy is meaningless" (agreed, say
so), "bloat" (two ops, one file).

If yes, the WKT2 snippets can become a `proj.db` convenience later, as a separate
argument.  If no, the fork and `c/` are the product.

## Not doing

Datum, grids, authority codes, `proj.db`, `+units=deg` in the first cut, SIMD, float,
minified source.

## Order

Spike, C port, PROJ patch, README FAQ and WKT recipe, upstream issue.
