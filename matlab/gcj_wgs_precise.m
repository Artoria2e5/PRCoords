function w = gcj_wgs_precise (g, tol, maxn)
  if nargin < 2
    tol = 1e-13;
  end
  if nargin < 3
    maxn = 10;
  end
  fun = caijun_precise (@wgs_gcj, @gcj_wgs);
  w = fun (g, tol, maxn);
endfunction
