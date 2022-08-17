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

;;;; Patch to fix compiler code-generation bug in 11.2
#|
Date: Fri, 22 Apr 2022 08:59:37 +0000
From: Taylor R Campbell <campbell@mumble.net>
To: Gerald Jay Sussman <gjs@mit.edu>
Cc: cph@chris-hanson.org
Subject: Re: Compiler bug

The attached patch might help.  Should add an automatic test for this.
You can also load it dynamically into Scheme with:
|#

((lambda (x) (eval x (->environment '(compiler rtl-generator))))
 '(begin
    (define (generate/continuation continuation)
      (let ((label (continuation/label continuation)))
        (call-with-values
            (lambda ()
              (generate/rgraph
               (continuation/entry-node continuation)
               (lambda (node)
                 (define (with-value generator)
                   (let* ((temporary (rtl:make-pseudo-register))
                          (prologue
                           (rtl:make-assignment temporary
                                                (rtl:make-fetch register:value)))
                          (intermezzo (generator temporary)))
                     (values prologue intermezzo)))
                 (receive (prologue intermezzo)
                          (enumeration-case continuation-type
                              (continuation/type continuation)
                            ((PUSH)
                             (with-value rtl:make-push))
                            ((REGISTER VALUE PREDICATE)
                             (with-value
                              (lambda (expression)
                                (rtl:make-assignment
                                 (continuation/register continuation)
                                 expression))))
                            ((EFFECT)
                             (values (make-null-cfg) (make-null-cfg)))
                            (else
                             (error "Illegal continuation type" continuation)))
                   (scfg-append!
                    (if (continuation/avoid-check? continuation)
                        (rtl:make-continuation-entry label)
                        (rtl:make-continuation-header label))
                    prologue
                    (generate/continuation-entry/pop-extra continuation)
                    intermezzo
                    (generate/node node))))))
          (lambda (rgraph entry-edge)
            (make-rtl-continuation
             rgraph
             label
             entry-edge
             (compute-next-continuation-offset
              (continuation/closing-block continuation)
              (continuation/offset continuation))
             (continuation/debugging-info continuation))))))
    (define (find-variable get-value? context variable if-compiler if-ic if-cached)
      (if (variable/value-variable? variable)
          (begin
            (if (not get-value?)
                (error "Can't take locative of value variable" variable))
            (if-compiler
             (if (lvalue-integrated? variable)
                 (let ((rvalue (lvalue-known-value variable)))
                   (cond ((rvalue/constant? rvalue)
                          (rtl:make-constant (constant-value rvalue)))
                         ((and (rvalue/procedure? rvalue)
                               (procedure/trivial-or-virtual? rvalue))
                          (make-trivial-closure-cons rvalue))
                         (else
                          (error "illegal integrated value variable" variable))))
                 (rtl:make-fetch
                  (continuation/register (reference-context/procedure context))))))
          (let ((if-locative
                 (if get-value?
                     (lambda (locative)
                       (if-compiler (rtl:make-fetch locative)))
                     if-compiler)))
            (find-variable-internal context variable
              (and get-value? if-compiler)
              (lambda (variable locative)
                (if-locative
                 (if (variable-in-cell? variable)
                     (rtl:make-fetch locative)
                     locative)))
              (lambda (variable block locative)
                (cond ((variable-in-known-location? context variable)
                       (if-locative
                        (rtl:locative-offset locative
                                             (variable-offset block variable))))
                      ((ic-block/use-lookup? block)
                       (if-ic locative (variable-name variable)))
                      (else
                       (if-cached (variable-name variable)))))))))))

