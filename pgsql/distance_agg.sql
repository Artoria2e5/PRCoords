CREATE TYPE _geodistance_agg_state AS
(distance double precision, lat double precision, lon double precision);

CREATE FUNCTION public._geodistance_agg_sfunc
(state _geodistance_agg_state, lat double precision, lon double precision)
RETURNS _geodistance_agg_state AS $$
SELECT
  (CASE WHEN $1 IS NULL THEN 0
   ELSE $1.distance+geodistance($1.lat, $1.lon, $2, $3) END),
  $2, $3
AS nextstate;
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION public._geodistance_agg_ffunc (state _geodistance_agg_state)
RETURNS double precision AS $$
SELECT $1.distance AS result;
$$ LANGUAGE SQL IMMUTABLE;

CREATE AGGREGATE geodistance_agg (double precision, double precision) (
  SFUNC = _geodistance_agg_sfunc,
  STYPE = _geodistance_agg_state,
  FINALFUNC = _geodistance_agg_ffunc
);
