#lang scribble/doc

@(require (for-label formica))

@(require
  scribble/manual
  scribble/eval)

@(define formica-eval
   (let ([sandbox (make-base-eval)])
     (sandbox '(require formica))
     sandbox))

@title[#:tag "functional"]{Operators and functionals}

@defmodule[formica/tools]

The bindings documented in this section are provided by the @racketmodname[formica/tools] and @racketmodname[formica] modules.

@defproc[(function? [x Any]) Bool]
Returns @racket[#t] only if @racket[_x] is a function and @racket[#f] otherwise.


@defthing[id Fun]
The identity function.

Examples:
@interaction[#:eval formica-eval
  (id 1)
  (id 'x)
  (id +)
  ((id +) 1 2)
  (id id)
  (id '(a b c))]


@defproc[(arg (n Ind)) Fun]
Creates a trivial function which returns the @racket[_n]-th argument.

Examples:
@interaction[#:eval formica-eval
  (arg 1)
  ((arg 1) 'x 'y 'z)
  ((arg 2) 'x 'y 'z)
  ((arg 3) 'x 'y 'z)]


@defproc[(const (x Any)) Fun]
Creates a trivial function which returns @racket[_x] for any arguments.

Examples:
@interaction[#:eval formica-eval
  (const 'A)
  ((const 'A) 1)
  ((const 'A) 1 2)
  ((const +))]


@defproc[(negated (p Fun)) Fun]
Returns the negation of a predicate @racket[_p].

Examples:
@interaction[#:eval formica-eval
  (negated odd?)
  ((negated odd?) 2)
  ((negated <) 1 2)]


@defproc[(flipped [f Fun]) Fun]
Returns a function which is functionally equivalent to @racket[_f], 
but gets it's arguments in reversed order.

Examples:
@interaction[#:eval formica-eval
  (define snoc (flipped cons))
  snoc
  (snoc 1 2)
  ((flipped list) 1 2 3)]


@defproc[(fif [p Fun] [f Fun] [g Fun]) Fun]
Returns function @tt{x y ... --> (if (p x y ...) (f x y ...) (g x y ...))}.

Examples:
@interaction[#:eval formica-eval
  (map (fif odd? sub1 id) '(1 2 3 4))]


@defproc[(andf [f Fun] [g Fun] ...) Fun]
Returns function @tt{x y ... --> (and (f x y ...) (g x y ...) ...)}.

Examples:
@interaction[#:eval formica-eval
  (map (andf integer? positive?) '(-3/5 -1 0 2 4.2))]


@defproc[(orf [f Fun] [g Fun] ...) Fun]
Returns function @tt{x y ... --> (or (f x y ...) (g x y ...) ...)}.

Examples:
@interaction[#:eval formica-eval
  (map (orf integer? positive?) '(-3/5 -1 2 4.2))]


@defproc[(fork [f Fun] [g unary?]) Fun]
Returns function @tt{x y ... --> (f (g x) (g y) ...)}.

Examples:
@interaction[#:eval formica-eval
  ((fork cons sqr) 2 3)]


@defproc[(all-args [p Fun]) Fun]
Returns @tt{(fork and p)}.

Examples:
@interaction[#:eval formica-eval
  ((all-args real?) 2 -3 4.5)
  ((all-args real?) 2 'x 4.5)]


@defproc[(any-args [f Fun]) Fun]
Returns function @tt{(fork or p)}.

Examples:
@interaction[#:eval formica-eval
  ((any-args real?) '(1 2) 'a "abc" 1-2i)
  ((any-args real?) 'x 2 "abc" 0+8i)]


@defproc*[([(curry [f Fun] [arg Any] ...) (or/c curried? Any)]
            [(curryr [f Fun] [arg Any] ...) (or/c curried? Any)])]
Return partially applied (curried) function @racket[_f], with fixed arguments @racket[_arg ...].

Examples of partial application:
@interaction[#:eval formica-eval
  (curry list 1 2)
  ((curry list 1 2) 3 4)
  (map (curry cons 1) '(1 2 3))
  (curryr list 1 2)
  ((curryr list 1 2) 3 4)
  (map (curryr cons 1) '(1 2 3))
  (curry cons 1 2)
  (curryr cons 1 2)]

The @racket[curry] function correctly reduces the arity of curried function:
@interaction[#:eval formica-eval
  (procedure-arity cons)
  (procedure-arity (curry cons))
  (procedure-arity (curry cons 1))
  (procedure-arity (curryr cons 1))
  (procedure-arity (curry + 1 2 3))]

@defproc[(curried? [x Any]) boolean?]
Returns @racket[#t] if @racket[x] is partially applied or curried function, and @racket[#f] otherwise.

Examples:
@interaction[#:eval formica-eval
  (curried? (curry cons 1))
  (curried (curry +))
  (curried (curryr +))
  (curried? +)]

@defproc[(fixed-point [f Fun] [#:same-test same? (any/c any/c -> boolean?) equal?]) Fun]
Returns a function which finds a least fixed point of @racket[_f] by iterative application. 
For any argument @racket[x], this function calculates @racket[(_f (_f (_f ... (_f x))))] 
while result keeps changing in the sence of the @racket[_same?] function.

Example:
@interaction[#:eval formica-eval
  (define fcos (fixed-point cos))
  (fcos 1)
  (cos (fcos 1))]