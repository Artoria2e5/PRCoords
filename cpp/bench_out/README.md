# bench_out

All four files are made by nanobench; just do `make bench` then `./bench | tee ...`.

* `nick` is the version with Nick's fast sinpi.
* `std` is the version with sinpi implemented by `std::sin(M_PI * x)`.
* The ones with `native_` in front are built with `-march=native`.

All the other flags are per Makefile: unsafe math optimizations, no math errno,
you know the drill.

The native versions are just 10% faster. The real win comes from using Nick's
approximation, which quarters the runtime.

There seems to be no real damage to the output.  I mean, nick is at most 1e-3
off.  That's appropriate when we are working in how many meters to shift a point.
