#lang racket

;; Dumps the eight-column test vector layout for py/checkvecs.py:
;; input lat, input lon, then wgs_gcj, gcj_bd and wgs_bd of the input.

(require "main.rkt")

(define (emit lat lon)
  (define p (latlon lat lon))
  (define wg (wgs-gcj p))
  (define gb (gcj-bd p))
  (define wb (wgs-bd p))
  (printf "~a\t~a\t~a\t~a\t~a\t~a\t~a\t~a\n"
          lat lon
          (latlon-lat wg) (latlon-lon wg)
          (latlon-lat gb) (latlon-lon gb)
          (latlon-lat wb) (latlon-lon wb)))

(define (point line)
  (define f (filter (lambda (s) (positive? (string-length s)))
                    (regexp-split #rx"[ \t]+" (string-trim line))))
  (and (>= (length f) 2)
       (let ([lat (string->number (list-ref f 0))]
             [lon (string->number (list-ref f 1))])
         (and lat lon
              (emit (real->double-flonum lat) (real->double-flonum lon))))))

(define args (current-command-line-arguments))
(define in (if (zero? (vector-length args))
               (current-input-port)
               (open-input-file (vector-ref args 0))))
(let loop ([line (read-line in)])
  (unless (eof-object? line)
    (point line)
    (loop (read-line in))))
(close-input-port in)
