function b = gcj_bd (g)
  % Apply the BD-09 distortion to GCJ-02 coordinates.
  x = g (2);
  y = g (1);

  r = sqrt (x .* x + y .* y) + 0.00002 * sinpi (y * 3000 / 180);
  theta = atan2 (y, x) + 0.000003 * cospi (x * 3000 / 180);

  bd_lon = r .* cos (theta) + 0.0065;
  bd_lat = r .* sin (theta) + 0.006;
  b = [bd_lat, bd_lon];
end
