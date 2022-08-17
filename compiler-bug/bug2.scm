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

;;;; This is "bug2.scm"

(define (rexists pred thing)
  (let tlp ((thing thing))
    (pp thing)
    (cond ((pred thing) #t)
          ((vector? thing)
           (pp 'here)
           (let ((n (vector-length thing)))
	     (let lp ((i 0))
	       (cond ((fix:= i n) #f)
		     ((tlp (vector-ref thing i))
                      (pp 'there)
                      #t)
		     (else (lp (fix:+ i 1)))))))
          ((list? thing)
           (any tlp thing))
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

(cf "bug2")
;Generating SCode for file: "bug2.scm" => "bug2.bin"...
;  This program does not have a USUAL-INTEGRATIONS declaration.
;  Without this declaration, the compiler will be unable to perform
;  many optimizations, and as a result the compiled program will be
;  slower and perhaps larger than it could be.  Please read the MIT
;  Scheme User's Guide for more information about USUAL-INTEGRATIONS.
;... done
;Compiling file: "bug2.bin" => "bug2.com"... done
;Unspecified return value

(load "bug2.scm")
;Loading "bug2.scm"... done
;Value: rexists

(rexists symbol? (vector 1 2))
#|
#(1 2)
here
1
2
;Value: #f
|#

(load "bug2.com")
;Loading "bug2.com"... done
;Value: rexists

(rexists symbol? (vector 1 2))
#|
#(1 2)
here
1
there
;Value: #t
|#
|#
