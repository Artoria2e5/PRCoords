;; People's Rectified Coordinates
;; Dedicated to the Public Domain under CC0

;; No idea about the module stuff.
;; Will it handle my awful, collision-prone naming?

;;(module prcoords typed/racket
;;  (provide latlon latlon-lat latlon-lon latlon? ;; Do I have to say these all?


;; I figured that before writing one for F#/Haskell/OCaml,
;; Writing one in parentheses first might be a good idea.

;; This sounds fun.
#lang typed/racket

;; I could have added some more restrictions, but whatever.
(struct latlon ([lat : Float] [lon : Float]))
;; I hear that those people in Haskell land use types to encode
;; more information. Should I do that?

;; These creepy x/y people...
(define (latlon-from-complex [c : Float-Complex]) : latlon
  (latlon (imag-part c) (real-part c)))
(define (latlon-to-complex [a : latlon]) : Float-Complex
  (make-rectangular (latlon-lon a) (latlon-lat a)))

;; This one is a little sloppy...
(: dcoord (-> latlon latlon
              latlon))
(define (dcoord a b)
  (latlon
   (- (latlon-lat a) (latlon-lat b))
   (- (latlon-lon a) (latlon-lon b))))

;; For looking into errors
(: dcoord-abs (-> latlon latlon
                  Float))
(define (dcoord-abs a b)
  (max
   (abs (latlon-lat (dcoord a b)))
   (abs (latlon-lon (dcoord a b)))))

;; For estimating deviations
(define
  (dist [a : latlon] [b : latlon]) : Float
  (let
      ([a-lat (degrees->radians (latlon-lat a))]
       [a-lon (degrees->radians (latlon-lon a))]
       [b-lat (degrees->radians (latlon-lat b))]
       [b-lon (degrees->radians (latlon-lon b))]
       [d-lat (degrees->radians (latlon-lat (dcoord a b)))]
       [d-lon (degrees->radians (latlon-lon (dcoord a b)))]
       [R 6371000.]
       [hav : (-> Float Float)
            (λ (theta)
              (* (sin (/ 2 theta)) (sin (/ 2 theta))))])
    (* 2. R (cast (asin (sqrt (+ (hav d-lat)
                                 (*
                                  (hav d-lon)
                                  (cos a-lat)
                                  (cos b-lat))))) Float))))

;; What, you want a polygon check? Not now.
(: probably-bad (-> latlon
                    Boolean))
(define (probably-bad a)
  (and
   #t ;; TODO
   #t
   #t
   #t))

;; For your sanity, no functions will be defined with the
;; rough "sanity" check on by default.
(: sanity-wrap (-> (-> latlon latlon) (-> latlon Boolean)
                   (-> latlon latlon)))
(define (sanity-wrap conv check)
  (λ ([a : latlon])
    (if (check a)
        (conv a)
        a)))

;; Sometimes people are like...
(: sanity-wrap-backward (-> (-> latlon latlon) (-> latlon Boolean)
                            (-> latlon latlon)))
(define (sanity-wrap-backward conv check)
  (λ ([a : latlon])
    (let ([c (conv a)])
      (if (check c)
          c
          a))))


;; Finally a conversion. I understand that you have been
;; cursing for all these poorly-written BS.
(: wgs-gcj (-> latlon
               latlon))
(define (wgs-gcj wgs)
  ; For (human) laziness
  (let* ([gcj-ee 0.00669342162296594323]  ;; Krasovsky 1940, Not What You Use With WGS-84(TM)
         [gcj-a 6378245.]
         [x (- (latlon-lon wgs) 105.)]    ;; Deviation params
         [y (- (latlon-lat wgs) 35.)]
         [dlat 0.] ;; Yay, huge expressions, not today
         [dlon 0.]
         [rlat (degrees->radians (latlon-lat wgs))]
         ;; This type checker is unhappy with...
         [mm (cast (- 1 (* gcj-ee (sin rlat) (sin rlat))) Positive-Flonum)]
         [arclat (exact->inexact (* (/ pi 180.) gcj-a (- 1 gcj-ee) (expt mm -1.5)))]
         [arclon (exact->inexact (* (/ pi 180.) gcj-a (cos rlat) (sqrt mm)))])
    (latlon
     (+ (latlon-lat wgs) (/ dlat arclat))
     (+ (latlon-lon wgs) (/ dlon arclon))))) ;; Do you really think I am gonna finish this?

;; A rough reverse function.
(: gcj-wgs-rough (-> latlon
                     latlon))
(define (gcj-wgs-rough gcj)
  (dcoord gcj
          (dcoord (wgs-gcj gcj)
                  gcj)))

;; Cai's iteration.
;; Not now. Chill, it's just carrying four accumulators around and stuff.
(define
  (caijun-iterate [fwd : (-> latlon latlon)]
                  [rough-rev : (-> latlon latlon)]
                  #:eps [eps : Float 1e-4]
                  #:maxn [maxn : Integer 10])
  (λ 
      ([bad : latlon]) : latlon
    (letrec
        ([improve : (-> latlon latlon Integer
                        latlon)
                  (λ
                    (curr prev i)
                    ;; Fixing a sloppy part in js, etc.:
                    ;; what happens if rough-rev is just an `id`?
                    (if (or (and (< i maxn) (< (dcoord-abs curr prev) eps)) (= i 0))
                        (improve
                         (dcoord curr
                                 (dcoord (fwd curr)
                                         bad))
                         curr
                         (+ 1 i))
                        curr))])
      (improve bad (rough-rev bad) 0))))

(define gcj-wgs : (-> latlon latlon)
  (caijun-iterate wgs-gcj gcj-wgs-rough))

;; Baudu's Obfuscation.
(define
  (gcj-bd [a : latlon]) : latlon
  (let
      ([bd-delta 0.0060+0.0065i]
       [c1 (latlon-to-complex a)]
       [lat (latlon-lat a)]
       [lon (latlon-lon a)])
    (latlon-from-complex
     (+
      (make-polar
       (+ (magnitude c1) (* 0.00002 (sin (* 3000. (degrees->radians lat)))))
       (+ (angle c1) (* 0.000003 (cos (* 3000. (degrees->radians lon))))))
      bd-delta))))

(define
  (bd-gcj-rough [a : latlon]) : latlon
  (let*
      ([bd-delta 0.0060+0.0065i]
       [c1 (- (latlon-to-complex a) bd-delta)]
       [lat (imag-part c1)]
       [lon (real-part c1)])
    (latlon-from-complex
     (make-polar
      (- (magnitude c1) (* 0.00002 (sin (* 3000. (degrees->radians lat)))))
      (- (angle c1) (* 0.000003 (cos (* 3000. (degrees->radians lon)))))))))

(define bd-gcj : (-> latlon latlon)
  (caijun-iterate gcj-bd bd-gcj-rough))

(define (wgs-bd [a : latlon]) : latlon
  (gcj-bd (wgs-gcj a)))
(define (bd-wgs-rough [a : latlon]) : latlon
  (gcj-wgs-rough (bd-gcj-rough a)))        
(define bd-wgs : (-> latlon latlon)
  (caijun-iterate wgs-bd bd-wgs-rough))

;; Yay!
