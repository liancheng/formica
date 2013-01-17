#lang scribble/doc

@(require (for-label formica))

@(require
  scribble/manual
  scribble/eval)

@(define formica-eval
   (let ([sandbox (make-base-eval)])
     (sandbox '(require formica))
     sandbox))

@title[#:tag "intro"]{Введение }

Основная цель разработки Formica -- создание функционального языка программирования, столь же гибкого, как @emph{Racket} или@emph{Wolfram Mathematica}, и столь же синтаксически элегантного, как @emph{Qi} или @emph{Haskell}. Будучи диалектом @emph{Racket} он должен дополнять основной язык, не исключая вохможности использовать любые его билиотеки.


Диалект Formica основывается на модуле @racket[racket/base] и включает в себя стандартные библиотеки @racket[racket/list], @racket[racket/contract], @racket[racket/math], @racket[racket/promice], @racket[racket/string] и @racket[rackunit]. Кроме этого, он содержит в себе дополнительные библиотеки:
@itemize{
 @item{@racket[formica/rewrite] --- определение и использование @elemref["t:replace"]{подстановок},}
 @item{@racket[formica/formal] --- определение @elemref["t:formal"]{формальных функций},}
 @item{@racket[formica/tools] --- инструментарий для функционального программирования,}
 @item{@racket[formica/memoize] --- определение @elemref["t:memo"]{мемоизированных} функций,}
 @item{@racket[formica/monad] --- определение и использование @elemref["t:monad"]{монад},}
 @item{@racket[formica/contract] --- определение типов и @elemref["t:signature"]{сигнатур},}
 @item{@racket[formica/unit-testing] --- инструментарий для юнит-тестирования.}}
Любую из этих библиотек можно подключать отдельно от языка Formica с помощью формы @racket[require].