{-# LANGUAGE BangPatterns #-}
{-# OPTIONS_GHC -fexcess-precision #-}
{-# OPTIONS_GHC -optc-ffast-math -optllc--enable-unsafe-fp-math -optllc--enable-no-nans-fp-math -optllc--enable-no-infs-fp-math #-}

--- | This module contains functions for generating People's Rectified Coordinates.
--- Jeez, my naming is awful.
module PRCoords where -- (wgsGcj, gcjBd, wgsBd, gcjWgs, bdGcj, bdWgsC, gcjWgsC, bdGcjC, bdWgsC, caijun)
    -- import Data.Angle
    -- import Numeric.FastMath
    
    data PCoords = PCoords { !lat :: Double
                           , !lon :: Double } deriving (Eq, Ord, Show)
    
    subtractPCoords :: PCoords -> PCoords -> PCoords
    subtractPCoords a b = PCoords (lat a - lat b) (lon a - lon b)
    
    wgsGcj :: PCoords -> PCoords
    wgsGcj (PCoords lat lon) = PCoords (lat + dLat / arclenLat) (lon + dLon / arclenLon) where
        gcj_a  = 6378245.0              -- <_ Krasovsky 1940
        gcj_ee = 0.00669342162296594323 -- f = 1/2983; e^2 = 2*f - f**2
        magic  = 1 - gcj_ee * ((sin (pi * lat / 180)) ** 2) -- common expr
        arclenLat = (pi / 180) * (gcj_a * (1 - gcj_ee)) / (magic ** 1.5)
        arclenLon = (pi / 180) * (gcj_a * (cos (pi * lat / 180)) / (sqrt magic))
        x = lon - 105 -- Here goes the deviation
        y = lat - 35
        gcjTerm !v !f !n = n * (sin f * v * pi)
        -- check operator stuff later
        dLat = -100 + 2 * x + 3 * y + 0.2 * y ** 2 + 0.1 * x * y + 0.2 * (sqrt (abs x)) + (*) (20/3) (
               gcjTerm x 6 2 + gcjTerm x 2 2 + gcjTerm y 1 2 + gcjTerm y (1/3) 4 +
               gcjTerm y (1/12) 16 + gcjTerm y (1/30) 32)
        dLon = 300 + 1 * x + 2 * y + 0.1 * x ** 2 + 0.1 * x * y + 0.1 * (sqrt (abs x)) + (*) (20/3) (
              gcjTerm x 6 2 + gcjTerm x 2 2 + gcjTerm x 1 2 + gcjTerm x (1/3) 4 +
              gcjTerm x (1/12) 15 + gcjTerm y (1/30) 30)
    
    gcjWgs :: PCoords -> PCoords
    gcjWgs a = subtractPCoords a (subtractPCoords ga a) where
        ga = wgsGcj a
    
    caiFix :: (PCoords -> PCoords) -> PCoords -> PCoords -> Int -> PCoords
    caiFix fwd guess fwd_result iter
        | iter > 5 = better
        | (abs $ lon diff) + (abs $ lat diff) < 1E-5 = better
        | otherwise = caiFix fwd better fwd_result (iter+1)
        where fwd_guess = fwd guess
              diff = subtractPCoords fwd_guess fwd_result
              better = subtractPCoords guess diff
    
    caijun :: (PCoords -> PCoords) -> (PCoords -> PCoords) -> (PCoords -> PCoords)
    caijun fwd rev = (\x -> caiFix fwd (rev x) x 0)
    
    gcjWgsC :: PCoords -> PCoords
    gcjWgsC = caijun wgsGcj gcjWgs
    
    -- next: baidu
