/**
 * Internal header for implementing "fast" sin(x*pi).
 */
#include <cmath>

namespace badmath {
    // what are you gonna do about it? x can't be too big!
    template<typename T>
    inline T red4(T x) {
        return -4 * std::nearbyint(x * 0.25) + x;
    }
    // devmaster user "Nick"'s approximation formula
    // https://web.archive.org/web/20171228230531/http://forum.devmaster.net/t/fast-and-accurate-sine-cosine/9648
    template<typename T>
    inline T sinpi_nick(T x) {
        x = red4(x * 2); // = 0 to 2pi; nick-magic works on units of 0.5pi
        T y = x * (2 - std::abs(x));
        return y * (0.775 + 0.225 * std::abs(y));
    }
    template<typename T>
    inline T sinpi_std(T x) {
        return std::sin(x * M_PI);
    }
    template<typename T>
    inline T sinpi(T x) {
#ifndef PRCOORDS_NO_BADMATH
        return sinpi_nick(x);
#else
        return sinpi_std(x);
#endif
    }
    template<typename T>
    inline T cospi(T x) {
        return sinpi(x + 0.5);
    }
}
