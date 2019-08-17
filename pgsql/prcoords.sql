CREATE OR REPLACE FUNCTION public.geodistance
(alat double precision, alng double precision, blat double precision, blng double precision)
RETURNS double precision AS $$
SELECT 2 * 6371000 * asin(
  sqrt(
    sin(radians($3-$1)/2)^2 +
    sin(radians($4-$2)/2)^2 * cos(radians($1)) * cos(radians($3))
  )
) AS distance;
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE COST 100;

CREATE OR REPLACE FUNCTION public.geodistance (a point, b point)
RETURNS double precision AS $$
SELECT 2 * 6371000 * asin(
  sqrt(
    sin(radians($2[0]-$1[0])/2)^2 +
    sin(radians($2[1]-$1[1])/2)^2 * cos(radians($1[0])) * cos(radians($2[0]))
  )
) AS distance;
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE COST 100;

CREATE OR REPLACE FUNCTION public.wgs_gcj (wgs point) RETURNS point AS
$$
DECLARE
  GCJ_A CONSTANT double precision := 6378245;
  GCJ_EE CONSTANT double precision := 0.00669342162296594323;
  x double precision;
  y double precision;
  dLat_m double precision;
  dLon_m double precision;
  radLat double precision;
  magic double precision;
  lat_deg_arclen double precision;
  lon_deg_arclen double precision;
BEGIN
  x := wgs[1] - 105;
  y := wgs[0] - 35;
  dLat_m := (-100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y +
    0.2 * sqrt(abs(x)) + (
        2 * sin(x * 6 * pi()) + 2 * sin(x * 2 * pi()) +
        2 * sin(y * pi()) + 4 * sin(y / 3 * pi()) +
        16 * sin(y / 12 * pi()) + 32 * sin(y / 30 * pi())
    ) * 20 / 3);
  dLon_m := (300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
      0.1 * sqrt(abs(x)) + (
          2 * sin(x * 6 * pi()) + 2 * sin(x * 2 * pi()) +
          2 * sin(x * pi()) + 4 * sin(x / 3 * pi()) +
          15 * sin(x / 12 * pi()) + 30 * sin(x / 30 * pi())
      ) * 20 / 3);

  radLat := radians(wgs[0]);
  magic := 1 - GCJ_EE * power(sin(radLat), 2);

  lat_deg_arclen := radians((GCJ_A * (1 - GCJ_EE)) / power(magic, 1.5));
  lon_deg_arclen = radians(GCJ_A * cos(radLat) / sqrt(magic));

  RETURN (wgs[0] + (dLat_m / lat_deg_arclen),
          wgs[1] + (dLon_m / lon_deg_arclen));
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE COST 150;

CREATE OR REPLACE FUNCTION public.gcj_wgs (gcj point) RETURNS point AS $$
SELECT $1 - (wgs_gcj($1) - $1) AS wgs
$$ LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE COST 150;

CREATE OR REPLACE FUNCTION public.gcj_wgs_bored (gcj point) RETURNS point AS
$$
DECLARE
  MAXITER CONSTANT double precision := 10;
  PRC_EPS CONSTANT double precision := 1e-5;
  wgs point;
  old point;
  diff point;
  i smallint;
BEGIN
  wgs = gcj_wgs(gcj);
  LOOP
    diff := (wgs - old);
    IF i < MAXITER AND (abs(diff[0]) > PRC_EPS OR abs(diff[1]) > PRC_EPS) THEN
      old := wgs;
      wgs := wgs - (wgs_gcj(wgs) - gcj);
      i := i + 1;
    ELSE
      RETURN wgs;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE COST 450;

CREATE OR REPLACE FUNCTION public.gcj_bd (gcj point) RETURNS point AS
$$
DECLARE
  r double precision;
  t double precision;
BEGIN
  r := sqrt(gcj[0] * gcj[0] + gcj[1] * gcj[1]) + 2e-5 * sin(3000 * radians(gcj[0]));
  t := atan2(gcj[0], gcj[1]) + 3e-6 * cos(3000 * radians(gcj[1]));
  RETURN point(r * sin(t) + 0.0060, r * cos(t) + 0.0065);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE COST 100;
