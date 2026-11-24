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

while (true)
  line = fgetl (fid);
  if (~ ischar (line))
    break;
  end
  p = sscanf (line, '%f');
  if (numel (p) < 2)
    continue;
  end
  w = wgs_gcj (p (1:2)');
  g = gcj_bd (p (1:2)');
  b = wgs_bd (p (1:2)');
  fprintf ('%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\n', ...
           p (1), p (2), w (1), w (2), g (1), g (2), b (1), b (2));
end

if (fid ~= 0)
  fclose (fid);
end
