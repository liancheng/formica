#lang scribble/doc

@(require (for-label formica))

@(require
  scribble/manual
  scribble/eval)

@(define formica-eval
   (let ([sandbox (make-base-eval)])
     (sandbox '(require formica))
     sandbox))

@title[#:tag "partial"]{Partial function application}

@defmodule[formica/partial-app]

The bindings documented in this section are provided by the @racketmodname[formica/partial-app] and @racketmodname[formica] modules.

In order to get Formica language without syntax for partial application, use @racket{#lang formica/regular-app} at the header of the file
or @racket[(require formica/regular-app)]. It will load all bindings from  @racketmodname[formica] module except for those provided in
@racketmodname[formica/partial-app].

One of features making Formica different from Racket, is simplifyed syntax for partial application
and currying, which is close to Haskell or Qi programming laguages.

For example, function @racket[cons], expects two arguments:
@interaction[#:eval formica-eval
  (cons 1 2)]

We may consider it as curried function: as a sequence of nested closures:
@interaction[#:eval formica-eval
  (cons)
  ((cons) 1)
  (((cons) 1) 2)]

Here is partial application of binary function @racket[cons]:
@interaction[#:eval formica-eval
  (cons 1)
  ((cons 1) 2)]
In the expression @racket[(cons 1)] the first argument is fixed, resulting an unary function.

That's how it is possible to define the increment function:
@interaction[#:eval formica-eval
  ((+ 1) 3)
  (define inc (+ 1))
  (inc 3)
  (map (+ 1) '(1 2 3))] 

The simplifyed syntax makes possible only "left" partial application by fixing arguments from left to right. 
For fixing the sequence of arguments "from the right" one has to use explicit partial application using 
@racket[curryr] function.
                       
Examples of explicit partial application:
@interaction[#:eval formica-eval
  (- 1)
  (curry - 1)
  ((curry - 1) 3)
  (map (curry - 1) '(1 2 3))
  (curryr - 1)
  ((curryr - 1) 3)
  (map (curryr - 1) '(1 2 3))]

@defproc[(apply* [f Fun] [v Any] ...) Any]
Applies @racket[_f] to a list of arguments @racket[_v ...] in a regular way without partial application.