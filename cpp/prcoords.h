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
extern "C" {
#else
#include <stdbool.h>
#endif

typedef struct PRCoords {
    PRCOORDS_NUM lat, lon;
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
