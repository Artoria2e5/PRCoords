#lang info

;; Dependencies are the packages behind the collections listed in the compiled
;; .dep files: racket/base and typed/* need base and typed-racket-lib, the
;; scribblings need scribble-lib, and the test submodule's typed/rackunit is
;; in rackunit-typed.
(define collection "prcoords")
(define deps '("base" "typed-racket-lib"))
(define build-deps '("scribble-lib" "racket-doc"))
(define test-deps '("rackunit-typed"))
(define scribblings '(("prcoords.scrbl" ())))
(define pkg-desc "GCJ-02 and BD-09 coordinate obfuscation from and to WGS-84")
(define pkg-authors '("Mingye Wang <arthur200126@gmail.com>"))
(define version "1.1.0")
(define license '(CC0-1.0 OR GPL-3.0-or-later))
