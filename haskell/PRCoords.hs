{-# LANGUAGE BangPatterns #-}

-- | This module contains functions for generating People's Rectified Coordinates.
-- Jeez, my naming is awful.
module PRCoords where (wgsGcj, gcjBd, wgsBd, gcjWgs, bdGcj, bdWgsC, gcjWgsC, bdGcjC, bdWgsC, caijun)
    -- import Data.Angle
    
    wgsGcj :: Degree -> Degree -> (Degree, Degree)
    wgsGcj !lat !lon = (lat + dLat / arclenLat, lon + dLon / arclenLon) where
        GCJ_A  = 6378245.0              -- <_ Krasovsky 1940
        GCJ_EE = 0.00669342162296594323 -- f = 1/298.3; e^2 = 2*f - f**2
        magic  = 1 - GCJ_EE * ((sin lat) ** 2) -- common expr
        arclenLat = (pi / 180.) * (GCJ_A * (1 - GCJ_EE)) * (magic ** 1.5)
        arclenLon = (pi / 180.) * (GCJ_A * (cos lat) / (sqrt magic))
        x = lon - 105 -- Here goes the deviation
        y = lat - 35
        gcjTerm !v !f !n = n * (sin f * v * pi)
        -- check operator stuff later
        dLat = -100 + 2 * x + 3 * y + 0.2 * y ** 2 + 0.1 * x * y + 0.2 * (sqrt (abs x)) + 20./3. * (
               gcjTerm x 6 2 + gcjTerm x 2 2 + gcjTerm y 1 2 + gcjTerm y 1./3. 4 +
               gcjTerm y 1./12. 16 + gcjTerm y 1./30. 32)
        dLon = 300  + 1 * x + 2 * y + 0.1 * x ** 2 + 0.1 * x * y + 0.1 * (sqrt (abs x)) + 20./3. * (
               gcjTerm x 6 2 + gcjTerm x 2 2 + gcjTerm x 1 2 + gcjTerm x 1./3. 4 +
               gcjTerm x 1./12. 15 + gcjTerm y 1./30. 30)
    
    gcjWgs :: Degree -> Degree -> (Degree, Degree)
    gcjWgs !lat !lon = (lat - (glat - lat), lon - (glon, lon)) where
        (glat, glon) = wgsGcj lat lon
    
    -- next: caijun
