#lang info

(define collection "prcoords")
(define deps '("base" "typed-racket-lib"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("prcoords.scrbl" ())))
(define pkg-desc "GCJ-02 and BD-09 coordinate obfuscation from and to WGS-84")
(define pkg-authors '("Mingye Wang <arthur200126@gmail.com>"))
(define version "1.0.3")
(define license '(CC0-1.0 OR GPL-3.0-or-later))
