#!/usr/bin/env python3
"""Simplify a boundary GeoJSON for point-in-polygon containment.

Holes are dropped: the test should say yes inside lakes and other enclaves.
Outer rings are rounded to a fixed precision and thinned with
Visvalingam-Whyatt, using a small effective-area limit on land borders and a
much larger one on the sea-facing coast.

The sea coast is only allowed to lose deep capes up to --allow, and is then
shifted seaward by --grow.  The result therefore invents its own points
there and prefers to include a little water over losing a coastal town.
Land-grade detail is kept inside the keep discs.

    simplify.py IN.geojson OUT.geojson [--precision 4] [--land-area 4e-4]
                [--sea-area 0.04] [--allow 0.02] [--grow 0.2]
                [--sea-lon 108.3] [--sea-lat 40] [--keep LAT,LON,R]...
"""
import argparse
import heapq
import json
import math
import sys


def vw(pts, limit, allow=None):
    """Visvalingam-Whyatt: indices of the points to keep, ends included.
    When allow is set, a land-turning vertex may only go if that cuts less
    than allow degrees into the interior."""
    n = len(pts)
    alive = bytearray(b"\x01") * n
    prev = [i - 1 if i else 0 for i in range(n)]
    nxt = [i + 1 if i < n - 1 else n - 1 for i in range(n)]

    def tri(i):
        ax, ay = pts[prev[i]]
        bx, by = pts[i]
        cx, cy = pts[nxt[i]]
        return abs((bx - ax) * (cy - ay) - (cx - ax) * (by - ay)) / 2, \
            (bx - ax) * (cy - by) - (cx - bx) * (by - ay)

    area = [0.0] * n
    todo = []
    for i in range(1, n - 1):
        area[i], _ = tri(i)
        heapq.heappush(todo, (area[i], i))
    while todo:
        a, i = heapq.heappop(todo)
        if not alive[i]:
            continue
        cur, turn = tri(i)
        if abs(cur - a) > 1e-12:
            area[i] = cur
            heapq.heappush(todo, (cur, i))
            continue
        if cur > limit:
            continue
        if allow is not None and turn > 0:
            ax, ay = pts[prev[i]]
            cx, cy = pts[nxt[i]]
            h = math.hypot(cx - ax, cy - ay) or 1.0
            if 2 * cur / h > allow:
                continue
        alive[i] = 0
        p, q = prev[i], nxt[i]
        nxt[p] = q
        prev[q] = p
        for j in (p, q):
            if alive[j] and 0 < j < n - 1:
                area[j], _ = tri(j)
                heapq.heappush(todo, (area[j], j))
    return [i for i in range(n) if alive[i]]


def unit(x, y):
    h = math.hypot(x, y) or 1.0
    return x / h, y / h


def offset(pts, d):
    """Shift a sea run outward by d and keep its ends.  The run goes
    counter-clockwise, so the sea is on the right of each segment."""
    out = [pts[0]]
    for i in range(1, len(pts) - 1):
        x1, y1 = pts[i - 1]
        x2, y2 = pts[i]
        x3, y3 = pts[i + 1]
        ax, ay = unit(y2 - y1, x1 - x2)
        bx, by = unit(y3 - y2, x2 - x3)
        nx, ny = ax + bx, ay + by
        h = math.hypot(nx, ny)
        if h < 0.2:
            nx, ny = ax, ay
        else:
            nx, ny = nx / h, ny / h
        s = d / max(0.35, h)
        out.append((x2 + nx * s, y2 + ny * s))
    out.append(pts[-1])
    return out


def simplify_ring(ring, params_of):
    pts = [(p[0], p[1]) for p in ring[:-1]]
    n = len(pts)
    ep = [params_of(p) for p in pts]
    k = next((i for i in range(n) if ep[i] != ep[i - 1]), None)
    if k is None:
        seg = pts + [pts[0]]
        return [seg[i] for i in vw(seg, ep[0][0])[:-1]]
    pts, ep = pts[k:] + pts[:k], ep[k:] + ep[:k]
    out, s = [], 0
    for i in range(1, n + 1):
        if i < n and ep[i] == ep[s]:
            continue
        seg = pts[s:] + [pts[0]] if i == n else pts[s:i + 1]
        limit, allow, grow = ep[s]
        seg = [seg[j] for j in vw(seg, limit, allow)]
        if grow:
            seg = offset(seg, grow)
        out.extend(seg[:-1])
        s = i
    out.append(out[0])
    return out


def finish(ring, prec):
    out = []
    for x, y in ring:
        p = (round(x, prec), round(y, prec))
        if not out or p != out[-1]:
            out.append(p)
    if len(out) > 1 and out[0] != out[-1]:
        out.append(out[0])
    return [[x, y] for x, y in out]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("-p", "--precision", type=int, default=4)
    ap.add_argument("--land-area", type=float, default=4e-4)
    ap.add_argument("--sea-area", type=float, default=0.04)
    ap.add_argument("--allow", type=float, default=0.02,
                    help="deepest cut a sea cape may take, in degrees")
    ap.add_argument("--grow", type=float, default=0.2,
                    help="seaward shift applied after thinning the coast")
    ap.add_argument("--sea-lon", type=float, default=108.3)
    ap.add_argument("--sea-lat", type=float, default=40.0)
    ap.add_argument("--keep", action="append", default=[],
                    metavar="LAT,LON,R",
                    help="keep land-grade detail within R degrees of LAT,LON")
    args = ap.parse_args()
    keep = [tuple(map(float, k.split(","))) for k in args.keep]
    if not keep:
        keep = [(24.42, 118.34, 0.35), (26.16, 120.20, 0.45)]

    def params_of(p):
        lon, lat = p
        for klat, klon, kr in keep:
            if (lon - klon) ** 2 + (lat - klat) ** 2 < kr * kr:
                return args.land_area, None, 0.0
        if lon > args.sea_lon and lat < args.sea_lat:
            return args.sea_area, args.allow, args.grow
        return args.land_area, None, 0.0

    if args.input.endswith(".xz"):
        import lzma
        with lzma.open(args.input, "rt", encoding="utf-8") as f:
            d = json.load(f)
    else:
        with open(args.input, encoding="utf-8") as f:
            d = json.load(f)
    rings = [p[0] for f in d["features"] for p in f["geometry"]["coordinates"]]
    main = max(range(len(rings)), key=lambda i: len(rings[i]))
    if sum(rings[main][i][0] * rings[main][i + 1][1] - rings[main][i][1] * rings[main][i + 1][0]
           for i in range(len(rings[main]) - 1)) < 0:
        rings[main] = rings[main][::-1]
    out = []
    for i, ring in enumerate(rings):
        params = params_of if i == main else lambda p: (args.land_area, None, 0.0)
        simple = finish(simplify_ring(ring, params), args.precision)
        print(f"{len(ring)} -> {len(simple)}", file=sys.stderr)
        if len(simple) > 3:
            out.append(simple)
    with open(args.output, "w", encoding="utf-8") as f:
        json.dump({"type": "MultiPolygon",
                   "coordinates": [[r] for r in out]}, f,
                  separators=(",", ":"))
    print(f"{len(rings)} rings, {sum(map(len, out))} points", file=sys.stderr)


if __name__ == "__main__":
    main()
