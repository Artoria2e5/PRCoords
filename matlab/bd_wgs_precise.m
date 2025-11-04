function w = bd_wgs_precise (b, tol, maxn)
  % Reverse the BD-09 distortion to WGS-84 coordinates in a precise way.
  if nargin < 2
    tol = 1e-13;
  end
  if nargin < 3
    maxn = 10;
  end
  fun = caijun_precise (@wgs_bd, @bd_wgs);
  w = fun (b, tol, maxn);
endfunction
