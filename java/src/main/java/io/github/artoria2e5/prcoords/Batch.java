package io.github.artoria2e5.prcoords;

/**
 * Batch transforms over parallel latitude and longitude arrays. Each call
 * rewrites the first n entries in place.
 *
 * The JNI bridge is optional. When prcoords_jni cannot be loaded, the same
 * methods run the Java implementation one point at a time: slower, and a few
 * last bits different when the C++ build uses its own sinpi, but otherwise
 * the same answer. Both paths skip the China check, like the C++ core.
 */
public final class Batch {
    private Batch() {}

    private static volatile boolean nativeOk = load();

    private static boolean load() {
        try {
            System.loadLibrary("prcoords_jni");
            return true;
        } catch (UnsatisfiedLinkError e) {
            return false;
        }
    }

    /** True when the JNI bridge is loaded and usable. */
    public static boolean nativeAvailable() { return nativeOk; }

    public static void wgsGcj(double[] lat, double[] lon, int n) {
        if (nativeOk) {
            try { Natives.wgsGcj(lat, lon, n); return; }
            catch (UnsatisfiedLinkError e) { nativeOk = false; }
        }
        each(lat, lon, n, p -> PRCoords.wgsGcj(p, false));
    }

    public static void gcjBd(double[] lat, double[] lon, int n) {
        if (nativeOk) {
            try { Natives.gcjBd(lat, lon, n); return; }
            catch (UnsatisfiedLinkError e) { nativeOk = false; }
        }
        each(lat, lon, n, p -> PRCoords.gcjBd(p));
    }

    public static void wgsBd(double[] lat, double[] lon, int n) {
        if (nativeOk) {
            try { Natives.wgsBd(lat, lon, n); return; }
            catch (UnsatisfiedLinkError e) { nativeOk = false; }
        }
        each(lat, lon, n, p -> PRCoords.wgsBd(p, false));
    }

    public static void gcjWgsBored(double[] lat, double[] lon, int n) {
        if (nativeOk) {
            try { Natives.gcjWgsBored(lat, lon, n); return; }
            catch (UnsatisfiedLinkError e) { nativeOk = false; }
        }
        each(lat, lon, n, PRCoords::gcjWgsBored);
    }

    public static void bdGcjBored(double[] lat, double[] lon, int n) {
        if (nativeOk) {
            try { Natives.bdGcjBored(lat, lon, n); return; }
            catch (UnsatisfiedLinkError e) { nativeOk = false; }
        }
        each(lat, lon, n, PRCoords::bdGcjBored);
    }

    public static void bdWgsBored(double[] lat, double[] lon, int n) {
        if (nativeOk) {
            try { Natives.bdWgsBored(lat, lon, n); return; }
            catch (UnsatisfiedLinkError e) { nativeOk = false; }
        }
        each(lat, lon, n, PRCoords::bdWgsBored);
    }

    private interface Op { Coords apply(Coords p); }

    private static void each(double[] lat, double[] lon, int n, Op op) {
        int len = Math.max(0, Math.min(n, Math.min(lat.length, lon.length)));
        for (int i = 0; i < len; i++) {
            Coords r = op.apply(new Coords(lat[i], lon[i]));
            lat[i] = r.lat();
            lon[i] = r.lon();
        }
    }
}
