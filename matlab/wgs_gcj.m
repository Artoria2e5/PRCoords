function r = wgs_gcj (w)
  % Apply the GCJ-02 distortion to WGS-84 coordinates.
  %
  % Accepts a two-element point or an N-by-2 matrix of points.
  [wlat, wlon] = prcoords_points (w);

  % Krasovsky 1940 ellipsoid
  GCJ_A = 6378245;
  GCJ_EE = 0.00669342162296594323; % f = 1./298.3; e^2 = 2*f - f^2

  % Deviation computation in meters, inlined.
  % [x, y] are relative coords from a common mapped "center" of China.
  x = wlon - 105;
  y = wlat - 35;
  dlat = -100 + 2 .* x + 3 .* y + 0.2 .* y .* y + 0.1 .* x .* y + ...
      0.2 .* sqrt(abs(x)) + (2 .* sinpi(x .* 6) + ...
      2 .* sinpi(x .* 2) + 2 .* sinpi(y) + 4 .* sinpi(y ./ 3) + ...
      16 .* sinpi(y ./ 12) + 32 .* sinpi(y ./ 30)) .* 20 ./ 3;
  dlon = 300 + x + 2 .* y + 0.1 .* x .* x + 0.1 .* x .* y + ...
      0.1 .* sqrt(abs(x)) + (2 .* sinpi(x .* 6) + ...
      2 .* sinpi(x .* 2) + 2 .* sinpi(x) + 4 .* sinpi(x ./ 3) + ...
      15 .* sinpi(x ./ 12) + 30 .* sinpi(x ./ 30)) .* 20 ./ 3;

  % Arc lengths for one degree on the wrong ellipsoid
  magic = 1 - GCJ_EE .* (sind(wlat) .^ 2); % A common expression
  arclen_1lat = pi / 180 .* (GCJ_A .* (1 - GCJ_EE)) ./ magic .^ 1.5;
  arclen_1lon = pi / 180 .*  GCJ_A .* cosd(wlat) ./ magic .^ 0.5;

  % Pack deviations into degrees
  glat = wlat + dlat ./ arclen_1lat;
  glon = wlon + dlon ./ arclen_1lon;
  r = [glat, glon];
end
