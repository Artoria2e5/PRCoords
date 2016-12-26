/**
 * People's Rectified Coordinates, C++11 implementation
 * Should yield a C-compatible ABI.
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

/// GCJ APIs should all probably turn on china-checks.
/// But we should allow some override.... Damn C.
PRCoords prcoords_wgs_gcj(PRCoords);
PRCoords prcoords_gcj_wgs(PRCoords);
PRCoords prcoords_gcj_bd(PRCoords);
PRCoords prcoords_bd_gcj(PRCoords);
PRCoords prcoords_wgs_bd(PRCoords);
PRCoords prcoords_bd_wgs(PRCoords);

PRCoords prcoords_gcj_wgs_bored(PRCoords);
PRCoords prcoords_bd_gcj_bored(PRCoords);
PRCoords prcoords_bd_wgs_bored(PRCoords);

bool prcoords_in_china(PRCoords);

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

/// Krasovsky 1940 ellipsoid
/// @const
const double GCJ_A = 6378245;
const double GCJ_EE = 0.00669342162296594323;  // f = 1/298.3; e^2 = 2*f - f**2

/// Epsilon to use for "exact" iterations.
/// Wanna troll? Use Number.EPSILON. 1e-13 in 15 calls for gcj.
/// @const
const double PRCOORDS_EPS = 1e-5;

prcoords_in_china(PRCoords a) {
    return a >= PRCoords{0.8293, 72.004} && a <= PRCoords{55.8271, 137.8347};
}

inline static double diff_sum(PRCoords a, PRCoords b) {
    PRCoords d = a - b;
    return fabs(d.lat) + fabs(d.lon);
}



typedef PRCoords (*ptr_prcoords_conv)(PRCoords);
// These conversions are for bored people: too accurate to be useful
// given pseudo-random noises added to GCJ.
template<ptr_prcoords_conv fwd, ptr_prcoords_conv rev>
PRCoords bored_reverse_conversion(PRCoords bad) {
    PRCoords wgs = rev(bad, false);
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
