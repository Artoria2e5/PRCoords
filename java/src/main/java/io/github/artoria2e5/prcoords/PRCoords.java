package io.github.artoria2e5.prcoords;

import static java.lang.Math.PI;
import static java.lang.Math.abs;
import static java.lang.Math.atan2;
import static java.lang.Math.cos;
import static java.lang.Math.pow;
import static java.lang.Math.sin;
import static java.lang.Math.sqrt;
import static java.lang.Math.toRadians;

/**
 * Chinese coordinate obfuscation, translated from py/prcoords.py.
 *
 * GCJ-02 and BD-09 are only defined in China, so the forward transforms take a
 * checkChina flag; with it set, coordinates outside the rough China box come
 * back untouched. The inverse transforms are one-step: they subtract the
 * forward offset measured at the input, which leaves meter-level residue. The
 * bored variants refine that to a fixed point.
 *
 * -- Skadeep
 */
public final class PRCoords {
    private PRCoords() {}

    /** Krasovsky 1940 ellipsoid. */
    public static final double GCJ_A = 6378245;
    public static final double GCJ_EE = 0.00669342162296594323; // f = 1/298.3

    /** Stop iterating once the offset is below this many degrees. */
    public static final double PRC_EPS = 1e-5;

    /** Baidu's artificial deviations. */
    public static final double BD_DLAT = 0.0060;
    public static final double BD_DLON = 0.0065;

    /** Mean Earth radius, for {@link Coords#distance}. */
    public static final double EARTH_R = 6371000;

    public static boolean inChina(Coords c) {
        return 0.8293 <= c.lat() && c.lat() <= 55.8271
            && 72.004 <= c.lon() && c.lon() <= 137.8347;
    }

    /** WGS-84 to GCJ-02. */
    public static Coords wgsGcj(Coords wgs) { return wgsGcj(wgs, true); }

    public static Coords wgsGcj(Coords wgs, boolean checkChina) {
        if (checkChina && !inChina(wgs))
            return wgs;

        double x = wgs.lon() - 105;
        double y = wgs.lat() - 35;

        // Distortions in meters of arc length, as functions of (lon - 105,
        // lat - 35). At 105E 35N the default is about <-300, -100> meters.
        double dLat_m = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y
            + 0.2 * sqrt(abs(x))
            + (2 * sin(x * 6 * PI) + 2 * sin(x * 2 * PI)
               + 2 * sin(y * PI) + 4 * sin(y / 3 * PI)
               + 16 * sin(y / 12 * PI) + 32 * sin(y / 30 * PI)) * 20 / 3;
        double dLon_m = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y
            + 0.1 * sqrt(abs(x))
            + (2 * sin(x * 6 * PI) + 2 * sin(x * 2 * PI)
               + 2 * sin(x * PI) + 4 * sin(x / 3 * PI)
               + 15 * sin(x / 12 * PI) + 30 * sin(x / 30 * PI)) * 20 / 3;

        double radLat = toRadians(wgs.lat());
        double magic = 1 - GCJ_EE * pow(sin(radLat), 2);

        // Length of a degree of latitude and of longitude, in meters.
        double lat_deg_arclen = toRadians((GCJ_A * (1 - GCJ_EE)) / pow(magic, 1.5));
        double lon_deg_arclen = toRadians(GCJ_A * cos(radLat) / sqrt(magic));

        return new Coords(wgs.lat() + dLat_m / lat_deg_arclen,
                          wgs.lon() + dLon_m / lon_deg_arclen);
    }

    /** GCJ-02 to WGS-84. One step; see the bored variant for better. */
    public static Coords gcjWgs(Coords gcj) { return gcjWgs(gcj, true); }

    public static Coords gcjWgs(Coords gcj, boolean checkChina) {
        return gcj.sub(wgsGcj(gcj, checkChina).sub(gcj));
    }

    /** GCJ-02 to BD-09. */
    public static Coords gcjBd(Coords gcj) {
        double y = gcj.lat();
        double x = gcj.lon();

        double r = sqrt(x * x + y * y) + 0.00002 * sin(toRadians(y) * 3000);
        double theta = atan2(y, x) + 0.000003 * cos(toRadians(x) * 3000);

        return new Coords(r * sin(theta) + BD_DLAT,
                          r * cos(theta) + BD_DLON);
    }

    /** The china flag is unused here, kept so the refinement loop stays uniform. */
    public static Coords gcjBd(Coords gcj, boolean checkChina) { return gcjBd(gcj); }

    /** BD-09 to GCJ-02. */
    public static Coords bdGcj(Coords bd) {
        double x = bd.lon() - BD_DLON;
        double y = bd.lat() - BD_DLAT;

        double r = sqrt(x * x + y * y) - 0.00002 * sin(toRadians(y) * 3000);
        double theta = atan2(y, x) - 0.000003 * cos(toRadians(x) * 3000);

        return new Coords(r * sin(theta), r * cos(theta));
    }

    /** BD-09 to WGS-84. */
    public static Coords bdWgs(Coords bd) { return bdWgs(bd, true); }

    public static Coords bdWgs(Coords bd, boolean checkChina) {
        return gcjWgs(bdGcj(bd), checkChina);
    }

    /** WGS-84 to BD-09. */
    public static Coords wgsBd(Coords wgs) { return wgsBd(wgs, true); }

    public static Coords wgsBd(Coords wgs, boolean checkChina) {
        return gcjBd(wgsGcj(wgs, checkChina));
    }

    /** Caijun 2014 fixed-point refinement: ten rounds or 1e-5 deg. */
    private static Coords bored(Coords bad,
                                java.util.function.BiFunction<Coords, Boolean, Coords> fwd,
                                java.util.function.Function<Coords, Coords> rev) {
        Coords wgs = rev.apply(bad);
        Coords diff = new Coords(99, 99); // canary

        for (int i = 0; i < 10 && diff.abs() > PRC_EPS; i++) {
            diff = fwd.apply(wgs, false).sub(bad);
            wgs = wgs.sub(diff);
        }
        return wgs;
    }

    public static Coords gcjWgsBored(Coords gcj) {
        return bored(gcj, PRCoords::wgsGcj, PRCoords::gcjWgs);
    }

    public static Coords bdGcjBored(Coords bd) {
        return bored(bd, PRCoords::gcjBd, PRCoords::bdGcj);
    }

    public static Coords bdWgsBored(Coords bd) {
        return bored(bd, PRCoords::wgsBd, PRCoords::bdWgs);
    }
}
