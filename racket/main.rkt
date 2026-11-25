#lang typed/racket

;; People's Rectified Coordinates
;; Dedicated to the Public Domain under CC0

;; Typed Racket, with every coordinate a Flonum so the checker keeps the
;; arithmetic in unboxed doubles. sin(pi x) and cos(pi x) get their own
;; flonum helpers (flsinpi, flcospi); the GCJ polynomials below are phrased
;; in them, since their arguments are literally integer or rational
;; multiples of pi.

(require racket/flonum)

(provide latlon latlon? latlon-lat latlon-lon
         in-china?
         wgs-gcj wgs-gcj* gcj-wgs gcj-wgs*
         gcj-bd bd-gcj wgs-bd wgs-bd* bd-wgs bd-wgs*
         gcj-wgs-bored bd-gcj-bored bd-wgs-bored
         dcoord dcoord-abs dist)

;; A point in degrees.
(struct latlon ([lat : Flonum] [lon : Flonum])
  #:transparent)

;; Krasovsky 1940, the ellipsoid GCJ-02 pretends to use.
(: gcj-a Flonum)
(define gcj-a 6378245.0)
(: gcj-ee Flonum)
(define gcj-ee 0.00669342162296594323) ; f = 1/298.3

;; Baidu's artificial deviations.
(: bd-dlat Flonum)
(define bd-dlat 0.0060)
(: bd-dlon Flonum)
(define bd-dlon 0.0065)

;; Stop refining once the offset is below this many degrees.
(: prc-eps Flonum)
(define prc-eps 1e-5)

;; Mean Earth radius, for `dist`.
(: earth-r Flonum)
(define earth-r 6371000.0)

(: flsinpi (-> Flonum Flonum))
(define (flsinpi x) (flsin (* pi x)))

(: flcospi (-> Flonum Flonum))
(define (flcospi x) (flcos (* pi x)))

;; Racket only ships the 1-argument flatan, so atan2 needs the coercion.
(: flatan2 (-> Flonum Flonum Flonum))
(define (flatan2 y x) (real->double-flonum (atan y x)))

(: d2r (-> Flonum Flonum))
(define (d2r d) (* d (/ pi 180.0)))

(: dcoord (-> latlon latlon latlon))
(define (dcoord a b)
  (latlon (- (latlon-lat a) (latlon-lat b))
          (- (latlon-lon a) (latlon-lon b))))

(: dcoord-abs (-> latlon latlon Flonum))
(define (dcoord-abs a b)
  (let ([d (dcoord a b)])
    (if (> (abs (latlon-lat d)) (abs (latlon-lon d)))
        (abs (latlon-lat d))
        (abs (latlon-lon d)))))

(: hav (-> Flonum Flonum))
(define (hav theta)
  (let ([s (flsin (/ theta 2.0))])
    (* s s)))

;; Haversine, for estimating deviations.
(: dist (-> latlon latlon Flonum))
(define (dist a b)
  (let* ([a-lat (d2r (latlon-lat a))]
         [b-lat (d2r (latlon-lat b))]
         [d (dcoord a b)])
    (* 2.0 earth-r
       (flasin (flsqrt (+ (hav (d2r (latlon-lat d)))
                          (* (hav (d2r (latlon-lon d)))
                             (flcos a-lat)
                             (flcos b-lat))))))))

;; GCJ-02 and BD-09 are only defined in China.
(: in-china? (-> latlon Boolean))
(define (in-china? c)
  (and (<= 0.8293 (latlon-lat c) 55.8271)
       (<= 72.004 (latlon-lon c) 137.8347)))

(: wgs-gcj* (-> latlon Boolean latlon))
(define (wgs-gcj* wgs check-china?)
  (cond
    [(and check-china? (not (in-china? wgs))) wgs]
    [else
     (let* ([lat (latlon-lat wgs)]
            [lon (latlon-lon wgs)]
            [x (- lon 105.0)]
            [y (- lat 35.0)]
            ;; Distortions in meters of arc length, as functions of
            ;; (lon - 105, lat - 35).
            [dlat-m (+ -100.0 (* 2.0 x) (* 3.0 y) (* 0.2 y y) (* 0.1 x y)
                       (* 0.2 (flsqrt (abs x)))
                       (/ (* (+ (* 2.0 (flsinpi (* x 6.0)))
                                (* 2.0 (flsinpi (* x 2.0)))
                                (* 2.0 (flsinpi y))
                                (* 4.0 (flsinpi (/ y 3.0)))
                                (* 16.0 (flsinpi (/ y 12.0)))
                                (* 32.0 (flsinpi (/ y 30.0))))
                             20.0)
                         3.0))]
            [dlon-m (+ 300.0 x (* 2.0 y) (* 0.1 x x) (* 0.1 x y)
                       (* 0.1 (flsqrt (abs x)))
                       (/ (* (+ (* 2.0 (flsinpi (* x 6.0)))
                                (* 2.0 (flsinpi (* x 2.0)))
                                (* 2.0 (flsinpi x))
                                (* 4.0 (flsinpi (/ x 3.0)))
                                (* 15.0 (flsinpi (/ x 12.0)))
                                (* 30.0 (flsinpi (/ x 30.0))))
                             20.0)
                         3.0))]
            [rlat (d2r lat)]
            [sinr (flsin rlat)]
            [magic (- 1.0 (* gcj-ee sinr sinr))]
            ;; Length of a degree of latitude and of longitude, in meters.
            [arclat (d2r (/ (* gcj-a (- 1.0 gcj-ee))
                            (* magic (flsqrt magic))))]
            [arclon (d2r (/ (* gcj-a (flcos rlat)) (flsqrt magic)))])
       (latlon (+ lat (/ dlat-m arclat))
               (+ lon (/ dlon-m arclon))))]))

(: wgs-gcj (-> latlon latlon))
(define (wgs-gcj wgs) (wgs-gcj* wgs #t))

(: gcj-wgs* (-> latlon Boolean latlon))
(define (gcj-wgs* gcj check-china?)
  (dcoord gcj (dcoord (wgs-gcj* gcj check-china?) gcj)))

(: gcj-wgs (-> latlon latlon))
(define (gcj-wgs gcj) (gcj-wgs* gcj #t))

(: gcj-bd (-> latlon latlon))
(define (gcj-bd gcj)
  (let* ([y (latlon-lat gcj)]
         [x (latlon-lon gcj)]
         [r (+ (flsqrt (+ (* x x) (* y y)))
               (* 0.00002 (flsinpi (/ (* y 3000.0) 180.0))))]
         [theta (+ (flatan2 y x)
                   (* 0.000003 (flcospi (/ (* x 3000.0) 180.0))))])
    (latlon (+ (* r (flsin theta)) bd-dlat)
            (+ (* r (flcos theta)) bd-dlon))))

(: bd-gcj (-> latlon latlon))
(define (bd-gcj bd)
  (let* ([x (- (latlon-lon bd) bd-dlon)]
         [y (- (latlon-lat bd) bd-dlat)]
         [r (- (flsqrt (+ (* x x) (* y y)))
               (* 0.00002 (flsinpi (/ (* y 3000.0) 180.0))))]
         [theta (- (flatan2 y x)
                   (* 0.000003 (flcospi (/ (* x 3000.0) 180.0))))])
    (latlon (* r (flsin theta))
            (* r (flcos theta)))))

(: wgs-bd* (-> latlon Boolean latlon))
(define (wgs-bd* wgs check-china?)
  (gcj-bd (wgs-gcj* wgs check-china?)))

(: wgs-bd (-> latlon latlon))
(define (wgs-bd wgs) (wgs-bd* wgs #t))

(: bd-wgs* (-> latlon Boolean latlon))
(define (bd-wgs* bd check-china?)
  (gcj-wgs* (bd-gcj bd) check-china?))

(: bd-wgs (-> latlon latlon))
(define (bd-wgs bd) (bd-wgs* bd #t))

;; Caijun 2014: nudge the rough inverse until the forward image lands back on
;; the input, ten rounds or 1e-5 deg.
(: bored (-> (-> latlon latlon) (-> latlon latlon) latlon latlon))
(define (bored fwd rev bad)
  (let loop ([wgs (rev bad)]
             [diff (latlon 99.0 99.0)]
             [i 0])
    (cond
      [(or (>= i 10) (<= (dcoord-abs diff (latlon 0.0 0.0)) prc-eps)) wgs]
      [else
       (let ([d (dcoord (fwd wgs) bad)])
         (loop (dcoord wgs d) d (+ i 1)))])))

(: gcj-wgs-bored (-> latlon latlon))
(define (gcj-wgs-bored gcj)
  (bored (lambda ([w : latlon]) (wgs-gcj* w #f)) gcj-wgs gcj))

(: bd-gcj-bored (-> latlon latlon))
(define (bd-gcj-bored bd)
  (bored gcj-bd bd-gcj bd))

(: bd-wgs-bored (-> latlon latlon))
(define (bd-wgs-bored bd)
  (bored (lambda ([w : latlon]) (wgs-bd* w #f)) bd-wgs bd))

(module+ test
  (require typed/rackunit)

  ;; Two points, six transforms each, against the Python reference.
  (define (chk [got : latlon] [lat : Flonum] [lon : Flonum])
    (check-= (latlon-lat got) lat 1e-12)
    (check-= (latlon-lon got) lon 1e-12))

  (define a (latlon 35.0 105.0))
  (chk (wgs-gcj a) 34.99909863223526 105.00328624145706)
  (chk (gcj-wgs a) 35.00090136776474 104.99671375854294)
  (chk (gcj-bd a) 35.00630952256762 105.0063785678672)
  (chk (bd-gcj a) 34.99370731767234 104.99361165598081)
  (chk (wgs-bd a) 35.00540366845696 105.00966682831948)
  (chk (bd-wgs a) 34.9946348980774 104.99035737281594)

  (define b (latlon 30.0 120.0))
  (chk (wgs-gcj b) 29.997534331696095 120.00466044559735)
  (chk (gcj-wgs b) 30.002465668303905 119.99533955440265)
  (chk (gcj-bd b) 30.006359999864998 120.00640999946)
  (chk (bd-gcj b) 29.99366216605467 119.9935908161529)
  (chk (wgs-bd b) 30.003883055512777 120.011070620552)
  (chk (bd-wgs b) 29.99614733160918 119.98894747845797))

