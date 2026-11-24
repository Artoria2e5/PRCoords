package io.github.artoria2e5.prcoords;

/**
 * JNI entry points into the C++ core. Batch loads the library and calls these
 * only when it worked, so nothing here is ever invoked without it.
 */
final class Natives {
    private Natives() {}

    static native void wgsGcj(double[] lat, double[] lon, int n);

    static native void gcjBd(double[] lat, double[] lon, int n);

    static native void wgsBd(double[] lat, double[] lon, int n);

    static native void gcjWgsBored(double[] lat, double[] lon, int n);

    static native void bdGcjBored(double[] lat, double[] lon, int n);

    static native void bdWgsBored(double[] lat, double[] lon, int n);
}
