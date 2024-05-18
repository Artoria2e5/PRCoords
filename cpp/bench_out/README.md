# bench_out

All four files are made by nanobench; just do `./bench4.sh`.

* `nick` is the version with Nick's fast sinpi.
* `std` is the version with sinpi implemented by `std::sin(M_PI * x)`.
* The ones with `native_` in front are built with `-march=native`.

All the other flags are per Makefile: unsafe math optimizations, no math errno,
you know the drill.

The native versions are just 10% faster. The real win comes from using Nick's
approximation, which quarters the runtime.

There seems to be no real damage to the output.  I mean, nick is at most 1e-3
off.  That's appropriate when we are working in how many meters to shift a
point.

## Update: more agressive nicking

I also applied Nick's approximation to the `arclen` calculation in GCJ.  As
expected of a more important divisor, some visible damage to the output is
seen, but the magnitude remians in the 1e-6 range.  I consider that acceptable,
and it's now the default.

`bd` calculation also now uses nick.

Anyone wishing to turn off nick can use the `-DPRCOORDS_NO_BADMATH` define.
There *might* be a point in turning off nick for specific parts of the
calculation, but I don't want to spend time on that.
