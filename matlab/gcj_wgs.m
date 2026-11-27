function w = gcj_wgs (g)
  % Reverse the GCJ-02 distortion in a rough way.
  %
  % Accepts a two-element point or an N-by-2 matrix of points.
  [glat, glon] = prcoords_points (g);
  gg = wgs_gcj ([glat, glon]);
  w = [2 .* glat - gg(:, 1), 2 .* glon - gg(:, 2)];
end
