/**
 * People's Rectified Coordinates, C/C++ Header.
 */
#ifndef PRCOORDS_H
#define PRCOORDS_H

/** May be changed to "long double" for bored folks
  * "float" is not recommended
  */
#ifndef PRCOORDS_NUM
#define PRCOORDS_NUM double
#endif

#ifdef __cplusplus
#define PRCOORDS_CONSTEXPR constexpr

#if __cplusplus >= 201300L
#define PRCOORDS_CONSTEXPR14 constexpr
#else
#define PRCOORDS_CONSTEXPR14 inline
#endif // c++14, including 1y

extern "C" {
#else
#include <stdbool.h>
#define PRCOORDS_CONSTEXPR inline
#endif

typedef struct PRCoords {
    PRCOORDS_NUM lat, lon;
} PRCoords;

// make them pure

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

PRCOORDS_CONSTEXPR static bool prcoords_in_china(const PRCoords& a) {
    // cut out some 
    return a.lat >= 16.7414 && a.lon >= 72.004 && a.lat <= 55.8271 && a.lon <= 137.8347;
}

#ifdef __cplusplus
}


inline PRCoords operator- (const PRCoords& a, const PRCoords& b) {
    return PRCoords {
        a.lat - b.lat,
        a.lon - b.lon
    };
}

// for sorting
//   lat
//    |
// -<-o---lon (quadrants III, IV and x < 0)
//  < | <
inline bool operator< (const PRCoords& a, const PRCoords& b) {
    return a.lat < b.lat || (a.lat == b.lat && a.lon < b.lon);
}
inline bool operator> (const PRCoords& a, const PRCoords& b) { return b < a; }
inline bool operator<=(const PRCoords& a, const PRCoords& b) { return !(a > b); }
inline bool operator>=(const PRCoords& a, const PRCoords& b) { return !(a < b); }

inline bool operator==(const PRCoords& a, const PRCoords& b) {
    return a.lat == b.lat && a.lon == b.lon;
}
inline bool operator!=(const PRCoords& a, const PRCoords& b) { return !(a == b); }
#endif // __cplusplus
#endif // header
