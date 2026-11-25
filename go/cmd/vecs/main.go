// Command vecs dumps the eight-column test vector layout for
// py/checkvecs.py: input lat, input lon, then wgs_gcj, gcj_bd and wgs_bd of
// the input pair.
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/Artoria2e5/PRCoords/go"
)

func main() {
	in := os.Stdin
	if len(os.Args) > 1 {
		f, err := os.Open(os.Args[1])
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		defer f.Close()
		in = f
	}

	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()

	sc := bufio.NewScanner(in)
	for sc.Scan() {
		fields := strings.Fields(sc.Text())
		if len(fields) < 2 {
			continue
		}
		lat, err1 := strconv.ParseFloat(fields[0], 64)
		lon, err2 := strconv.ParseFloat(fields[1], 64)
		if err1 != nil || err2 != nil {
			continue
		}
		p := prcoords.Coords{Lat: lat, Lon: lon}
		w := prcoords.WgsGcj(p)
		g := prcoords.GcjBd(p)
		b := prcoords.WgsBd(p)
		fmt.Fprintf(out, "%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\n",
			lat, lon, w.Lat, w.Lon, g.Lat, g.Lon, b.Lat, b.Lon)
	}
	if err := sc.Err(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
