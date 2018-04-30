-- Depends on PostGIS and prcoords.sql

CREATE OR REPLACE FUNCTION public._latlng2geometry (p point)
RETURNS geometry AS $$
SELECT ST_SetSRID(ST_MakePoint(p[1], p[0]), 4326);
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION public._geometry2latlng (p geometry)
RETURNS point AS $$
BEGIN
  IF GeometryType(p) != 'POINT' THEN
    RAISE EXCEPTION 'Input geom must be a point. Currently is: %', GeometryType(p);
  ELSIF ST_SRID(p) != 4326 THEN
    RAISE EXCEPTION 'SRID of the input geom must be 4326. Currently is: %', ST_SRID(p);
  END IF;
  RETURN point(ST_Y($1), ST_X($1));
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION public.wgs_gcj (wgs geometry)
RETURNS geometry AS $$
SELECT _latlng2geometry(wgs_gcj(_geometry2latlng($1)))
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION public.gcj_wgs (gcj geometry)
RETURNS geometry AS $$
SELECT _latlng2geometry(gcj_wgs(_geometry2latlng($1)))
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION public.gcj_bd (gcj geometry)
RETURNS geometry AS $$
SELECT _latlng2geometry(gcj_bd(_geometry2latlng($1)))
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;
