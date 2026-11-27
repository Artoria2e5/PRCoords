function fun = caijun_precise (fwd, rev, o, tol, maxn)
  % usage: fun = caijun_precise (@fwd, @rev)
  %
  % With a precise forward obfuscation and a rough deobfuscation
  % function, construct a precise iterative deobfuscation function.
  %
  % The "tol" operand is the fixed-point threshold in degrees and the
  % "maxn" operand caps the number of iterations.  The wrappers default
  % to 1e-13 degrees and 10.
  % (caijun/geoChina; 2014)

  function c = rectify (o, tol, maxn)
    % Given obfuscated coords,
    % return something that appears much less wrong to us.
    %
    % Inputs and outputs are normalized to N-by-2 so the iteration works
    % on whole coordinate arrays at once.
    [olat, olon] = prcoords_points (o);
    o = [olat, olon];
    c = rev (o);
    d = c - o;

    for i = 1:maxn
      if (all (max (abs (d), [], 2) <= tol))
        break;
      end
      d = fwd (c) - o;
      c = c - d;
    end
  end
  fun = @rectify;
end
