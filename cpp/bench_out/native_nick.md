Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 550.0 and 4,208.0 MHz

Recommendations
* Use 'pyperf system tune' before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |          ins/op |          cyc/op |    IPC |         bra/op |   miss% |     total | benchmark
|--------------------:|--------------------:|--------:|----------------:|----------------:|-------:|---------------:|--------:|----------:|:----------
|               29.95 |       33,390,729.94 |    0.7% |          223.00 |          118.50 |  1.882 |           2.00 |    0.0% |      0.01 | `wgs_gcj`
|               44.11 |       22,670,466.12 |    0.7% |          238.00 |          175.31 |  1.358 |           4.00 |    0.0% |      0.01 | `gcj_wgs`
|              154.57 |        6,469,750.99 |    0.9% |          684.22 |          611.48 |  1.119 |          13.04 |    2.3% |      0.02 | `gcj_wgs_bored`
|              158.64 |        6,303,428.51 |    2.6% |          683.66 |          626.24 |  1.092 |          13.03 |    2.3% |      0.02 | `bd_wgs_bored`
|               71.44 |       13,998,106.82 |    1.1% |          360.42 |          278.26 |  1.295 |          49.22 |    3.0% |      0.01 | `gcj_bd`
