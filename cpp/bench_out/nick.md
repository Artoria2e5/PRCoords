Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 550.0 and 4,208.0 MHz

Recommendations
* Use 'pyperf system tune' before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |          ins/op |          cyc/op |    IPC |         bra/op |   miss% |     total | benchmark
|--------------------:|--------------------:|--------:|----------------:|----------------:|-------:|---------------:|--------:|----------:|:----------
|               44.15 |       22,649,946.45 |    0.7% |          448.00 |          179.32 |  2.498 |          38.00 |    0.0% |      0.01 | `wgs_gcj`
|               55.14 |       18,136,609.48 |    1.0% |          465.00 |          225.05 |  2.066 |          40.00 |    0.0% |      0.01 | `gcj_wgs`
|              191.66 |        5,217,656.06 |    0.5% |        1,366.88 |          778.35 |  1.756 |         121.26 |    0.3% |      0.02 | `gcj_wgs_bored`
|              191.38 |        5,225,221.63 |    0.5% |        1,364.36 |          775.94 |  1.758 |         121.03 |    0.2% |      0.02 | `bd_wgs_bored`
|               55.64 |       17,972,068.07 |    0.1% |          391.38 |          227.23 |  1.722 |          55.21 |    2.7% |      0.01 | `gcj_bd`
