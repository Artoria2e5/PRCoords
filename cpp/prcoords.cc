/**
 * People's Rectified Coordinates, C++11 implementation
 * Should yield a C-compatible ABI.
 */
#define PRCOORDS_TEST 1

/** May be changed to "long double" for bored folks
  * "float" is not recommended
  */
#ifndef PRCOORDS_NUM
#define PRCOORDS_NUM double
#endif

#if !defined(PRCOORDS_H) && !defined(PRCOORDS_NO_HEADER)
#define PRCOORDS_H

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


inline PRCoords operator- (PRCoords a, PRCoords b) {
    return PRCoords {
        a.lat - b.lat,
        a.lon - b.lon
    };
}

// for sorting
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

#if !defined(PRCOORDS_HEADER_ONLY) && defined(__cplusplus) // implementation
#include <cmath>
#include <functional>

/// Krasovsky 1940 ellipsoid
/// @const
const PRCOORDS_NUM GCJ_A = 6378245;
const PRCOORDS_NUM GCJ_EE = 0.00669342162296594323;  // f = 1/298.3; e^2 = 2*f - f**2
const PRCOORDS_NUM BD_DLAT = 0.0060;
const PRCOORDS_NUM BD_DLON = 0.0065;

/// Epsilon to use for "exact" iterations.
/// Wanna troll? Use Number.EPSILON. 1e-13 in 15 calls for gcj.
/// @const
const PRCOORDS_NUM PRCOORDS_EPS = 1e-5;

bool prcoords_in_china(PRCoords a) {
    return a >= PRCoords{0.8293, 72.004} && a <= PRCoords{55.8271, 137.8347};
}

inline static PRCOORDS_NUM prcoords_diffsum(PRCoords a, PRCoords b);
inline static PRCOORDS_NUM prcoords_diffsum(PRCoords a, PRCoords b) {
    PRCoords d = a - b;
    return fabs(d.lat) + fabs(d.lon);
}


typedef PRCoords (*ptr_prcoords_conv)(PRCoords);
// These conversions are for bored people: too accurate to be useful
// given pseudo-random noises added to GCJ.
template<ptr_prcoords_conv fwd, ptr_prcoords_conv rev>
PRCoords bored_reverse_conversion(PRCoords bad) {
    PRCoords wgs = rev(bad);
    PRCoords old = bad;
    
    int i = 0;
    do {
        old = wgs;
        wgs -= (fwd(wgs) - bad);
    } while (prcoords_diffsum(old, wgs) > PRCOORDS_EPS && i++ < 10)
    return wgs;
}

PRCoords prcoords_wgs_gcj(PRCoords wgs) {
	PRCOORDS_NUM x = wgs.lon - 105, y = wgs.lat - 35;
	
	// These distortion functions accept (x = lon - 105, y = lat - 35).
	// They return distortions in terms of arc lengths, in meters.
	//
	// In other words, you can pretty much figure out how much you will be off
	// from WGS-84 just through evaulating them...
	// 
	// For example, at the (mapped) center of China (105E, 35N), you get a
	// default deviation of <300, -100> meters.
	PRCOORDS_NUM dLat_m = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y +
		0.2 * sqrt(abs(x)) + (
	        2 * sin(x * 6 * PI) + 2 * sin(x * 2 * PI) +
	        2 * sin(y * PI) + 4 * sin(y / 3 * PI) +
	        16 * sin(y / 12 * PI) + 32 * sin(y / 30 * PI)
        ) * 20 / 3;
	PRCOORDS_NUM dLon_m = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
		0.1 * sqrt(abs(x)) + (
        	2 * sin(x * 6 * PI) + 2 * sin(x * 2 * PI) +
	        2 * sin(x * PI) + 4 * sin(x / 3 * PI) +
	        15 * sin(x / 12 * PI) + 30 * sin(x / 30 * PI)
        ) * 20 / 3;
    
    
    PRCOORDS_NUM radLat = wgs.lat / 180 * PI;
    PRCOORDS_NUM magic = 1 - GCJ_EE * pow(sin(radLat), 2); // just a common expr
    
    // [[:en:Latitude#Length_of_a_degree_of_latitude]]
    PRCOORDS_NUM lat_deg_arclen = (PI / 180) * (GCJ_A * (1 - GCJ_EE)) * pow(magic, 1.5);
    // [[:en:Longitude#Length_of_a_degree_of_longitude]]
    PRCOORDS_NUM lon_deg_arclen = (PI / 180) * (GCJ_A * cos(radLat) / sqrt(magic));
    
    // The screwers pack their deviations into degrees and disappear.
    // Note how they are mixing WGS-84 and Krasovsky 1940 ellipsoids here...
    return PRCoords{
    	wgs.lat + (dLat_m / lat_deg_arclen),
    	wgs.lon + (dLon_m / lon_deg_arclen)
    };
}

PRCoords prcoords_wgs_gcj(PRCoords gcj) {
    return gcj - (prcoords_wgs_gcj(gcj) - gcj);
}

PRCoords prcoords_gcj_bd(PRCoords gcj) {
	PRCOORDS_NUM x = gcj.lon;
	PRCOORDS_NUM y = gcj.lat;
	
	// trivia: pycoordtrans actually describes how these values are calculated
	PRCOORDS_NUM r = sqrt(x * x + y * y) + 0.00002 * sin(y * PI * 3000 / 180);
	PRCOORDS_NUM θ = atan2(y, x) + 0.000003 * cos(x * PI * 3000 / 180);
	
	// Hard-coded default deviations again!
	return PRCoords{
		lat: r * sin(θ) + BD_DLAT,
		lon: r * cos(θ) + BD_DLON
	};
}

PRCoords prcoords_bd_gcj(PRCoords bd) {
	PRCOORDS_NUM x = bd.lon - BD_DLON;
	PRCOORDS_NUM y = bd.lat - BD_DLAT;
	
	PRCOORDS_NUM r = sqrt(x * x + y * y) - 0.00002 * sin(y * PI * 3000 / 180);
	PRCOORDS_NUM θ = atan2(y, x) - 0.000003 * cos(x * PI * 3000 / 180);
	
	return PRCoords{
		lat: r * sin(θ),
		lon: r * cos(θ)
	};
}

PRCoords prcoords_wgs_bd(PRCoords wgs) {
    return prcoords_gcj_bd(prcoords_wgs_gcj(wgs));
}

PRCoords prcoords_bd_wgs(PRCoords bd) {
    return prcoords_gcj_wgs(prcoords_bd_gcj(bd));
}

PRCoords prcoords_gcj_wgs_bored(PRCoords gcj) {
    return bored_reverse_conversion<prcoords_wgs_gcj, prcoords_gcj_wgs>(gcj);
}
PRCoords prcoords_bd_gcj_bored(PRCoords bd) {
    return bored_reverse_conversion<prcoords_gcj_bd, prcoords_bd_gcj>)(bd);
}
PRCoords prcoords_bd_wgs_bored(PRCoords bd) {
    return bored_reverse_conversion<prcoords_wgs_bd, prcoords_bd_wgs>)(bd);
}

#if PRCOORDS_TEST
#include <iostream>
#include <type_traits>
int main(void) {
    std::cout << std::is_pod<PRCoords>::value << std::endl;
}
#endif
#endif
