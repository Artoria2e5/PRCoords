function g = bd_gcj (b)
  % Reverse the BD-09 distortion to GCJ-02 coordinates.
  x = b (2) - 0.0065;
  y = b (1) - 0.006;

  r = sqrt (x .* x + y .* y) - 0.00002 * sin (y * pi * 3000 / 180);
  theta = atan2 (y, x) - 0.000003 * cos (x * pi * 3000 / 180);

  gcj_lon = r .* cos (theta);
  gcj_lat = r .* sin (theta);
  g = [gcj_lat, gcj_lon];
endfunction
