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
(struct latlon ([lat : Real] [lon : Real]))
;; I hear that those people in Haskell land use types to encode
;; more information. Should I do that?

;; This one is a little sloppy...
(: dcoord (-> latlon latlon
              latlon))
(define (dcoord a b)
        (latlon
          (- (latlon-lat a) (latlon-lat b))
          (- (latlon-lon a) (latlon-lon b)))

;; For looking into errors
(: dcoord-abs (-> latlon
                  Real))
(define (dcoord-abs a b)
        (max
          (abs (latlon-lat (dcoord a b)))
          (abs (latlon-lon (dcoord a b))))

;; For estimating deviations
(: dist (-> latlon latlon
            Real))
(define (dist a b)
        42.0) ;; Some round-earth haversine stuff, not now
        
;; What, you want a polygon check? Not now.
(: probably-bad (-> latlon
                      Boolean))
(define (probably-bad a)
          (and
            ()
            ()
            ()
            ())

;; For your sanity, no functions will be defined with the
;; rough "sanity" check on by default.
(: sanity-wrap (-> (-> latlon latlon) (-> latlon Boolean)
                   (-> latlon latlon)))
(define (sanity-wrap conv check)
        (lambda ([a : latlon])
                (if (check a)
                    (conv a)
                    a)))

;; Finally a conversion. I understand that you have been
;; cursing for all these poorly-written BS.
(: wgs-gcj (-> latlon
               latlon))
(define (wgs-gcj wgs)
  ; For laziness
  (let ([x (- (latlon-lon wgs) 105)]    ;; Deviation params
        [y (- (latlon-lat wgs) 35)]
        [rlat (degrees->radians (latlon-lat wgs))]
        [gcj-ee 0.00669342162296594323] ;; Krasovsky 1940, Not What You Use With WGS-84(TM)
        [gcj-a 6378245])
  (let ([mm (- 1
              (* gcj-ee
                (expt (sin rlat)
                      2)))]
        [dlat] ;; Yay, huge expressions
        [dlon]
        [arclat]
        [arclon])
        (latlon
          (+ (latlon-lat wgs) (/ dlat arclat))
          (+ (latlon-lon wgs) (/ dlot arclot))))) ;; Do you really think I am gonna finish this?

;; A rough reverse function.
(: gcj-wgs-rough (-> latlon
                     latlon))
(define (gcj-wgs-rough gcj)
        (dcoord gcj
          (dcoord (wgs-gcj gcj)
                    gcj))

;; Cai's iteration.
;; Not now. Chill, it's just carrying four accumulators around and stuff.
