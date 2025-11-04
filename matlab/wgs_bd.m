function b = wgs_bd (w)
  % Apply the BD-09 distortion to WGS-84 coordinates.
  g = wgs_gcj (w);
  b = gcj_bd (g);
endfunction