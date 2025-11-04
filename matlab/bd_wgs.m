function w = bd_wgs (b)
  % Reverse the BD-09 distortion to WGS-84 coordinates.
  g = bd_gcj (b);
  w = gcj_wgs (g);
endfunction