% Dump the eight-column test vectors: read "lat lon" pairs from the file
% named on the command line, or from stdin, and write one row per point with
% the WGS->GCJ, GCJ->BD and WGS->BD results.
%
% Run from the repository root as
%   octave-cli --quiet --path matlab matlab/vecs.m TestVecs/inputs.tsv
% or feed inputs.tsv on stdin.

args = {};
if (exist ('argv', 'builtin') || exist ('argv', 'file'))
  args = argv ();
end

if (numel (args) >= 1)
  fid = fopen (args{1}, 'r');
  if (fid < 0)
    error ('cannot open %s', args{1});
  end
else
  fid = 0;
end

P = zeros (0, 2);
while (true)
  line = fgetl (fid);
  if (~ ischar (line))
    break;
  end
  p = sscanf (line, '%f');
  if (numel (p) < 2)
    continue;
  end
  P(end + 1, :) = p (1:2)';
end

if (fid ~= 0)
  fclose (fid);
end

if (isempty (P))
  return;
end

% One vectorized pass over the whole input.  Note that the gcj_bd column is
% gcj_bd applied to the input itself, matching TestVecs/vec.tsv; wgs_bd is
% the ordinary composition.
w = wgs_gcj (P);
g = gcj_bd (P);
b = wgs_bd (P);
M = [P, w, g, b];
fprintf ('%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\n', M');
