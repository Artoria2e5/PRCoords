function g = bd_gcj_precise (b, tol, maxn)
  % Reverse the BD-09 distortion to GCJ-02 coordinates in a precise way.
  if nargin < 2
    tol = 1e-13;
  end
  if nargin < 3
    maxn = 10;
  end
  fun = caijun_precise (@gcj_bd, @bd_gcj);
  g = fun (b, tol, maxn);
endfunction