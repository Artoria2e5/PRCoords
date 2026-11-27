# People's Rectified Coordinates, R port.  CC0.
GCJ_A <- 6378245
GCJ_EE <- 0.00669342162296594323
BD_DLAT <- 0.006
BD_DLON <- 0.0065
EARTH_R <- 6371000
PRC_EPS <- 1e-5

in_china <- function(lat, lon)
  lat >= 0.8293 & lat <= 55.8271 & lon >= 72.004 & lon <= 137.8347

wgs_gcj_nc <- function(lat, lon) {
  x <- lon - 105
  y <- lat - 35
  dlat <- -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y +
    0.2 * sqrt(abs(x)) +
    (2 * sinpi(x * 6) + 2 * sinpi(x * 2) + 2 * sinpi(y) +
       4 * sinpi(y / 3) + 16 * sinpi(y / 12) + 32 * sinpi(y / 30)) * 20 / 3
  dlon <- 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y +
    0.1 * sqrt(abs(x)) +
    (2 * sinpi(x * 6) + 2 * sinpi(x * 2) + 2 * sinpi(x) +
       4 * sinpi(x / 3) + 15 * sinpi(x / 12) + 30 * sinpi(x / 30)) * 20 / 3
  magic <- 1 - GCJ_EE * sinpi(lat / 180)^2
  cbind(
    lat = lat + dlat / ((GCJ_A * (1 - GCJ_EE) / magic^1.5) * (pi / 180)),
    lon = lon + dlon / ((GCJ_A * cospi(lat / 180) / sqrt(magic)) * (pi / 180))
  )
}

wgs_gcj <- function(lat, lon, check_china = TRUE) {
  out <- wgs_gcj_nc(lat, lon)
  if (check_china) {
    inside <- in_china(lat, lon)
    out[!inside, 1] <- lat[!inside]
    out[!inside, 2] <- lon[!inside]
  }
  out
}

gcj_wgs_nc <- function(lat, lon) {
  g <- wgs_gcj_nc(lat, lon)
  cbind(lat = 2 * lat - g[, 1], lon = 2 * lon - g[, 2])
}

gcj_wgs <- function(lat, lon, check_china = TRUE) {
  out <- gcj_wgs_nc(lat, lon)
  if (check_china) {
    inside <- in_china(lat, lon)
    out[!inside, 1] <- lat[!inside]
    out[!inside, 2] <- lon[!inside]
  }
  out
}

gcj_bd <- function(lat, lon) {
  y <- lat
  x <- lon
  r <- sqrt(x * x + y * y) + 0.00002 * sinpi(y * 3000 / 180)
  theta <- atan2(y, x) + 0.000003 * cospi(x * 3000 / 180)
  cbind(lat = r * sin(theta) + BD_DLAT, lon = r * cos(theta) + BD_DLON)
}

bd_gcj <- function(lat, lon) {
  x <- lon - BD_DLON
  y <- lat - BD_DLAT
  r <- sqrt(x * x + y * y) - 0.00002 * sinpi(y * 3000 / 180)
  theta <- atan2(y, x) - 0.000003 * cospi(x * 3000 / 180)
  cbind(lat = r * sin(theta), lon = r * cos(theta))
}

wgs_bd_nc <- function(lat, lon) {
  g <- wgs_gcj_nc(lat, lon)
  gcj_bd(g[, 1], g[, 2])
}

wgs_bd <- function(lat, lon, check_china = TRUE) {
  out <- wgs_bd_nc(lat, lon)
  if (check_china) {
    inside <- in_china(lat, lon)
    out[!inside, 1] <- lat[!inside]
    out[!inside, 2] <- lon[!inside]
  }
  out
}

bd_wgs_nc <- function(lat, lon) {
  g <- bd_gcj(lat, lon)
  gcj_wgs_nc(g[, 1], g[, 2])
}

bd_wgs <- function(lat, lon, check_china = TRUE) {
  out <- bd_wgs_nc(lat, lon)
  if (check_china) {
    inside <- in_china(lat, lon)
    out[!inside, 1] <- lat[!inside]
    out[!inside, 2] <- lon[!inside]
  }
  out
}

bored <- function(fwd, rev) {
  function(lat, lon, check_china = TRUE) {
    bad <- cbind(lat, lon)
    out <- rev(lat, lon, check_china)
    diff <- c(99, 99)
    for (i in 1:10) {
      if (sqrt(sum(diff * diff)) <= PRC_EPS) break
      diff <- fwd(out[, 1], out[, 2]) - bad
      out <- out - diff
    }
    out
  }
}

gcj_wgs_bored <- bored(wgs_gcj_nc, gcj_wgs)
bd_gcj_bored <- bored(gcj_bd, function(lat, lon, check_china = TRUE) bd_gcj(lat, lon))
bd_wgs_bored <- bored(wgs_bd_nc, bd_wgs)

distance <- function(lat1, lon1, lat2, lon2) {
  hav <- function(d) sinpi(d / 360)^2
  a <- hav(lat1 - lat2) +
    cospi(lat1 / 180) * cospi(lat2 / 180) * hav(lon1 - lon2)
  2 * EARTH_R * asin(sqrt(a))
}
