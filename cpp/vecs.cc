/**
 * People's Rectified Coordinates, vector dumper.
 *
 * Reads "lat lon" pairs from a file (or stdin), one per line, and writes the
 * same 8-column TSV layout as TestVecs/vec.tsv to stdout: the input pair
 * followed by the wgs_gcj, gcj_bd and wgs_bd results.
 *
 * Feed the result to py/checkvecs.py:
 *
 *   ./vecs ../TestVecs/inputs.tsv | python ../py/checkvecs.py -
 *   python ../py/checkvecs.py --run ./vecs --profile badmath
 */
#include "prcoords.h"
#include "libprcoords.cc"

#include <cstdio>

int main(int argc, char** argv) {
    std::FILE* in = stdin;
    if (argc > 1) {
        in = std::fopen(argv[1], "r");
        if (!in) {
            std::perror(argv[1]);
            return 2;
        }
    }

    char line[256];
    while (std::fgets(line, sizeof line, in)) {
        double lat, lon;
        if (std::sscanf(line, "%lf %lf", &lat, &lon) != 2)
            continue;  // header or junk

        PRCoords p = {(PRCOORDS_NUM) lat, (PRCOORDS_NUM) lon};
        PRCoords wg = prcoords_wgs_gcj(p);
        PRCoords gb = prcoords_gcj_bd(p);
        PRCoords wb = prcoords_wgs_bd(p);

        // 17 significant digits round-trip a double exactly.
        std::printf("%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\n",
                    lat, lon, (double) wg.lat, (double) wg.lon,
                    (double) gb.lat, (double) gb.lon,
                    (double) wb.lat, (double) wb.lon);
    }
    if (in != stdin)
        std::fclose(in);
    return 0;
}
