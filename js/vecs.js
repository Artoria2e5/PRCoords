#!/usr/bin/env node
/**
 * People's Rectified Coordinates, vector dumper (JS).
 *
 * Reads "lat lon" pairs from a file (or stdin), one per line, and writes the
 * same 8-column TSV layout as TestVecs/vec.tsv to stdout: the input pair
 * followed by the wgs_gcj, gcj_bd and wgs_bd results.
 *
 * Feed the result to py/checkvecs.py:
 *
 *   node vecs.js | python ../py/checkvecs.py -
 *   python ../py/checkvecs.py --run "node js/vecs.js" --profile exact
 */
'use strict'
const fs = require('fs')
const PRCoords = require('./PRCoords.js')

const text = process.argv[2] ?
	fs.readFileSync(process.argv[2], 'utf8') : fs.readFileSync(0, 'utf8')

const out = []
for (const line of text.split('\n')) {
	const fields = line.trim().split(/[\t ]+/)
	if (fields.length < 2) continue
	const lat = Number(fields[0])
	const lon = Number(fields[1])
	if (isNaN(lat) || isNaN(lon)) continue
	const p = {lat, lon}
	const wg = PRCoords.wgs_gcj(p)
	const gb = PRCoords.gcj_bd(p)
	const wb = PRCoords.wgs_bd(p)
	// Number -> string is the shortest exact round-trip representation.
	out.push([lat, lon, wg.lat, wg.lon, gb.lat, gb.lon, wb.lat, wb.lon].join('\t'))
}
process.stdout.write(out.join('\n') + (out.length ? '\n' : ''))
