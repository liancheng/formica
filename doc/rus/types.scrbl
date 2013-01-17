#lang scribble/doc

@(require (for-label formica))

@(require
  scribble/manual
  scribble/eval)

@(define formica-eval
   (let ([sandbox (make-base-eval)])
     (sandbox '(require formica))
     sandbox))

@declare-exporting[formica]

@title[#:tag "types"]{Cистема типов}

Formica --- язык со @emph{строгой динамической типизацией}.

Типы в языке выполняют идентификационную и охраняющую роль, оптимизации, основанной на типах, в языке нет.

Указывать типы функций и их аргументов не обязательно, однако их использование помогает документировать код, делает его более устойчивым и облегчает отладку
программ.

Тип связан с величиной, а не с переменной, он представляет множество к которому принадлежит величина. Множество может быть задано перечислением, предикатом или  индуктивным определением.

В языке можно использовать
@itemize{@item{@elemref["t:prim"]{простые типы};}
         @item{@elemref["t:ADT"]{абстрактные} алгебраические и полиморфные типы;}
         @item{@elemref["t:funtype"]{функциональные типы} и @elemref["t:signature"]{сигнатуры функций}.}}

@section[#:tag "type:predicates"]{Контракты}

@emph{Типы данных} определяются контрактами.

@elemtag["t:predicate"] В роли контракта может выступать
@itemize{@item{константа, принадлежащая простому типу;}
         @item{любой унарный предикат --- функция, возвращающая @racket[#t] или любое значение отличное от @racket[#f], для величин соответствующего типа и @racket[#f] -- для любых других величин.;}
         @item{составной контракт, сконструированный с помощью @elemref["t:type:comb"]{комбинаторов контрактов}.}}

Контракты можно определять, как обыкновенные функции --- с помощью формы @racket[define].

@defproc[(contract? [v Any]) Bool]
Возвращает @racket[#t] только если @racket[_v] может быть
использовано, как контракт, и @racket[#f] --- во всех других случаях.

@interaction[#:eval formica-eval
 (contract? number?)
 (contract? Num)
 (contract? (and/c integer? positive?))
 (contract? cons)]

Любая константа, принадлежащая @elemref["t:prim"]{простому типу}, представляет собой @emph{единичный тип}
и может рассматриваться, как контракт для этого типа.

@interaction[#:eval formica-eval
 (contract? 5)
 (contract? 'abc)]

@margin-note{Определена в модуле @racket[formica/types]}
@defform[(is v type-pred) #:contracts ([v Any] [type-pred contract?])]
Возвращает @racket[#t], если @racket[_v] принадлежит типу,
определяемому контрактом @racket[_type-pred], и @racket[#f] --- во всех других случаях.

Отличается от непосредственной аппликации предиката тем, что
@itemize{@item{позволяет рассматривать единичные типы;} 
         @item{если аппликация предиката @racket[_type-pred] к величине @racket[_v] приводит к ошибке, возвращает @racket[#f] не останавливая выполнения программы.}}

@interaction[#:eval formica-eval
 (is 'abc symbol?)
 (is 'abc 'abc)
 (is 1.2 odd?)]

Непосредственное применение предиката @racket[odd?] к числу, не являющемуся целым,
привело бы к ошибке:
@interaction[#:eval formica-eval
 (odd? 1.2)]

Любая величина может одновременно принадлежать неограниченному множеству типов.
Так, например, число @racket[5] одновременно принадлежит следующим типам:
@itemize{@item{единичному типу @racket[5]:
           @interaction[#:eval formica-eval (is 5 5)]}          
         @item{числовому типу, определяемому предикатом @racket[number?]:
           @interaction[#:eval formica-eval (is 5 number?)]}
         @item{числовому типу "целое число", определяемому предикатом @racket[integer?]:
           @interaction[#:eval formica-eval (is 5 integer?)]}
         @item{числовому типу "нечётное число", определяемому предикатом @racket[odd?]:
           @interaction[#:eval formica-eval (is 5 odd?)]}
         @item{алгебраическому типу, определяемому контрактом @racket[(or/c 0 1 2 3 5 8 13)]:
           @interaction[#:eval formica-eval (is 5 (or/c 0 1 2 3 5 8 13))] и т.д.}}

Все величины принадлежат типу @racket[Any].

Проверка типов может организовываться явно, с помощью управляющих конструкций @racket[if], @racket[cond] и т.п. или же путём определения @elemref["t:signature"]{сигнатур функций}.

@section[#:tag "types:primitive"]{Простые типы данных}


К @elemtag["t:prim"]{простым типам} относятся
@itemize{@item{типы данных, определяемых предикатами (@emph{логический тип}, @emph{числа}, @emph{строки}, @emph{символы} и т.д.),}
         @item{@emph{функциональные типы}.}}

Все функции и подстановки удовлетворяют предикату @racket[function?].

К @elemtag["t:funtype"]{функциональным типам} относятся:
@itemize{@item{@elemref["t:memo"]{мемоизированные} функции, определяемые предикатом @racket[memoized?],}
         @item{@elemref["t:curry"]{каррированные} и @elemref["t:partial"]{частично применённые} функции, определяемые предикатом @racket[curried?],} 
         @item{@elemref["t:formal"]{формальные} функции, определяемые предикатом @racket[formal?],}
         @item{@elemref["t:predicate"]{контракты}, определяемые предикатом @racket[contract?].}}

Функциональные типы, описывающие типы для аргументов и возвращаемого значения, можно
определять с помощью @elemref["t:signature"]{сигнатур}.

Некоторые часто используемые простые типы имеют краткие обозначения. Они могут рассматриваться, как имена множеств, отражающие эти типы.

@margin-note{Определены в модуле @racket[formica/types]}
@defthing[Bool contract?] определяет множество величин логического типа. Эквивалентен предикату @racket[boolean?].
@defthing[Num contract?] определяет множество чиел. Эквивалентен предикату @racket[number?].
@defthing[Real contract?]  определяет множество действительных чисел. Эквивалентен предикату @racket[real?].
@defthing[Int contract?]  определяет множество целых чисел. Эквивалентен предикату @racket[integer?].
@defthing[Nat contract?]  определяет множество натуральных чисел.
@defthing[Index contract?]  определяет множество натуральных чисел больших нуля.
@defthing[Str contract?]  определяет множество строк. Эквивалентен предикату @racket[string?].
@defthing[Sym contract?] определяет множество символов. Эквивалентен предикату @racket[symbol?].
@defthing[Fun contract?]  определяет множество функций. Эквивалентен предикату @racket[function?].


@section[#:tag "type:definition"]{Определение типов}

Форма @racket[define-type] позволяет давать определения типам, используя синтаксис, подобный тому, что принято использовать для определения
алгебраических типов данных.

@margin-note{Определена в модуле @racket[formica/types]}
@defform*[#:literals(? and or not)
 [(define-type name c ...)
  (define-type (name x ...) c ...)] #:contracts ([c contract?] [x contract?])]
Конструирует именованный тип, возвращающий @racket[#t], если его аргумент удовлетворяет хотя бы одному из контрактов @racket[_c ...]. Если указаны типы-параметры @racket[_x ...], определяется параметризуемый тип.

Типы, определяемые формой @racket[define-type] соответствуют понятию @emph{алгебраического типа}, где простые типы соответствуют @emph{единичным типам}, составные и абстрактные типы ---  @emph{произведению типов}, а последовательность @nonbreaking{@racket[_c ...]} --- @emph{сумме типов}.

@elemtag["t:type:comb"]{@bold{Комбинаторы контрактов}}

@defproc[(Any [v Any]) contract?]
контракт для произвольного выражения.

@deftogether[
[@defproc[(or/c [c contract?] ...) contract?]
 @defproc[(and/c [c contract?] ...) contract?]
 @defproc[(not/c [c contract?]) contract?]]]
Объединение, пересечение и отрицание контрактов.

@section[#:tag "types:container"]{Контейнерные типы}

Алгебраические типы данных создаются с помощью контейнерных типов: пар или формальных функций.

@margin-note{Определена в модуле @racket[formica/types]}
@defproc[(cons: [c1 contract?] [c2 contract?]) contract?]
контракт для @elemref["t:pair"]{пары}, элементы которой имеют типы @racket[_c1] и @racket[_c2].

@interaction[#:eval formica-eval
  (is (cons 1 2) (cons: 1 2))
  (is (cons 1 2) (cons: Num Num))
  (is (cons 1 'x) (cons: Num Num))
  (is (cons 1 (cons 2 'x)) (cons: Num (cons: Num Sym)))]


@margin-note{Определена в модуле @racket[formica/contract]}
@defform*[
[(list: c ...) 
 (list: c ..)] #:contracts [(c contract?)]]
контракт для @elemref["t:list"]{списка}.

@itemize{ @item{@racket[(list: c ...)] контракт для списка фиксированным числом элементов.
                 Число элементов списка должно совпадать с числом контрактов @racket[_c ...] и все эти 
                 элементы должны соответствовать своим контрактам.
                 @interaction[#:eval formica-eval
                   (is '(1 2) (list: 1 2))
                   (is '(1 2) (list: Num Num))
                   (is '(1 2) (list: Num Sym))
                   (is '(1 2 -3) (list: positive? positive? negative?))]}
          @item{@racket[(list: c ..)] контракт для списка, все элементы которого удовлетворяют контракту @racket[c].
                 @interaction[#:eval formica-eval
                   (is '(1 2) (list: Num ..))
                   (is '(1 1 1 1) (list: 1 ..))
                   (is '(1 2 x 4 5) (list: Num ..))
                   (is '(1 2 30 1) (list: positive? ..))]}}

@defform/none[(f: c ...) #:contracts [(c contract?)]]
контракт для аппликации 
@elemref["t:formal"]{формальной функции} @racket[_f]. Подобен контракту @racket[list:].

Полный список определённых в языке контрактов
можно найти в  документации к модулю @racket[racket/contract]. 

@bold{Примеры}

С помощью контрактов можно определять разнообразные специальные типы
Например, тип для натуральных чисел можно определить так
@def+int[#:eval formica-eval
  (define (natural? x)
    (and (integer? x) 
         (positive? x)))
  (is 9 natural?)
  (is -4 natural?)
  (is "abc" natural?)]
или с помощью формы @racket[define-type] и комбинатора @racket[and/c]:
 @def+int[#:eval formica-eval
  (define-type natural? 
    (and/c integer? positive?))
  (is 9 natural?)
  (is -4 natural?)
  (is "abc" natural?)]
 
 
Перечислимый тип "друг":

@def+int[#:eval formica-eval
  (define-type friend?
    "Андрей" "Маша" "Пак Хэ Донг" "Джеймс")
  (is "Маша" friend?)
  (is "Панкрат" friend?)
  (is 845 friend?)]

Индуктивный тип "список":

@def+int[#:eval formica-eval
  (define-type list? 
    null?
    (cons: Any list?))
  (is '(a b c) list?)
  (is (cons 'a (cons 'b (cons 'c '()))) list?)
  (is (cons 'a (cons 'b 'c)) list?)
  (is 42 list?)]

Индуктивный параметризованный тип: "список величин типа A":
@def+int[#:eval formica-eval
  (define-type (listof A)
    null?
    (cons: A (listof A)))
  (is '(1 2 3) (listof integer?))
  (is '(1 2 x) (listof integer?))
  (is '(a b c) (listof symbol?))]

@section[#:tag "types:ADT"]{Абстрактные типы}

@elemtag["t:ADT"]{@emph{Абстрактным типом данных}} будем называть комбинацию данных других типов (абстрактных или простых), объединённую с помощью @emph{контенерного типа}. 

Доступ к данным, заключённым в абстрактный тип, осуществляется либо с помощью функций-селекторов, либо с помощью шаблонов и механизма сопоставления с образцом.

Примером абстрактного типа является @elemref["t:pair"]{точечная пара}.

@bold{Пример 1.}

Определим с помощью формальной функции абстрактный тип, эквивалентный 
точечной паре:

@def+int[#:eval formica-eval
  (define-formal kons)
  (kons 1 2)
  (kons (kons 1 2) (kons 3 4))]

При определении формальной функции, создаётся соответствующий ей контракт:

@interaction[#:eval formica-eval
  (is (kons 1 2) kons?)
  (is (cons 1 2) kons?)
  (is 42 kons?)]

Построим конструктор для списков, создаваемых с помощью @racket[kons],
при этом, в качестве пустого списка, будем использовать символ @racket['knull]:

@def+int[#:eval formica-eval
 (define (klist . x)
   (foldr kons 'knull x))
 (klist 1 2 3 4)]

Так можно определить контракт @racket[klist?], определяющий тип для подобных списков:
@def+int[#:eval formica-eval
   (define-type klist? 
     'knull
     (kons: Any klist?))
   (is (klist 1 2 3) klist?)
   (is (klist) klist?)
   (is (kons 1 (kons 2 3)) klist?)
   (is (list 1 2 3) klist?)]

Обратите внимание на то, что определение этого типа
соответствует формальному определению алгебраического типа для списков:
@racketgrammar[#:literals (null сons:) List null (cons: Any List)]

Наконец, определим свёртку и ряд функций для обработки 
определённых нами списков:

@def+int[#:eval formica-eval
  (define/c (kfold f x0)
    (/. 'knull --> x0
        (kons h t) --> (f h (kfold f x0 t))
        x --> (error "kfold: The argument must be a klist. Given" x)))]

Отображение:

@def+int[#:eval formica-eval
  (define/c (kmap f) (kfold (∘ kons f) 'knull))
  (kmap sqr (klist 1 2 3 4 5))
  (kmap sqr (list 1 2 3 4 5))]

Сумма элементов:

@def+int[#:eval formica-eval
  (define total (kfold + 0))
  (total (klist 1 2 3 4 5))]

@bold{Пример 2.}

Определим параметризованный алгебраический тип для представления двоичного дерева 
с элементами заданного типа @racket[A].
@racketgrammar[#:literals (Empty) (Tree A) Empty (Leaf A) (Node (Tree A) (Tree A))]
В качестве конструкторов для типов @racket[Leaf] и  @racket[Node] используем формальные
функции, а единичный тип @racket[Empty] будет представлен символом @racket['Empty].

@def+int[#:eval formica-eval
  (define-formal Leaf Node)]

Контракт для типа:

@def+int[#:eval formica-eval
  (define-type (Tree A) 
    'Empty
    (Leaf: A)
    (Node: (Tree A) (Tree A)))]

Теперь мы можем создавать двоичные деревья

@defs+int[#:eval formica-eval
  [(define A (Node (Node (Leaf 5) 
                        'Empty) 
                  (Node (Node 'Empty 
                              (Leaf 6)) 
                        (Leaf 2))))
  (define B (Node (Leaf 'a) 
                         (Node (Leaf 'b) 
                               (Node (Leaf 'c)
                                     'Empty))))]
  ((Tree integer?) A)
  ((Tree symbol?) A)
  ((Tree symbol?) B)]

Определим для нашего типа функцию свёртки:

@def+int[#:eval formica-eval
  (define/c (tfold f x0 g)
    (/. 'Empty --> x0
        (Leaf x) --> (g x)
        (Node l r) --> (f (tfold f x0 g l)
                          (tfold f x0 g r))
        x --> (error "The argument must be a Tree. Given" x)))]

С её помощью можно определить ряд полезных функций для обработки деревьев:

Отображение:

@def+int[#:eval formica-eval
   (define/c (tmap f) (tfold Node 'Empty (∘ Leaf f)))
   (tmap sqr A)]

Список листьев:

@def+int[#:eval formica-eval
   (define leaves (tfold append '() list))
   (leaves A)
   (leaves B)
   (leaves '(1 2 3))]

Сумма элементов (для числовых деревьев):

@def+int[#:eval formica-eval
   (define (total t)
     (cond
       [(is t (Tree number?)) (tfold + 0 id t)]
       [else (error "total: The argument must be a (Tree number?). Given" t)]))
   (total A)
   (total B)]

Для проверки типов можно определить @elemref["t:signature"]{сигнатуру} функции:
@def+int[#:eval formica-eval
   (:: total ((Tree Num) -> Num)
     (define total (tfold + 0 id)))
   (total A)
   (total B)]