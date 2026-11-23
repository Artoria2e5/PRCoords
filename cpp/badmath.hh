/**
 * Internal header for implementing "fast" sin(x*pi).
 * Include prcoords.h first: sinpi_std wants its M_PI.
 */
#include <cmath>

namespace badmath {
    // what are you gonna do about it? x can't be too big!
    // this is supposed to turn into FMA where fast, and not invoke the fma() libc function otherwise.
    // like how Julia's muladd() works, but at the mercy of the compiler.
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

    // Refits of Nick's parabola: with y = t * (2 - abs(t)) for t in [-2, 2],
    //
    //     sin(pi t / 2) ~= y * (c0 + abs(y) * (c1 + abs(y) * (c2 + ...)))
    //
    // Remez fits on [0, 1] in abs(y). Coefficients and maximum absolute error:
    //
    //     sinpi_nick   0.775, 0.225                                     1.09e-3
    //     sinpi_d2     0.777320432199, 0.221947173039                   7.32e-4
    //     sinpi_d3     0.785554283512, 0.195409751101, 0.0190281477634  7.82e-6
    //     sinpi_d4     0.785396508482, 0.196365553104, 0.0173811840777,
    //                  0.000856701715691                               5.26e-8
    //
    // A two-term refit buys 1.5x and nothing more; other two-parameter forms
    // need a pow() to do better, which costs more than a third term. The third
    // term is worth 140x for one multiply and one add, the fourth another
    // 150x. d4 is the default.
    // Of some historical interest, see Apollo's take at:
    // http://jeanmariechauvet.com/papers/curttrig.html
    // -- Skadeep
    template<typename T>
    inline T sinpi_d2(T x) {
        x = red4(x * 2); // = 0 to 2pi; nick-magic works on units of 0.5pi
        T y = x * (2 - std::abs(x));
        return y * (T(0.777320432199) + T(0.221947173039) * std::abs(y));
    }

    template<typename T>
    inline T sinpi_d3(T x) {
        x = red4(x * 2);
        T y = x * (2 - std::abs(x));
        T a = std::abs(y);
        return y * (T(0.785554283512) + a * (T(0.195409751101)
                    + a * T(0.0190281477634)));
    }

    template<typename T>
    inline T sinpi_d4(T x) {
        x = red4(x * 2);
        T y = x * (2 - std::abs(x));
        T a = std::abs(y);
        return y * (T(0.785396508482) + a * (T(0.196365553104)
                    + a * (T(0.0173811840777) + a * T(0.000856701715691))));
    }

    template<typename T>
    inline T sinpi_std(T x) {
        // TODO: when C++ eventually gets C23 sinpi(), add an ifdef here
        return std::sin(x * M_PI);
    }
    // Choose the variant with -DPRCOORDS_SINPI=d3 (or nick, d2, std).
    // -DPRCOORDS_NO_BADMATH still forces std.
#ifndef PRCOORDS_SINPI
#ifdef PRCOORDS_NO_BADMATH
#define PRCOORDS_SINPI std
#else
#define PRCOORDS_SINPI d4
#endif
#endif
#define BADMATH_CAT_(a, b) a##b
#define BADMATH_CAT(a, b) BADMATH_CAT_(a, b)

    template<typename T>
    inline T sinpi(T x) {
        return BADMATH_CAT(sinpi_, PRCOORDS_SINPI)(x);
    }
    template<typename T>
    inline T cospi(T x) {
        return sinpi(x + 0.5);
    }
}
