#lang scribble/manual

@(require (for-label prcoords
                     racket/base))

@title{PRCoords for Racket}
@author{Mingye Wang}

@defmodule[prcoords]

A Typed Racket port of People's Rectified Coordinates: the GCJ-02 and BD-09
obfuscations of Chinese map coordinates, along with the Caijun refinement for
the inverses.

Coordinates are @racket[latlon] structs holding Flonums in degrees. The
transforms are @racket[wgs-gcj], @racket[gcj-wgs], @racket[gcj-bd],
@racket[bd-gcj], @racket[wgs-bd] and @racket[bd-wgs]; each has a @tt{*}
variant that takes an explicit China check, and the @tt{-bored} procedures run
ten rounds of the Caijun fixed-point refinement.

@defstruct[latlon ([lat Flonum] [lon Flonum])]{A point in degrees.}
