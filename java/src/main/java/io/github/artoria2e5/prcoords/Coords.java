package io.github.artoria2e5.prcoords;

import java.util.Objects;

/** Latitude and longitude in degrees. */
public final class Coords implements Comparable<Coords> {
    private final double lat;
    private final double lon;

    public Coords(double lat, double lon) {
        this.lat = lat;
        this.lon = lon;
    }

    public double lat() { return lat; }

    public double lon() { return lon; }

    public Coords add(Coords o) { return new Coords(lat + o.lat, lon + o.lon); }

    public Coords sub(Coords o) { return new Coords(lat - o.lat, lon - o.lon); }

    public double abs() { return Math.sqrt(lat * lat + lon * lon); }

    /** Haversine over short distances, fine for checking conversion errors. */
    public double distance(Coords o) {
        Coords d = sub(o);
        double hav = Math.pow(Math.sin(Math.toRadians(d.lat) / 2), 2)
            + Math.cos(Math.toRadians(lat)) * Math.cos(Math.toRadians(o.lat))
              * Math.pow(Math.sin(Math.toRadians(d.lon) / 2), 2);
        return 2 * PRCoords.EARTH_R * Math.asin(Math.sqrt(hav));
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof Coords))
            return false;
        Coords c = (Coords) o;
        return Double.compare(lat, c.lat) == 0 && Double.compare(lon, c.lon) == 0;
    }

    @Override
    public int hashCode() { return Objects.hash(lat, lon); }

    /** Orders by latitude, then longitude, matching the C++ port. */
    @Override
    public int compareTo(Coords o) {
        int c = Double.compare(lat, o.lat);
        return c != 0 ? c : Double.compare(lon, o.lon);
    }

    @Override
    public String toString() { return "Coords[lat=" + lat + ", lon=" + lon + "]"; }
}
