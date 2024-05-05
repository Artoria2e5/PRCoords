// mirror of https://runkit.com/artoria2e5/proj4-plugin-prcoords
const proj4 = require("proj4")
const prcoords = require("prcoords")
const noop = Function.prototype
const DEG = Math.PI / 180

function xy_to_ll(p) {
  return { lon: p.x / DEG, lat: p.y / DEG }
}
function ll_to_xy(p) {
  return { x: p.lon * DEG, y: p.lat * DEG }
}
function xy_rename_ll(p) {
  return { lon: p.x, lat: p.y }
}
function ll_rename_xy(p) {
  return { x: p.lon, y: p.lat }
}

function wrap(f, ...args) {
  return (p) => ll_to_xy(f(xy_to_ll(p), ...args))
}

// We lie our way to Baidu "Mercator".
proj4.defs([
  [
    "_CLARK_MC",
    "+proj=merc +a=6378206.4 +b=6356583.8 +lat_ts=0.0 +lon_0=0.0 +x_0=0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs",
  ],
  ["_CLARK_LL", "+proj=longlat +a=6378206.4 +b=6356583.8"],
])

proj4.Proj.projections.add({
  init: noop,
  forward: wrap(prcoords.wgs_gcj),
  inverse: wrap(prcoords.gcj_wgs_bored),
  names: ["gcj", "gcj02", "CN_Obfs_GCJ_2002_Ellipsoidal"],
})

proj4.Proj.projections.add({
  init: noop,
  forward: wrap(prcoords.wgs_bd),
  inverse: wrap(prcoords.bd_wgs_bored),
  names: ["baidu", "bd09", "CN_Obfs_Baidu_2009_Ellipsoidal"],
})

proj4.Proj.projections.add({
  init: noop,
  forward: (p) =>
    proj4("_CLARK_LL", "_CLARK_MC", ll_rename_xy(prcoords.wgs_bd(xy_to_ll(p)))),
  inverse: (p) =>
    ll_to_xy(
      prcoords.bd_wgs_bored(xy_rename_ll(proj4("_CLARK_MC", "_CLARK_LL", p))),
    ),
  names: ["baidu", "bd09mc", "CN_Obfs_Baidu_2009_Mercator"],
})

proj4.defs([
  // Why isn't units=degrees working... work around with wrap() now.
  ["GCJ02", "+title=GCJ 02 (long/lat) +proj=gcj02 +units=degrees"],
  ["BD09", "+title=Baidu 2009 (long/lat) +proj=bd09 +units=degrees"],
  ["BD09MC", "+title=Baidu 2009 (Mercator) +proj=bd09mc +units=m"],
])

console.log([
  // should be the same as https://artoria2e5.github.io/PRCoords/demo
  xy_to_ll(proj4("WGS84", "BD09", { x: 105, y: 35 })),
  xy_to_ll(proj4("WGS84", "GCJ02", { x: 105, y: 35 })),
])

console.log([
  // should be very close to the original
  proj4(
    "BD09",
    "WGS84",
    ll_to_xy({ lat: 35.005403668456964, lon: 105.00966682831948 }),
  ),
  proj4(
    "GCJ02",
    "WGS84",
    ll_to_xy({ lat: 34.99909863223526, lon: 105.00328624145706 }),
  ),
])

console.log([
  proj4("WGS84", "BD09MC", { x: 105, y: 35 }),
  proj4("BD09MC", "WGS84", { x: 11689750, y: 4139877 }),
])
