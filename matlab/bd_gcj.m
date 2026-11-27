function g = bd_gcj (b)
  % Reverse the BD-09 distortion to GCJ-02 coordinates.
  %
  % Accepts a two-element point or an N-by-2 matrix of points.
  [blat, blon] = prcoords_points (b);
  x = blon - 0.0065;
  y = blat - 0.006;

  r = sqrt (x .* x + y .* y) - 0.00002 * sinpi (y * 3000 / 180);
  theta = atan2 (y, x) - 0.000003 * cospi (x * 3000 / 180);

  gcj_lon = r .* cos (theta);
  gcj_lat = r .* sin (theta);
  g = [gcj_lat, gcj_lon];
end
