#!/usr/bin/env python3
"""
Cross-implementation checker for the PRCoords test vectors.

Every implementation is expected to be able to dump its three forward
transforms in the same 8-column TSV layout as TestVecs/vec.tsv:

    input_lat input_lon wgs_gcj_lat wgs_gcj_lon gcj_bd_lat gcj_bd_lon
    wgs_bd_lat wgs_bd_lon

This script reads such a dump, from a file or from a command's stdout, and
reports the largest per-transform deviation from the reference vectors
produced by py/gentest.py. The "main" set is what gets graded; the "cusp" set
holds the 105E 35N origin and a sweep around it, and is for looking, not for
grading. See ../TestVecs/README.md.

Examples:

    ./checkvecs.py --run "node ../js/vecs.js" --profile exact
    ./checkvecs.py --run "../cpp/vecs" --profile badmath
    ../cpp/vecs ../TestVecs/inputs.tsv | ./checkvecs.py -
"""
import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.realpath(__file__))
TESTVECS = os.path.join(HERE, os.pardir, 'TestVecs')

#: Vector set -> (reference TSV, input TSV). "cusp" holds the origin of the
#: deviation polynomial and a sweep around it; those vectors are for looking,
#: not for grading. See ../TestVecs/README.md.
SETS = {
    'main': (os.path.join(TESTVECS, 'vec.tsv'),
             os.path.join(TESTVECS, 'inputs.tsv')),
    'cusp': (os.path.join(TESTVECS, 'cusp.tsv'),
             os.path.join(TESTVECS, 'cusp-inputs.tsv')),
}

#: Transform name -> (lat column, lon column) in the 8-column layout.
CHECKS = (
    ('wgs_gcj', 2, 3),
    ('gcj_bd', 4, 5),
    ('wgs_bd', 6, 7),
)

#: Largest acceptable deviation in degrees, by build profile. The reference
#: vectors are CPython doubles, so "exact" means "same expression, same libm":
#: the C++ and JS implementations both match to the last bit.
#:
#:   exact          double or long double with IEEE sin
#:   badmath        double with badmath::sinpi (minimax fit, <0.1 mm)
#:   float          PRCOORDS_NUM=float with IEEE sin (<2.4 m)
#:   float-badmath  both of the above
PROFILES = {
    'exact': 1e-12,
    'badmath': 1e-8,
    'float': 3e-5,
    'float-badmath': 3e-5,
}

METERS_PER_DEG = 111320.


def portable_command(cmd):
    """Let "./vecs" work under cmd.exe, which chokes on the slashed path."""
    if os.name != 'nt':
        return cmd
    head, sep, rest = cmd.partition(' ')
    if '/' not in head:
        return cmd
    return head.replace('/', '\\') + sep + rest


def read_tsv(lines):
    """Parse float rows, skipping blank and non-numeric (header) lines."""
    rows = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            rows.append([float(field) for field in line.split('\t')])
        except ValueError:
            continue
    return rows


def load(path):
    with open(path, 'r') as f:
        return read_tsv(f)


def compare(ref, got, tolerance, per_row=False):
    """Print deviations per transform; return True when all are in bounds."""
    if not ref or not got:
        raise SystemExit('empty reference or candidate')
    if len(ref) != len(got):
        raise SystemExit('row count mismatch: reference %d, candidate %d'
                         % (len(ref), len(got)))
    for i, (r, g) in enumerate(zip(ref, got)):
        if len(r) != 8 or len(g) != 8:
            raise SystemExit('row %d is not an 8-column vector' % (i + 1))

    print('%-10s %12s %12s %10s  %s'
          % ('transform', 'max dlat', 'max dlon', '~meters', 'verdict'))
    ok = True
    for name, ilat, ilon in CHECKS:
        dlat = max(abs(g[ilat] - r[ilat]) for r, g in zip(ref, got))
        dlon = max(abs(g[ilon] - r[ilon]) for r, g in zip(ref, got))
        passed = dlat <= tolerance and dlon <= tolerance
        ok = ok and passed
        print('%-10s %12.4e %12.4e %10.4g  %s'
              % (name, dlat, dlon, max(dlat, dlon) * METERS_PER_DEG,
                 'ok' if passed else 'FAIL'))

    if per_row:
        print('\n%-3s %-26s %12s %10s  %s'
              % ('#', 'input lat lon', 'max dev', '~meters', 'verdict'))
        for i, (r, g) in enumerate(zip(ref, got)):
            dev = max(abs(g[k] - r[k]) for _, ilat, ilon in CHECKS
                      for k in (ilat, ilon))
            print('%-3d %-26s %12.4e %10.4g  %s'
                  % (i + 1, '%r %r' % (r[0], r[1]), dev,
                     dev * METERS_PER_DEG,
                     'ok' if dev <= tolerance else 'FAIL'))
    return ok


def main(argv=None):
    parser = argparse.ArgumentParser(
        description='Compare implementation output with PRCoords test vectors.')
    parser.add_argument('candidate', nargs='?',
                        help='8-column TSV from the implementation '
                             '("-" for stdin)')
    parser.add_argument('--run', metavar='CMD',
                        help='command that reads the input vectors on stdin '
                             'and writes the 8-column TSV on stdout')
    parser.add_argument('--set', default='main', choices=sorted(SETS),
                        help='vector set (default: %(default)s)')
    parser.add_argument('--ref',
                        help='reference TSV (default: vec.tsv, or cusp.tsv '
                             'with --set cusp)')
    parser.add_argument('--inputs',
                        help='input TSV fed to --run (default: inputs.tsv, '
                             'or cusp-inputs.tsv with --set cusp)')
    parser.add_argument('--profile', choices=sorted(PROFILES),
                        default='exact',
                        help='tolerance profile (default: %(default)s)')
    parser.add_argument('--tolerance', type=float,
                        help='override the profile tolerance, in degrees')
    parser.add_argument('-v', '--per-row', action='store_true',
                        help='list every row as well as every transform')
    args = parser.parse_args(argv)

    ref_path, inputs_path = SETS[args.set]
    if args.ref:
        ref_path = args.ref
    if args.inputs:
        inputs_path = args.inputs

    if args.run and args.candidate:
        parser.error('give either a candidate file or --run, not both')
    if not args.run and not args.candidate:
        parser.error('give a candidate file or --run')

    if args.run:
        with open(inputs_path, 'r') as f:
            inputs = f.read()
        proc = subprocess.run(portable_command(args.run), shell=True,
                              input=inputs,
                              stdout=subprocess.PIPE,
                              universal_newlines=True)
        if proc.returncode:
            print('command failed with status %d' % proc.returncode,
                  file=sys.stderr)
            return 2
        got = read_tsv(proc.stdout.splitlines())
    elif args.candidate == '-':
        got = read_tsv(sys.stdin)
    else:
        got = load(args.candidate)

    ref = load(ref_path)
    tolerance = (args.tolerance if args.tolerance is not None
                 else PROFILES[args.profile])

    print('reference: %s (%d vectors)' % (os.path.normpath(ref_path), len(ref)))
    print('tolerance: %.1e deg (profile: %s)'
          % (tolerance, args.profile if args.tolerance is None else 'custom'))
    print()

    if args.set == 'cusp':
        print('note: the cusp point sits where the field has an infinite'
              ' derivative;\n      this set is informational, not a grade\n')

    ok = compare(ref, got, tolerance, args.per_row)
    print('\n%s' % ('all checks passed' if ok else 'FAILED'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
