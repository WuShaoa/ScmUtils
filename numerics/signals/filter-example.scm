#| -*- Scheme -*-

Copyright (c) 1987, 1988, 1989, 1990, 1991, 1995, 1997, 1998,
              1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006,
              2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014,
              2015, 2016, 2017, 2018, 2019, 2020
            Massachusetts Institute of Technology

This file is part of MIT scmutils.

MIT scmutils is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

MIT scmutils is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with MIT scmutils; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301,
USA.

|#

;;; Frequency-domain filtration used to separate signals

(make-scope 8)
;Value: (new-scope 8)

(define 6Hz
  (sigfun:make (lambda (x) (cos (* :2pi 6 x)))
	       (sigfun:make-span -8 8)))

(plot-trace 1 6Hz)
;Value: (1 (-8. 8. -1. 1.))

(define 2Hz
  (sigfun:make (lambda (x) (cos (* :2pi 2 x)))
	       (sigfun:make-span -8 8)))

(plot-trace 2 2Hz)
;Value: (2 (-8. 8. -1. 1.))

(plot-trace 3 (+ 6Hz 2Hz))
;Value: (3 (-8. 8. -2. 2.))

(plot-trace 4 (magnitude (Fourier-transform (+ 6Hz 2Hz))))
;Value: (4 (-32. 32. 0. 8.))

(define lpf
  (sigfun:make (unit-boxcar 3)
	       (sigfun:make-span -32 32)))

(plot-trace 5 lpf)
;Value: (5 (-32. 32. 0 1))

(define bpf 
  (+ (sigfun:shift lpf 7)
     (sigfun:shift lpf -7)))

(plot-trace 6 bpf)
;Value: (6 (-32. 32. 0 1))

(plot-trace 7
	    (inverse-Fourier-transform
	     (* lpf (Fourier-transform (+ 6Hz 2Hz)))))
;Value: (7 (-8. 8. -1. 1.))

(plot-trace 8
	    (inverse-Fourier-transform
	     (* bpf (Fourier-transform (+ 6Hz 2Hz)))))
;Value: (8 (-8. 8. -1. 1.))


(graphics-clear *the-scope*)

;;; By using frequencies that are not commensurate with the interval
;;; we get spectral leakage.

(define 6.1Hz
  (sigfun:make (lambda (x) (cos (* :2pi 6.1 x)))
	       (sigfun:make-span -8 8)))

(plot-trace 1 6.1Hz)

(define 2.39Hz
  (sigfun:make (lambda (x) (sin (* :2pi 2.39 x)))
	       (sigfun:make-span -8 8)))

(plot-trace 2 2.39Hz)


(plot-trace 4 (magnitude (Fourier-transform (+ 6.1Hz 2.39Hz))))


(plot-trace 7
	    (inverse-Fourier-transform
	     (* lpf (Fourier-transform (+ 6.1Hz 2.39Hz)))))

(plot-trace 8
	    (inverse-Fourier-transform
	     (* bpf (Fourier-transform (+ 6.1Hz 2.39Hz)))))

