{-# LANGUAGE BangPatterns #-}
{-# OPTIONS_GHC -optc-ffast-math -optllc--enable-unsafe-fp-math -optllc--enable-no-nans-fp-math -optllc--enable-no-infs-fp-math #-}

--- | People's Rectified Coordinates: GCJ-02 and BD-09 conversion, plus the
--- Caijun fixed-point refinement for the inverses.
--- Dedicated to the Public Domain under CC0.
module PRCoords
    ( PCoords(..)
    , inChina
    , wgsGcj, wgsGcjNC
    , gcjWgs, gcjWgsNC
    , gcjBd, bdGcj
    , wgsBd, wgsBdNC
    , bdWgs, bdWgsNC
    , gcjWgsBored, bdGcjBored, bdWgsBored
    ) where

data PCoords = PCoords { lat :: Double
                       , lon :: Double } deriving (Eq, Ord, Show)

subtractPCoords :: PCoords -> PCoords -> PCoords
subtractPCoords a b = PCoords (lat a - lat b) (lon a - lon b)

gcjA, gcjEe, bdDLat, bdDLon, prcEps :: Double
gcjA = 6378245.0                  -- Krasovsky 1940 ellipsoid
gcjEe = 0.00669342162296594323     -- f = 1/298.3; e^2 = 2*f - f^2
bdDLat = 0.0060                    -- Baidu's artificial deviations
bdDLon = 0.0065
prcEps = 1e-5                      -- stop refining below this many degrees

degToRad :: Double -> Double
degToRad d = d * (pi / 180)

--- | Sine and cosine of pi times the argument, named after the C23 functions.
sinpi :: Double -> Double
sinpi x = sin (pi * x)

cospi :: Double -> Double
cospi x = cos (pi * x)

--- | GCJ-02 and BD-09 are only defined in China.
inChina :: PCoords -> Bool
inChina (PCoords lat lon) =
    0.8293 <= lat && lat <= 55.8271
 && 72.004 <= lon && lon <= 137.8347

--- | WGS-84 to GCJ-02, outside China left alone.
wgsGcj :: PCoords -> PCoords
wgsGcj p | inChina p = wgsGcjNC p
         | otherwise = p

wgsGcjNC :: PCoords -> PCoords
wgsGcjNC (PCoords lat lon) =
    PCoords (lat + dLat / arclenLat) (lon + dLon / arclenLon)
  where
    rad = degToRad lat
    s = sin rad
    magic = 1 - gcjEe * s * s
    -- Length of a degree of latitude and of longitude, in meters.
    arclenLat = degToRad (gcjA * (1 - gcjEe) / (magic ** 1.5))
    arclenLon = degToRad (gcjA * cos rad / sqrt magic)
    x = lon - 105                  -- deviation parameters
    y = lat - 35
    -- Distortions in meters of arc length, as functions of (x, y).
    dLat = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y
         + 0.2 * sqrt (abs x)
         + (20 / 3) * ( 2 * sinpi (x * 6) + 2 * sinpi (x * 2)
                      + 2 * sinpi y + 4 * sinpi (y / 3)
                      + 16 * sinpi (y / 12) + 32 * sinpi (y / 30))
    dLon = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y
         + 0.1 * sqrt (abs x)
         + (20 / 3) * ( 2 * sinpi (x * 6) + 2 * sinpi (x * 2)
                      + 2 * sinpi x + 4 * sinpi (x / 3)
                      + 15 * sinpi (x / 12) + 30 * sinpi (x / 30))

--- | GCJ-02 to WGS-84, one step.
gcjWgs :: PCoords -> PCoords
gcjWgs p | inChina p = gcjWgsNC p
         | otherwise = p

gcjWgsNC :: PCoords -> PCoords
gcjWgsNC gcj = subtractPCoords gcj (subtractPCoords (wgsGcjNC gcj) gcj)

--- | GCJ-02 to BD-09.
gcjBd :: PCoords -> PCoords
gcjBd (PCoords lat lon) =
    PCoords (r * sin theta + bdDLat) (r * cos theta + bdDLon)
  where
    x = lon
    y = lat
    r = sqrt (x * x + y * y) + 0.00002 * sinpi (y * 3000 / 180)
    theta = atan2 y x + 0.000003 * cospi (x * 3000 / 180)

--- | BD-09 to GCJ-02.
bdGcj :: PCoords -> PCoords
bdGcj (PCoords lat lon) = PCoords (r * sin theta) (r * cos theta)
  where
    x = lon - bdDLon
    y = lat - bdDLat
    r = sqrt (x * x + y * y) - 0.00002 * sinpi (y * 3000 / 180)
    theta = atan2 y x - 0.000003 * cospi (x * 3000 / 180)

--- | WGS-84 to BD-09.
wgsBd :: PCoords -> PCoords
wgsBd = gcjBd . wgsGcj

wgsBdNC :: PCoords -> PCoords
wgsBdNC = gcjBd . wgsGcjNC

--- | BD-09 to WGS-84.
bdWgs :: PCoords -> PCoords
bdWgs = gcjWgs . bdGcj

bdWgsNC :: PCoords -> PCoords
bdWgsNC = gcjWgsNC . bdGcj

--- | Caijun 2014: nudge the rough inverse until the forward image lands back
--- on the input, ten rounds or 1e-5 deg.
bored :: (PCoords -> PCoords) -> (PCoords -> PCoords) -> PCoords -> PCoords
bored fwd rev bad = go (rev bad) (PCoords 99 99) (0 :: Int)
  where
    go wgs diff i
      | i >= 10 = wgs
      | magnitude diff <= prcEps = wgs
      | otherwise = go (subtractPCoords wgs d) d (i + 1)
      where
        d = subtractPCoords (fwd wgs) bad
    magnitude (PCoords la lo) = sqrt (la * la + lo * lo)

gcjWgsBored :: PCoords -> PCoords
gcjWgsBored = bored wgsGcjNC gcjWgs

bdGcjBored :: PCoords -> PCoords
bdGcjBored = bored gcjBd bdGcj

bdWgsBored :: PCoords -> PCoords
bdWgsBored = bored wgsBdNC bdWgs
