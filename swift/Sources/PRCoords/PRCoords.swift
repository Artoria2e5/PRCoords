import Foundation

/// Latitude and longitude in degrees.
public struct Coords: Hashable, Comparable, AdditiveArithmetic, Sendable, CustomStringConvertible {
    public var lat: Double
    public var lon: Double

    public init(_ lat: Double, _ lon: Double) {
        self.lat = lat
        self.lon = lon
    }

    public static let zero = Coords(0, 0)

    public var description: String {
        return "Coords(\(lat), \(lon))"
    }

    /// Lexicographic order by latitude, then longitude, matching the C++ port.
    public static func < (a: Coords, b: Coords) -> Bool {
        return a.lat < b.lat || (a.lat == b.lat && a.lon < b.lon)
    }

    public static func + (a: Coords, b: Coords) -> Coords {
        return Coords(a.lat + b.lat, a.lon + b.lon)
    }

    public static func - (a: Coords, b: Coords) -> Coords {
        return Coords(a.lat - b.lat, a.lon - b.lon)
    }

    /// Euclidean norm, for deviation checks.
    public var magnitude: Double {
        return (lat * lat + lon * lon).squareRoot()
    }

    /// Haversine distance, fine over short distances.
    public func distance(to other: Coords) -> Double {
        func hav(_ theta: Double) -> Double {
            let s = sin(theta / 2)
            return s * s
        }

        let d = self - other
        let h = hav(d.lat * Double.pi / 180)
            + cos(lat * Double.pi / 180) * cos(other.lat * Double.pi / 180)
            * hav(d.lon * Double.pi / 180)
        return 2 * PRCoords.earthR * asin(h.squareRoot())
    }
}

/// Namespace for the transform functions and shared constants.
public enum PRCoords {
    public static let earthR = 6371000.0

    // Krasovsky 1940, the ellipsoid GCJ-02 pretends to use.
    static let gcjA = 6378245.0
    static let gcjEE = 0.00669342162296594323 // f = 1/298.3; e^2 = 2*f - f^2

    // Baidu's artificial deviations.
    static let bdDLat = 0.0060
    static let bdDLon = 0.0065

    // Caijun refinement stops when the residual is this small, in degrees.
    static let prcEps = 1e-5
}

/// sin(pi * x) as a fourth-order Remez refit of Nick's parabola, the same
/// approximation as cpp/badmath.hh's sinpi_d4. Calling sin() with a
/// multiplied argument would be more precise than the transforms need.
@inline(__always)
internal func sinPi(_ x: Double) -> Double {
    let t2 = x * 2
    let t = t2 - 4 * (t2 * 0.25).rounded(.toNearestOrEven)
    let y = t * (2 - abs(t))
    let a = abs(y)
    return y * (0.785396508482 + a * (0.196365553104
        + a * (0.0173811840777 + a * 0.000856701715691)))
}

@inline(__always)
internal func cosPi(_ x: Double) -> Double {
    return sinPi(x + 0.5)
}

public func inChina(_ p: Coords) -> Bool {
    return 0.8293 <= p.lat && p.lat <= 55.8271
        && 72.004 <= p.lon && p.lon <= 137.8347
}

/// GCJ-02's distortion at a WGS-84 point, in metres of arc. The polynomials
/// are specified in x = lon - 105 and y = lat - 35.
public func deviationMeters(_ p: Coords) -> (lat: Double, lon: Double) {
    let x = p.lon - 105
    let y = p.lat - 35

    let dLatM = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y
        + 0.2 * abs(x).squareRoot()
        + (2 * sinPi(6 * x) + 2 * sinPi(2 * x) + 2 * sinPi(y)
            + 4 * sinPi(y / 3) + 16 * sinPi(y / 12) + 32 * sinPi(y / 30))
        * 20 / 3

    let dLonM = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y
        + 0.1 * abs(x).squareRoot()
        + (2 * sinPi(6 * x) + 2 * sinPi(2 * x) + 2 * sinPi(x)
            + 4 * sinPi(x / 3) + 15 * sinPi(x / 12) + 30 * sinPi(x / 30))
        * 20 / 3

    return (dLatM, dLonM)
}

public func wgsGcj(_ wgs: Coords, checkChina: Bool = true) -> Coords {
    if checkChina && !inChina(wgs) {
        return wgs
    }

    let (dLatM, dLonM) = deviationMeters(wgs)
    let radLat = wgs.lat * Double.pi / 180
    let magic = 1 - PRCoords.gcjEE * pow(sin(radLat), 2)

    // Length of a degree of latitude and longitude, in metres.
    let latArc = (PRCoords.gcjA * (1 - PRCoords.gcjEE)) / pow(magic, 1.5)
        * Double.pi / 180
    let lonArc = PRCoords.gcjA * cos(radLat) / magic.squareRoot()
        * Double.pi / 180

    return Coords(wgs.lat + dLatM / latArc, wgs.lon + dLonM / lonArc)
}

public func gcjWgs(_ gcj: Coords, checkChina: Bool = true) -> Coords {
    let wgs = wgsGcj(gcj, checkChina: checkChina)
    return Coords(2 * gcj.lat - wgs.lat, 2 * gcj.lon - wgs.lon)
}

public func gcjBd(_ gcj: Coords) -> Coords {
    let y = gcj.lat
    let x = gcj.lon

    let r = (x * x + y * y).squareRoot() + 0.00002 * sinPi(y * 3000 / 180)
    let theta = atan2(y, x) + 0.000003 * cosPi(x * 3000 / 180)

    return Coords(r * sin(theta) + PRCoords.bdDLat,
                  r * cos(theta) + PRCoords.bdDLon)
}

public func bdGcj(_ bd: Coords) -> Coords {
    let x = bd.lon - PRCoords.bdDLon
    let y = bd.lat - PRCoords.bdDLat

    let r = (x * x + y * y).squareRoot() - 0.00002 * sinPi(y * 3000 / 180)
    let theta = atan2(y, x) - 0.000003 * cosPi(x * 3000 / 180)

    return Coords(r * sin(theta), r * cos(theta))
}

public func bdWgs(_ bd: Coords, checkChina: Bool = true) -> Coords {
    return gcjWgs(bdGcj(bd), checkChina: checkChina)
}

public func wgsBd(_ wgs: Coords, checkChina: Bool = true) -> Coords {
    return gcjBd(wgsGcj(wgs, checkChina: checkChina))
}

internal func refined(_ bad: Coords,
                      forward: (Coords) -> Coords,
                      reverse: (Coords) -> Coords) -> Coords {
    var wgs = reverse(bad)
    var diff = Coords(99, 99)
    var i = 0

    while i < 10 && diff.magnitude > PRCoords.prcEps {
        diff = forward(wgs) - bad
        wgs = wgs - diff
        i += 1
    }

    return wgs
}

public func gcjWgsBored(_ gcj: Coords) -> Coords {
    return refined(gcj, forward: { wgsGcj($0, checkChina: false) },
                   reverse: { gcjWgs($0) })
}

public func bdGcjBored(_ bd: Coords) -> Coords {
    return refined(bd, forward: { gcjBd($0) }, reverse: { bdGcj($0) })
}

public func bdWgsBored(_ bd: Coords) -> Coords {
    return refined(bd, forward: { wgsBd($0, checkChina: false) },
                   reverse: { bdWgs($0) })
}
