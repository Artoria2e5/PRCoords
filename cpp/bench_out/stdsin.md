Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 550.0 and 4,208.0 MHz

Recommendations
* Use 'pyperf system tune' before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |          ins/op |          cyc/op |    IPC |         bra/op |   miss% |     total | benchmark
|--------------------:|--------------------:|--------:|----------------:|----------------:|-------:|---------------:|--------:|----------:|:----------
|              200.92 |        4,977,173.68 |    2.0% |        1,315.30 |          801.53 |  1.641 |         160.03 |    7.0% |      0.03 | `wgs_gcj`
|              200.63 |        4,984,178.96 |    0.4% |        1,332.44 |          800.42 |  1.665 |         162.04 |    6.9% |      0.02 | `gcj_wgs`
|              630.61 |        1,585,756.39 |    0.1% |        3,975.75 |        2,525.20 |  1.574 |         489.29 |    5.6% |      0.08 | `gcj_wgs_bored`
|              633.69 |        1,578,065.39 |    0.7% |        3,971.60 |        2,529.31 |  1.570 |         488.49 |    5.6% |      0.08 | `bd_wgs_bored`
|               90.52 |       11,047,372.25 |    0.3% |          543.35 |          358.15 |  1.517 |          77.20 |    5.4% |      0.01 | `gcj_bd`
