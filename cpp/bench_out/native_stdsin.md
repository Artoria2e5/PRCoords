Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 550.0 and 4,208.0 MHz

Recommendations
* Use 'pyperf system tune' before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |          ins/op |          cyc/op |    IPC |         bra/op |   miss% |     total | benchmark
|--------------------:|--------------------:|--------:|----------------:|----------------:|-------:|---------------:|--------:|----------:|:----------
|              194.53 |        5,140,660.72 |    0.3% |        1,279.44 |          771.57 |  1.658 |         160.05 |    7.0% |      0.02 | `wgs_gcj`
|              196.29 |        5,094,624.89 |    0.2% |        1,294.55 |          775.42 |  1.669 |         162.05 |    6.9% |      0.02 | `gcj_wgs`
|              625.05 |        1,599,860.70 |    0.2% |        3,857.64 |        2,458.17 |  1.569 |         488.67 |    5.6% |      0.07 | `gcj_wgs_bored`
|              628.28 |        1,591,638.82 |    0.2% |        3,865.01 |        2,467.08 |  1.567 |         489.52 |    5.6% |      0.08 | `bd_wgs_bored`
|               90.49 |       11,050,353.38 |    0.5% |          540.37 |          355.40 |  1.520 |          77.20 |    5.4% |      0.01 | `gcj_bd`
