// Insane version of the "is in China" check (70 points. I tried.)
// Dedicated to the Public Domain under CC0
//
// Incorrect use of this polygon can lead to adverse geopolitical issues.
// This set of points is only intended to approximate the scope of a type of distortion,
// and has nothing to do with any political entities.
//
// Also, screw geodetics. The Earth is flat according to this approximation.

// We will need to filter out these points for Baidu.
// (We will need South China Sea too.)
var is_near_hkmo = function (lat, lon) {
  return 22 <= lat && lat <= 22.7 && 113.5 <= lon && lon <= 114.5
}
// Well we now have indices for HK/MO.
var HK_LENGTH = 12

// lon, lat
var POINTS = [
  // dup for a ring
  110.669856, 17.754550,
  // start hkmo
  114.433722, 22.064310,
  114.009458, 22.182105,
  113.599275, 22.121763,
  113.583463, 22.176002,
  113.530900, 22.175318,
  113.529542, 22.210608,
  113.613377, 22.227435,
  113.938514, 22.483714,
  114.043449, 22.500274,
  114.138506, 22.550640,
  114.222984, 22.550960,
  114.366803, 22.524255,
  // end hkmo
  115.254019, 20.235733,
  121.456316, 26.504442,
  123.417261, 30.355685,
  124.289197, 39.761103,
  126.880509, 41.774504,
  127.887261, 41.370015,
  128.214602, 41.965359,
  129.698745, 42.452788,
  130.766139, 42.668534,
  131.282487, 45.037051,
  133.142361, 44.842986,
  134.882453, 48.370596,
  132.235531, 47.785403,
  130.980075, 47.804860,
  130.659026, 48.968383,
  127.860252, 50.043973,
  125.284310, 53.667091,
  120.619316, 53.100485,
  119.403751, 50.105903,
  117.070862, 49.690388,
  115.586019, 47.995542,
  118.599613, 47.927785,
  118.260771, 46.707335,
  113.534759, 44.735134,
  112.093739, 45.001999,
  111.431259, 43.489381,
  105.206324, 41.809510,
  96.485703, 42.778692,
  94.167961, 44.991668,
  91.130430, 45.192938,
  90.694601, 47.754437,
  87.356293, 49.232005,
  85.375791, 48.263928,
  85.876055, 47.109272,
  82.935423, 47.285727,
  81.929808, 45.506317,
  79.919457, 45.108122,
  79.841455, 42.178752,
  73.334917, 40.076332,
  73.241805, 39.062331,
  79.031902, 34.206413,
  78.738395, 31.578004,
  80.715812, 30.453822,
  81.821692, 30.585965,
  85.501663, 28.208463,
  92.096061, 27.754241,
  94.699781, 29.357171,
  96.079442, 29.429559,
  98.910308, 27.140660,
  97.404057, 24.494701,
  99.400021, 23.168966,
  100.697449, 21.475914,
  102.976870, 22.616482,
  105.476997, 23.244292,
  108.565621, 20.907735,
  107.730505, 18.193406,
  110.669856, 17.754550,
]

var lats = POINTS.filter((ditch, i) => i % 2 == 1)
var lons = POINTS.filter((ditch, i) => i % 2 == 0)
POINTS = null // gotta ditch that

// Perform precalculation:
// http://alienryderflex.com/polygon/
for (let i = 0; i < lats.length; i++) {
  // blah blah
  k[i] =
  b[i] =
}

var bdlats = lats.filter((ditch, i) => i == 0 || i - 1 > HK_LENGTH)
var bdlons = lats.filter((ditch, i) => i == 0 || i - 1 > HK_LENGTH)

for (let i = 0; i < bdlats.length; i++) {
  // blah blah
  bd_k[i] =
  bd_b[i] =
}

// dont need that anyway
bdlats = bdlons = lats = lons = null

// I expect you to call this *after* doing the rough check.
// Perform check.
function isInGoogle(lat, lon) {
  // Yank out South China Sea
  if (lat <= 17.75455)
    return false;
  
}

function isInBaidu(lat, lon) {
  // Yank out South China Sea
  // Their Sansha data is crap too.
  if (lat <= 17.75455)
    return false;
  
}
