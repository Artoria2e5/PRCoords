Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 550.0 and 4,208.0 MHz

Recommendations
* Use 'pyperf system tune' before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |          ins/op |          cyc/op |    IPC |         bra/op |   miss% |     total | benchmark
|--------------------:|--------------------:|--------:|----------------:|----------------:|-------:|---------------:|--------:|----------:|:----------
|                3.24 |      308,253,800.28 |    0.2% |           22.00 |           12.97 |  1.696 |           0.00 |    0.0% |      0.01 | `nop`
|              216.41 |        4,620,855.79 |    6.9% |        1,315.38 |          853.91 |  1.540 |         160.04 |    7.2% |      0.03 | :wavy_dash: `wgs_gcj` (Unstable with ~10,854.4 iters. Increase `minEpochIterations` to e.g. 108544)
|              206.03 |        4,853,603.19 |    1.4% |        1,332.00 |          811.94 |  1.641 |         162.03 |    7.0% |      0.03 | `gcj_wgs`
|              653.44 |        1,530,359.50 |    1.0% |        3,973.24 |        2,546.70 |  1.560 |         488.60 |    5.6% |      0.08 | `gcj_wgs_bored`
|              653.92 |        1,529,245.44 |    0.6% |        3,976.15 |        2,533.60 |  1.569 |         488.87 |    5.6% |      0.08 | `bd_wgs_bored`
|               93.34 |       10,713,089.73 |    0.4% |          543.42 |          361.83 |  1.502 |          77.21 |    5.5% |      0.01 | `gcj_bd`
