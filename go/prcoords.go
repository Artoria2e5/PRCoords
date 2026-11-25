// Package prcoords implements the GCJ-02 and BD-09 coordinate obfuscations
// used on Chinese maps, plus the Caijun fixed-point refinement for the
// inverses. Dedicated to the Public Domain under CC0.
package prcoords

import "math"

// pi is a variable so that pi/180 divides two float64 values at run time,
// matching the reference implementation bit for bit.
var pi = math.Pi

// Coords is a latitude/longitude pair in degrees.
type Coords struct {
	Lat, Lon float64
}

// Add returns p+q.
func (p Coords) Add(q Coords) Coords { return Coords{p.Lat + q.Lat, p.Lon + q.Lon} }

// Sub returns p-q.
func (p Coords) Sub(q Coords) Coords { return Coords{p.Lat - q.Lat, p.Lon - q.Lon} }

// Abs returns the Euclidean norm of the pair, for deviation checks. The
// coordinates are degree-sized, so a plain sqrt is safe and cheaper than
// math.Hypot's overflow-scaled path.
func (p Coords) Abs() float64 { return math.Sqrt(p.Lat*p.Lat + p.Lon*p.Lon) }

const (
	gcjA   = 6378245.0              // Krasovsky 1940 ellipsoid
	gcjEE  = 0.00669342162296594323 // f = 1/298.3; e^2 = 2f - f^2
	bdDLat = 0.0060                 // Baidu's artificial deviations
	bdDLon = 0.0065
	prcEps = 1e-5 // stop refining below this many degrees
	earthR = 6371000.0
)

func degToRad(d float64) float64 { return d * (pi / 180) }

// sinPi and cosPi are the sine and cosine of pi times the argument, named
// after the C23 functions. The GCJ polynomials are phrased in them because
// their arguments are exact integer or rational multiples of pi.
func sinPi(x float64) float64 { return math.Sin(pi * x) }
func cosPi(x float64) float64 { return math.Cos(pi * x) }

// InChina reports whether p is in the region where GCJ-02 is defined.
func InChina(p Coords) bool {
	return 0.8293 <= p.Lat && p.Lat <= 55.8271 &&
		72.004 <= p.Lon && p.Lon <= 137.8347
}

// WgsGcj converts WGS-84 to GCJ-02, leaving points outside China alone.
func WgsGcj(p Coords) Coords {
	if !InChina(p) {
		return p
	}
	return WgsGcjNC(p)
}

// WgsGcjNC is WgsGcj without the China check.
func WgsGcjNC(p Coords) Coords {
	x := p.Lon - 105
	y := p.Lat - 35

	dLat := -100 + 2*x + 3*y + 0.2*y*y + 0.1*x*y +
		0.2*math.Sqrt(math.Abs(x)) +
		(2*sinPi(x*6)+2*sinPi(x*2)+
			2*sinPi(y)+4*sinPi(y/3)+
			16*sinPi(y/12)+32*sinPi(y/30))*20/3
	dLon := 300 + x + 2*y + 0.1*x*x + 0.1*x*y +
		0.1*math.Sqrt(math.Abs(x)) +
		(2*sinPi(x*6)+2*sinPi(x*2)+
			2*sinPi(x)+4*sinPi(x/3)+
			15*sinPi(x/12)+30*sinPi(x/30))*20/3

	radLat := degToRad(p.Lat)
	magic := 1 - gcjEE*math.Pow(math.Sin(radLat), 2)

	latArclen := degToRad((gcjA * (1 - gcjEE)) / math.Pow(magic, 1.5))
	lonArclen := degToRad(gcjA * math.Cos(radLat) / math.Sqrt(magic))

	return Coords{p.Lat + dLat/latArclen, p.Lon + dLon/lonArclen}
}

// GcjWgs converts GCJ-02 to WGS-84 in one step, leaving points outside China
// alone.
func GcjWgs(g Coords) Coords {
	if !InChina(g) {
		return g
	}
	return GcjWgsNC(g)
}

// GcjWgsNC is GcjWgs without the China check.
func GcjWgsNC(g Coords) Coords { return g.Sub(WgsGcjNC(g).Sub(g)) }

// GcjBd converts GCJ-02 to BD-09.
func GcjBd(g Coords) Coords {
	x, y := g.Lon, g.Lat
	r := math.Sqrt(x*x+y*y) + 0.00002*sinPi(y*3000/180)
	theta := math.Atan2(y, x) + 0.000003*cosPi(x*3000/180)
	return Coords{r*math.Sin(theta) + bdDLat, r*math.Cos(theta) + bdDLon}
}

// BdGcj converts BD-09 to GCJ-02 in one step.
func BdGcj(b Coords) Coords {
	x := b.Lon - bdDLon
	y := b.Lat - bdDLat
	r := math.Sqrt(x*x+y*y) - 0.00002*sinPi(y*3000/180)
	theta := math.Atan2(y, x) - 0.000003*cosPi(x*3000/180)
	return Coords{r * math.Sin(theta), r * math.Cos(theta)}
}

// WgsBd converts WGS-84 to BD-09, leaving points outside China alone.
func WgsBd(p Coords) Coords {
	if !InChina(p) {
		return p
	}
	return WgsBdNC(p)
}

// WgsBdNC is WgsBd without the China check.
func WgsBdNC(p Coords) Coords { return GcjBd(WgsGcjNC(p)) }

// BdWgs converts BD-09 to WGS-84, leaving points outside China alone.
func BdWgs(b Coords) Coords {
	if !InChina(b) {
		return b
	}
	return BdWgsNC(b)
}

// BdWgsNC is BdWgs without the China check.
func BdWgsNC(b Coords) Coords { return GcjWgsNC(BdGcj(b)) }

// bored applies the Caijun 2014 refinement: nudge the rough inverse until the
// forward image lands back on the input, ten rounds or 1e-5 degrees.
func bored(fwd, rev func(Coords) Coords) func(Coords) Coords {
	return func(bad Coords) Coords {
		wgs := rev(bad)
		diff := Coords{99, 99}
		for i := 0; i < 10 && diff.Abs() > prcEps; i++ {
			diff = fwd(wgs).Sub(bad)
			wgs = wgs.Sub(diff)
		}
		return wgs
	}
}

var (
	gcjWgsBored = bored(WgsGcjNC, GcjWgs)
	bdGcjBored  = bored(GcjBd, BdGcj)
	bdWgsBored  = bored(WgsBdNC, BdWgs)
)

// GcjWgsBored is GcjWgs with iterative refinement for better accuracy.
func GcjWgsBored(g Coords) Coords { return gcjWgsBored(g) }

// BdGcjBored is BdGcj with iterative refinement for better accuracy.
func BdGcjBored(b Coords) Coords { return bdGcjBored(b) }

// BdWgsBored is BdWgs with iterative refinement for better accuracy.
func BdWgsBored(b Coords) Coords { return bdWgsBored(b) }

// Distance returns the haversine distance in meters, suitable for short
// distances like deviation checks.
func Distance(p, q Coords) float64 {
	hav := func(theta float64) float64 { s := math.Sin(theta / 2); return s * s }
	d := p.Sub(q)
	return 2 * earthR * math.Asin(math.Sqrt(
		hav(degToRad(d.Lat))+
			math.Cos(degToRad(p.Lat))*math.Cos(degToRad(q.Lat))*hav(degToRad(d.Lon))))
}
