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

;;;; This is "bug.scm"

(declare (usual-integrations))

(define-integrable down-type-tag '*down*)


(define (differential? obj)
  (and (pair? obj)
       (eq? (car obj) '*diff*)))


(define (up . args)
  (vector->up (list->vector args)))

(define (down . args)
  (vector->down (list->vector args)))


(define (vector->up v)
  v)

(define (vector->down v)
  (list down-type-tag v))



(define (up? x)
  (vector? x))

(define (down? x)
  (and (pair? x)
       (eq? (car x) down-type-tag)))

(define (structure? x)
  (or (up? x) (down? x)))

(define (s:length v)
  (if (structure? v)
      (vector-length (s:->vector v))
      1))

(define (up->vector v)
  v)

(define (down->vector v)
  (cadr v))

(define (s:->vector v)
  (cond ((up? v) (up->vector v))
	((down? v) (down->vector v))
	(else
	 (error "Bad structure -- S:->VECTOR" v))))

(define (s:ref v i)
  (if (structure? v)
      (vector-ref (s:->vector v) i)
      (if (fix:= i 0)
	  v
	  (error "Bad structure -- S:REF" v i))))

(define (list? x)
  (or (null? x)
      (and (pair? x)
           (list? (cdr x)))))

(define (any pred lst)
  (cond ((null? lst) #f)
        ((pred (car lst)) #t)
        (else (any pred (cdr lst)))))

(define (rexists pred thing)
  (let tlp ((thing thing))
    (pp thing)
    (cond ((pred thing) #t)
	  ((structure? thing)
	   (let ((n (s:length thing)))
	     (let lp ((i 0))
	       (cond ((fix:= i n) #f)
		     ((tlp (s:ref thing i)) #t)
		     (else (lp (fix:+ i 1)))))))
          ;; This line is the loser
          ((list? thing)
           (any tlp thing))
          #|
	  ((pair? thing)
           (or (tlp (car thing)) (tlp (cdr thing))))
          |#
          (else #f))))

#|
Summary of configuration options:
  heap size: 300219
  constant-space size: 2242
  stack size: 1024
  library path: /usr/local/Scheme/mit-scheme-11.2/usr/local/lib/mit-scheme-x86-64-11.2
  band: /usr/local/Scheme/mit-scheme-11.2/usr/local/lib/mit-scheme-x86-64-11.2/all.com
  emacs subprocess: yes
  force interactive: no
  disable core dump: no
  suppress noise: no
  no unused arguments
MIT/GNU Scheme running under GNU/Linux

Copyright (C) 2020 Massachusetts Institute of Technology
This is free software; see the source for copying conditions. There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Image saved on Sunday March 7, 2021 at 3:24:56 PM
  Release 11.2 || SF || LIAR/x86-64

(cf "bug1")
;Generating SCode for file: "bug1.scm" => "bug1.bin"... done
;Compiling file: "bug1.bin" => "bug1.com"... done
;Unspecified return value

(load "bug1.scm")
;Loading "bug1.scm"... done
;Value: rexists

(rexists differential? (up (up 1 2) (down 3 4)))
;Value: #f

(load "bug1.com")
;Loading "bug1.com"... done
;Value: rexists

(rexists differential? (up (up 1 2) (down 3 4)))
;Value: #t

;;; But! If I comment out the nasty clause I get:

;Generating SCode for file: "bug.scm" => "bug.bin"... done
;Compiling file: "bug.bin" => "bug.com"... done
;Unspecified return value

;Loading "bug.scm"... done
;Value: rexists

#(#(1 2) (*down* #(3 4)))
#(1 2)
1
2
(*down* #(3 4))
3
4
;Value: #f

;Loading "bug.com"... done
;Value: rexists

#(#(1 2) (*down* #(3 4)))
#(1 2)
1
2
(*down* #(3 4))
3
4
;Value: #f

|#