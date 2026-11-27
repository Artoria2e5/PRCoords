function [lat, lon] = prcoords_points (p)
  % Normalize a coordinate input to column vectors.
  %
  % A coordinate may be a two-element vector (row or column) for a single
  % point, or an N-by-2 matrix with one point per row.  The transforms use
  % the returned columns elementwise, so both shapes share one code path.
  if (isvector (p) && numel (p) == 2)
    lat = p (1);
    lon = p (2);
  elseif (size (p, 2) == 2)
    lat = p (:, 1);
    lon = p (:, 2);
  else
    error ('prcoords:badshape', ...
           'expected a two-element point or an N-by-2 matrix');
  end
end
