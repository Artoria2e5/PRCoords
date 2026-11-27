\name{prcoords}
\alias{prcoords}
\alias{in_china}
\alias{distance}
\alias{wgs_gcj}
\alias{wgs_gcj_nc}
\alias{gcj_wgs}
\alias{gcj_wgs_nc}
\alias{gcj_bd}
\alias{bd_gcj}
\alias{wgs_bd}
\alias{wgs_bd_nc}
\alias{bd_wgs}
\alias{bd_wgs_nc}
\alias{gcj_wgs_bored}
\alias{bd_gcj_bored}
\alias{bd_wgs_bored}
\title{Chinese coordinate obfuscation conversions}
\description{
  Convert between WGS-84, GCJ-02 and BD-09 coordinates.
}
\usage{
wgs_gcj(lat, lon, check_china = TRUE)
wgs_gcj_nc(lat, lon)
gcj_wgs(lat, lon, check_china = TRUE)
gcj_wgs_nc(lat, lon)
gcj_bd(lat, lon)
bd_gcj(lat, lon)
wgs_bd(lat, lon, check_china = TRUE)
wgs_bd_nc(lat, lon)
bd_wgs(lat, lon, check_china = TRUE)
bd_wgs_nc(lat, lon)
gcj_wgs_bored(lat, lon, check_china = TRUE)
bd_gcj_bored(lat, lon, check_china = TRUE)
bd_wgs_bored(lat, lon, check_china = TRUE)
in_china(lat, lon)
distance(lat1, lon1, lat2, lon2)
}
\arguments{
  \item{lat, lon}{Numeric vectors of latitude and longitude in degrees.}
  \item{check_china}{Logical; if true, points outside China are returned
    unchanged by the checked transforms.}
  \item{lat1, lon1, lat2, lon2}{Numeric vectors of latitude and longitude in
    degrees for the two endpoints.}
}
\value{
  The transforms return a two-column matrix with columns \code{lat} and
  \code{lon}.  \code{in_china} returns a logical vector.  \code{distance}
  returns metres.
}
\details{
  GCJ-02 and BD-09 are the obfuscated coordinates used by Chinese maps.
  They are not EPSG coordinate reference systems, so these functions work on
  plain numeric coordinates and do not attach a CRS.

  The \code{_nc} variants skip the China check.  The \code{_bored} variants
  iterate the inverse to a fixed point.
}
\examples{
gcj_wgs(35.0055, 105.0033)
bd_wgs(35.0055, 105.0033)
in_china(35, 105)
distance(35, 105, 35, 106)
}
\keyword{spatial}
