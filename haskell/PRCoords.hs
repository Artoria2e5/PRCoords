{-# LANGUAGE BangPatterns #-}

-- | This module contains functions for generating People's Rectified Coordinates.
-- Jeez, my naming is awful.
module PRCoords where (wgsGcj, gcjBd, wgsBd, gcjWgs, bdGcj, bdWgsC, gcjWgsC, bdGcjC, bdWgsC, caijun)
    import Data.Angle
    
    wgsGcj :: Degree -> Degree -> (Degree, Degree)
    wgsGcj !lat !lon = (lat + dLat / arclenLat, lon + dLon / arclenLon) where
        GCJ_A  = 6378245.0              -- <_ Krasovsky 1940
        GCJ_EE = 0.00669342162296594323 -- f = 1/298.3; e^2 = 2*f - f**2
        magic  = 1 - GCJ_EE * ((sine lat) ** 2) -- common expr
        arclenLat = (pi / 180.) * (GCJ_A * (1 - GCJ_EE)) * (magic ** 1.5)
        arclenLon = (pi / 180.) * (GCJ_A * (cosine lat) / (sqrt magic))
        x = lon - 105 -- Here goes the deviation
        y = lat - 35
        -- Not now!
    
    gcjWgs :: Degree -> Degree -> (Degree, Degree)
    gcjWgs !lat !lon = (lat - (glat - lat), lon - (glon, lon)) where
        (glat, glon) = wgsGcj lat lon
    
    -- next: caijun
