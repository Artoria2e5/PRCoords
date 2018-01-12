/**
 * People's Rectified Coordinates, C++ demo.
 */

#if PRCOORDS_DEMO_FORCE_STANDALONE
#include "libprcoords.cc"
#else
#include "prcoords.h"
#endif

#include <iostream>
#include <string>
using namespace std;

#ifndef PRCOORDS_STON
#define PRCOORDS_STON stod
#endif

std::string show_coord(PRCoords v) {
    return std::to_string(v.lat) + ", " + std::to_string(v.lon);
}

PRCoords parse_coord(const string& s) {
    int cut = s.find(", ");
    return PRCoords{
        PRCOORDS_STON(s.substr(0, cut)),
        PRCOORDS_STON(s.substr(cut + 1))
    };
}

int main(void) {
    string input;

    while (getline(cin, input))
    {
        PRCoords v = std::move(parse_coord(input));
        cout
            << "w2g\t" << show_coord(prcoords_wgs_gcj(v)) << endl
            << "w2b\t" << show_coord(prcoords_wgs_bd(v)) << endl
            << "g2b\t" << show_coord(prcoords_gcj_bd(v)) << endl
            << "g2wQ\t" << show_coord(prcoords_gcj_wgs(v)) << endl
            << "b2wQ\t" << show_coord(prcoords_bd_wgs(v)) << endl
            << "b2gQ\t" << show_coord(prcoords_bd_gcj(v)) << endl
            << "g2wP\t" << show_coord(prcoords_gcj_wgs_bored(v)) << endl
            << "b2wP\t" << show_coord(prcoords_bd_wgs_bored(v)) << endl
            << "b2gP\t" << show_coord(prcoords_bd_gcj_bored(v)) << endl
            << endl;
    }
}
