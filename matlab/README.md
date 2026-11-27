# PRCoords for MATLAB and Octave

People's Rectified Coordinates (PRCoords) is a cross-language implementation of
"public secret" Chinese coordinate obfuscation methods including GCJ-02 and
BD-09, along with general deobfuscation methods previously established in
ChinaMapShift, eviltransform, and geoChina.

This directory is the MATLAB/Octave port.

The full README, the other language ports and the test vectors live in the
repository: [Artoria2e5/PRCoords](https://github.com/Artoria2e5/PRCoords).

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
