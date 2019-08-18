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

// Generic helper definitions for shared library support
#if defined _WIN32 || defined __CYGWIN__
  #define PRCOORDS_HELPER_DLL_IMPORT __declspec(dllimport)
  #define PRCOORDS_HELPER_DLL_EXPORT __declspec(dllexport)
  #define PRCOORDS_HELPER_DLL_LOCAL
#else
  #if __GNUC__ >= 4 // works on clang lmao
    #define PRCOORDS_HELPER_DLL_IMPORT __attribute__ ((visibility ("default")))
    #define PRCOORDS_HELPER_DLL_EXPORT __attribute__ ((visibility ("default")))
    #define PRCOORDS_HELPER_DLL_LOCAL  __attribute__ ((visibility ("hidden")))
  #else
    #define PRCOORDS_HELPER_DLL_IMPORT
    #define PRCOORDS_HELPER_DLL_EXPORT
    #define PRCOORDS_HELPER_DLL_LOCAL
  #endif
#endif

#ifdef PRCOORDS_DLL // defined if PRCOORDS is compiled as a DLL
  #ifdef PRCOORDS_DLL_EXPORTS // defined if we are building the PRCOORDS DLL (instead of using it)
    #define PRCOORDS_API PRCOORDS_HELPER_DLL_EXPORT
  #else
    #define PRCOORDS_API PRCOORDS_HELPER_DLL_IMPORT
  #endif // PRCOORDS_DLL_EXPORTS
  #define PRCOORDS_LOCAL PRCOORDS_HELPER_DLL_LOCAL
#else // PRCOORDS_DLL is not defined: this means PRCOORDS is a static lib.
  #define PRCOORDS_API
  #define PRCOORDS_LOCAL
#endif // PRCOORDS_DLL

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
PRCOORDS_API PRCoords prcoords_wgs_gcj(PRCoords);
PRCOORDS_API PRCoords prcoords_gcj_wgs(PRCoords);
PRCOORDS_API PRCoords prcoords_gcj_bd(PRCoords);
PRCOORDS_API PRCoords prcoords_bd_gcj(PRCoords);
PRCOORDS_API PRCoords prcoords_wgs_bd(PRCoords);
PRCOORDS_API PRCoords prcoords_bd_wgs(PRCoords);

PRCOORDS_API PRCoords prcoords_gcj_wgs_bored(PRCoords);
PRCOORDS_API PRCoords prcoords_bd_gcj_bored(PRCoords);
PRCOORDS_API PRCoords prcoords_bd_wgs_bored(PRCoords);

PRCOORDS_LOCAL PRCOORDS_CONSTEXPR static bool prcoords_in_china(const PRCoords& a) {
    // cut out some 
    return a.lat >= 16.7414 && a.lon >= 72.004 && a.lat <= 55.8271 && a.lon <= 137.8347;
}

#ifdef __cplusplus
}


PRCOORDS_LOCAL inline PRCoords operator- (const PRCoords& a, const PRCoords& b) {
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
PRCOORDS_LOCAL inline bool operator< (const PRCoords& a, const PRCoords& b) {
    return a.lat < b.lat || (a.lat == b.lat && a.lon < b.lon);
}
PRCOORDS_LOCAL inline bool operator> (const PRCoords& a, const PRCoords& b) { return b < a; }
PRCOORDS_LOCAL inline bool operator<=(const PRCoords& a, const PRCoords& b) { return !(a > b); }
PRCOORDS_LOCAL inline bool operator>=(const PRCoords& a, const PRCoords& b) { return !(a < b); }

PRCOORDS_LOCAL inline bool operator==(const PRCoords& a, const PRCoords& b) {
    return a.lat == b.lat && a.lon == b.lon;
}
PRCOORDS_LOCAL inline bool operator!=(const PRCoords& a, const PRCoords& b) { return !(a == b); }
#endif // __cplusplus
#endif // header
