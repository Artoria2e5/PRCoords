# PRCoords for MATLAB and Octave

Every transform takes one point or an N-by-2 matrix:

```matlab
p = [35 105; 39.9 116.4];   % WGS-84, one point per row
g = wgs_gcj(p);             % GCJ-02
b = gcj_bd(g);              % BD-09
w = gcj_wgs_precise(g);     % iterative inverse

wgs_gcj([35 105])           % 1-by-2
```

The six transforms and the `*_precise` wrappers all accept the matrix form.
`matlab/vecs.m` reads an input TSV and writes the eight-column dump in one pass.
