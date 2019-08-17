function v = PRCoords()
  %% People's Rectified Coordinates: Chinese geographic obfuscations
  %% Dedicated to the Public Domain under CC0.
  %% Mingye Wang (Artoria2e5), 2017.
  %% @url https://github.com/Artoria2e5/PRCoords
  v = "To be split"
end

function [glat, glon] = wgs_gcj (wlat, wlon)
  % usage: [glat, glon] = wgs_gcj (wlat, wlon)
  %
  % Apply the GCJ-02 distortion to WGS-84 coordinates.

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
endfunction

function [wlat, wlon] = gcj_wgs (glat, glon)
  % usage: [wlat, wlon] = gcj_wgs (glat, glon)
  %
  % Reverse the GCJ-02 distortion in a rough way.
  [gglat, gglon] = wgs_gcj(glat, glon)
  wlat = glat .* 2 - gglat
  wlon = glon .* 2 - gglon
endfunction


function fun = caijun_precise (fwd, rev, eps, maxn)
  % usage: fun = caijun_precise (fwd, rev)
  %        fun = caijun_precise (fwd, rev, eps)
  %        fun = caijun_precise (fwd, rev, eps, maxn)
  %
  % With a precise forward obfuscation and a rough deobfuscation
  % function, construct a precise iterative deobfuscation function.
  %
  % A custom epsilon for "fixed point" detection can be specified
  % with the "eps" operand. The default value is 1e-4 degrees.
  % 
  % A custon max iteration limit can be specified with the "maxn"
  % operand. The default value is 10 iterations.
  %
  % (caijun/geoChina; 2014)
  if (~exist('eps', 'var'))
    eps = 1e-4;
  end

  % 10 iterations ought to be enough for anybody. I wonder why I am adding this.
  if (~exist('maxn', 'var'))
    maxn = 10;
  end

  % scope magic?
  fwd = fwd;
  rev = rev;
  eps = eps;
  maxn = maxn;
  
  function [clat, clon] = rectify (olat, olon)
    % usage: [clat, clon] = rectify (olat, olon)
    %
    % Given obfuscated coords,
    % return something that appears much less wrong to us.
    [clat, clon] = rev(olat, olon);
    plat = olat;
    plon = olon;
    
    % Hmm. If something falls behind, we all go for another iter.
    % Can't we just execute these failing outliers and use an average for eps?
    for i = 1:maxn
      if (max(max(abs(clat - olat)), max(abs(clon - olon))) < eps)
        break;
      end
      % prev = curr
      plat = clat;
      plon = clon;
      % get two distortions
      [flat, flon] = fwd(clat, clon);
      % apply iterative step: good -= (fwd(good) - orig)
      clat -= flat - olat;
      clon -= flon - olon;
    end
  endfunction
  fun = rectify;
endfunction
