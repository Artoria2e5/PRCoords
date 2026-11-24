package io.github.artoria2e5.prcoords;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * Dumps the eight-column test vector layout: input lat, input lon, then the
 * results of wgs_gcj, gcj_bd and wgs_bd as applied to the input pair.
 *
 *   java -cp build/classes io.github.artoria2e5.prcoords.Vecs [--native] [file]
 *
 * --native runs the same transform through the JNI bridge instead of this
 * package's own arithmetic.
 */
public final class Vecs {
    private Vecs() {}

    public static void main(String[] args) throws IOException {
        boolean useNative = false;
        String file = null;
        for (String a : args) {
            if (a.equals("--native"))
                useNative = true;
            else
                file = a;
        }

        BufferedReader in = file == null
            ? new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8))
            : Files.newBufferedReader(Paths.get(file), StandardCharsets.UTF_8);

        double[] lat = new double[64];
        double[] lon = new double[64];
        int n = 0;

        for (String line = in.readLine(); line != null; line = in.readLine()) {
            String[] f = line.trim().split("[\\t ]+");
            if (f.length < 2)
                continue;
            double la, lo;
            try {
                la = Double.parseDouble(f[0]);
                lo = Double.parseDouble(f[1]);
            } catch (NumberFormatException e) {
                continue;
            }
            if (n == lat.length) {
                lat = java.util.Arrays.copyOf(lat, n * 2);
                lon = java.util.Arrays.copyOf(lon, n * 2);
            }
            lat[n] = la;
            lon[n] = lo;
            n++;
        }

        if (useNative && !Batch.nativeAvailable())
            System.err.println("note: no prcoords_jni, using the Java fallback");

        double[][] out = useNative
            ? nativeTransforms(lat, lon, n)
            : javaTransforms(lat, lon, n);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < n; i++) {
            sb.append(lat[i]).append('\t').append(lon[i]);
            for (double[] t : out)
                sb.append('\t').append(t[i]);
            sb.append('\n');
        }
        System.out.print(sb);
    }

    /** Pure Java: three transforms per point. */
    private static double[][] javaTransforms(double[] lat, double[] lon, int n) {
        double[][] out = {new double[n], new double[n], new double[n], new double[n],
                          new double[n], new double[n]};
        for (int i = 0; i < n; i++) {
            Coords p = new Coords(lat[i], lon[i]);
            Coords wg = PRCoords.wgsGcj(p);
            Coords gb = PRCoords.gcjBd(p);
            Coords wb = PRCoords.wgsBd(p);
            out[0][i] = wg.lat(); out[1][i] = wg.lon();
            out[2][i] = gb.lat(); out[3][i] = gb.lon();
            out[4][i] = wb.lat(); out[5][i] = wb.lon();
        }
        return out;
    }

    /** JNI bridge: three batched calls. */
    private static double[][] nativeTransforms(double[] lat, double[] lon, int n) {
        double[][] out = new double[6][];
        double[][][] buf = new double[3][2][];
        for (int i = 0; i < 3; i++) {
            buf[i][0] = lat.clone();
            buf[i][1] = lon.clone();
        }
        Batch.wgsGcj(buf[0][0], buf[0][1], n);
        Batch.gcjBd(buf[1][0], buf[1][1], n);
        Batch.wgsBd(buf[2][0], buf[2][1], n);
        for (int i = 0; i < 3; i++) {
            out[2 * i] = buf[i][0];
            out[2 * i + 1] = buf[i][1];
        }
        return out;
    }
}
