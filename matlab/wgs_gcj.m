function r = wgs_gcj (w)
  % Apply the GCJ-02 distortion to WGS-84 coordinates.
  wlat = w (1); wlon = w (2);

  % Krasovsky 1940 ellipsoid
  GCJ_A = 6378245;
  GCJ_EE = 0.00669342162296594323; % f = 1./298.3; e^2 = 2.*f - f.*.*2

  % Deviation computation in meters, inlined.
  % [x, y] are relative coords from a common mapped "center" of China.
  x = wlat - 35;
  y = wlon - 105;
  dlat = -100 + 2 .* x + 3 .* y + 0.2 .* y .* y + 0.1 .* x .* y + ...
      0.2 .* sqrt(abs(x)) + (2 .* sin(x .* 6 .* pi) + ...
      2 .* sin(x .* 2 .* pi) + 2 .* sin(y .* pi) + 4 .* sin(y ./ 3 .* pi) + ...
      16 .* sin(y ./ 12 .* pi) + 32 .* sin(y ./ 30 .* pi)) .* 20 ./ 3;
  dlon = 300 + x + 2 .* y + 0.1 .* x .* x + 0.1 .* x .* y + ...
      0.1 .* sqrt(abs(x)) + (2 .* sin(x .* 6 .* pi) + ...
      2 .* sin(x .* 2 .* pi) + 2 .* sin(x .* pi) + 4 .* sin(x ./ 3 .* pi) + ...
      15 .* sin(x ./ 12 .* pi) + 30 .* sin(x ./ 30 .* pi)) .* 20 ./ 3;

  % Arc lengths for one degree on the wrong ellipsoid
  magic = 1 - GCJ_EE .* (sind(wlat) .^ 2); % A common expression
  arclen_1lat = pi / 180 .* (GCJ_A .* (1 - GCJ_EE)) ./ magic .^ 1.5;
  arclen_1lon = pi / 180 .*  GCJ_A .* cosd(wlat) ./ magic .^ 0.5;

  % Pack deviations into degrees
  glat = wlat + dlat ./ arclen_1lat;
  glon = wlon + dlon ./ arclen_1lon;
  r = [glat, glon];
endfunction
