function fun = caijun_precise (fwd, rev, o, tol, maxn)
  % usage: fun = caijun_precise (@fwd, @rev)
  %
  % With a precise forward obfuscation and a rough deobfuscation
  % function, construct a precise iterative deobfuscation function.
  %
  % A custom tolilon for "fixed point" detection can be specified
  % with the "tol" operand. The default value is 1e-4 degrees.
  % 
  % A custon max iteration limit can be specified with the "maxn"
  % operand. The default value is 10 iterations.
  %
  % (caijun/geoChina; 2014)

  function c = rectify (o, tol, maxn)
    % Given obfuscated coords,
    % return something that appears much less wrong to us.
    c = rev (o);
    d = c - o;
    
    for i = 1:maxn
      if (max(abs(d (1))) + max(abs(d (2))) <= tol)
        break;
      end
      d = fwd(c) - o;
      c -= d;
    end
  endfunction
  fun = @rectify;
endfunction
