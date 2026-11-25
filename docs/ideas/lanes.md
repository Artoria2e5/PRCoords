How can we do SIMD right?
=========================

One elem per lane
-----------------

The most obviously correct way is to do it element-wise.
Every op can just be broadcast.
The only issue, "bored", can be rewritten by a fixed number of iters (3).

Well there's also the inChina check.
You could mask that, but I'd bet it's not even needed for callers who know
what they're doing.


Within wgs_gcj
--------------

The sillier idea is to do micromanagement of `wgs_gcj`, ONLY.
Recall the two big ugly ones:

```js
dLat_m = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y
    + 0.2 * sqrt(fabs(x)) + (
    2 * sinpi(x * 6) + 2 * sinpi(x * 2)
    + 2 * sinpi(y) + 4 * sinpi(y / 3)
    + 16 * sinpi(y / 12) + 32 * sinpi(y / 30)
    ) * 20 / 3;
dLon_m = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y
    + 0.1 * sqrt(fabs(x)) + (
        2 * sinpi(x * 6) + 2 * sinpi(x * 2)
        + 2 * sinpi(x) + 4 * sinpi(x / 3)
        + 15 * sinpi(x / 12) + 30 * sinpi(x / 30)
    ) * 20 / 3;
```

we could instead say:

```js
// Surely the compiler can do these two
dLat_m = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y
dLon_m = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y

SQRTX  = sqrt(fabs(x)) * 0.1
COM1   = 2 * sinpi(x * 6) + 2 * sinpi(x * 2)
FACT   = 20 / 3

COM2f  = (x) => [sinpi(x), sinpi(x / 3), sinpi(x / 12), sinpi(x / 30)]
DOT    = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
COM2   = COM2f(y)

dLat_m += 2 * SQRTX + COM1 + DOT(COM2, [2, 4, 16, 32]) * FACT
dLon_m +=     SQRTX + COM1 + DOT(COM2, [2, 4, 15, 30]) * FACT
```

COM2f can be efficiently done by naively broadcasting badmath sinpi.


pnpoly
------

This has been pretty well-studied.
First you'd precompute the slopes of the edges.

The multi-point case is the regular thing just expanded to more lanes.

The single-point case is a case of reduction op with XOR.
