/**
 * People's Rectified Coordinates, C++11 implementation
 * Should yield a C-compatible ABI.
 * 
 */
#define PRCOORDS_TEST

#if !defined(PRCOORDS_H) && !defined(PRCOORDS_NO_HEADER)
#define PRCOORDS_H

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

typedef struct PRCoords {
    double lat, lon;
} PRCoords;

PRCoords wgs_gcj(PRCoords, bool);
PRCoords gcj_wgs(PRCoords, bool);
PRCoords gcj_bd(PRCoords, bool);
PRCoords bd_gcj(PRCoords, bool);
PRCoords wgs_bd(PRCoords, bool);
PRCoords bd_wgs(PRCoords, bool);

PRCoords gcj_wgs_bored(PRCoords, bool);
PRCoords bd_gcj_bored(PRCoords, bool);
PRCoords bd_wgs_bored(PRCoords, bool);

#ifdef __cplusplus
}


inline PRCoords operator- (PRCoords a, PRCoords b) {
    return PRCoords {
        a.lat - b.lat,
        a.lon - b.lon
    };
}

inline bool operator< (PRCoords a, PRCoords b) {
    return a.lat < b.lat || a.lon < b.lon;
}
inline bool operator> (PRCoords a, PRCoords b) { return b < a; }
inline bool operator<=(PRCoords a, PRCoords b) { return !(a > b); }
inline bool operator>=(PRCoords a, PRCoords b) { return !(a < b); }

inline bool operator==(PRCoords a, PRCoords b) {
    return a.lat == b.lat && a.lon == b.lon;
}
inline bool operator!=(PRCoords a, PRCoords b) { return !(a == b); }
#endif // __cplusplus
#endif // header

#if !defined(PRCOORDS_HEADER_ONLY) && defined(__cplusplus)
#include <cmath>
#include <functional>

const double PRCOORDS_EPS = 1e-5;

inline static bool sanity_in_china(PRCoords a);
inline static bool sanity_in_china(PRCoords a) {
    return a >= PRCoords{0.8293, 72.004} && a <= PRCoords{55.8271, 137.8347};
}

inline static double diff_sum(PRCoords a, PRCoords b) {
    PRCoords d = a - b;
    return fabs(d.lat) + fabs(d.lon);
}

// These conversions are for bored people: too accurate to be useful
// given pseudo-random noises added to GCJ.
template<std::function fwd, std::function rev>
PRCoords bored_reverse_conversion(PRcoords bad) {
    PRCoords wgs = rev(bad);
    // ...
    return wgs;
}

#ifdef PRCOORDS_TEST
#include <iostream>
#include <type_traits>
int main(void) {
    std::cout << std::is_pod<PRCoords>::value << std::endl;
}
#endif
#endif
