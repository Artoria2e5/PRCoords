function w = gcj_wgs (g)
  % Reverse the GCJ-02 distortion in a rough way.
  gg = wgs_gcj (g);
  w = g * 2 - gg;
endfunction
