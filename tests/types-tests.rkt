#lang formica
(require "test-utils.rkt")

; simple contracts
(:: f ((between/c -1 1) -> Num)
  (define (f x) (+ 7 x)))

(test-case 
 "simple-contracts"
 (check-equal? (f 0)  7)
 (check-exn exn:fail:contract:blame? (λ () (f 2)))
 (check-exn exn:fail:contract:arity? (λ () (f 2 3))))


;"optional arguments"
(:: range (Real (? Real Real) -> (list: Real ..))
  (define/. range
    n --> (range 1 n)
    a b --> (range a b 1)
    a b s --> (let loop ([i a] [res '()])
                (if (< (- b i (- s)) s)
                    (reverse res)
                    (loop (+ i s) (cons i res))))))

(test-case 
 "optional-arguments"
 (check-equal? (range 2)  '(1 2))
 (check-equal? (range 2 4)  '(2 3 4))
 (check-equal? (range -1 1 1/2)  '(-1 -1/2 0 1/2 1))
 (check-exn exn:fail:contract:blame? (λ () (range 1+2i)))
 (check-exn exn:fail:contract:arity? (λ () (range 1 2 3 4))))

; "polymorphic types"
(:: dup ((A -> A) -> (A -> A))
  (define (dup f)
    (compose f f)))

(test-case 
 "polymorphic-types"
 (check-equal? ((dup (+ 2)) 4) 8)
 (check-equal? (((dup dup) (+ 2)) 4) 12))

(:: comp  ((B -> C) (A A .. -> B) -> (A A .. -> C))
  (define (comp f g)
    (λ x (f (apply g x)))))

(test-case 
 "polymorphic-types"
 (check-equal? ((comp length append) '(1 2 3) '(x y z))  6)
 (check-equal? ((comp sqr -) 1 2 3)  16))

(:: fold ((A B -> B) B (list: A ..) -> B)
  (define/c (fold f x0)
    (/. '() --> x0
        (cons h t) --> (f h (fold f x0 t)))))

(:: map ((A -> B) (list: A ..) -> (list: B ..))
  (define/c (map f) (fold (∘ cons f) '())))

(test-case 
 "polymorphic-types"
 (check-equal? (fold ($ 'f 2) 'x0 '(1 2 3))  '(f 1 (f 2 (f 3 x0))))
 (check-equal? (fold + 0 '(1 2 3))  6)
 (check-equal? (map ($ f 1) '(a b c))  '((f a) (f b) (f c)))
 (check-equal? (map sqr '(1 2 3))  '(1 4 9))
 (check-equal? (map (map (+ 1)) '((1 2) (3)))  '((2 3) (4)))
 (check-exn exn:fail:contract:blame? (λ () (map 5 '(2 3 4))))
 (check-exn exn:fail:contract:blame? (λ () (map sqr 2)))
 ; Using parametric contracts hides the arity information
 ; making functions nullary and variadic, so it is impossible to
 ; get the real function's arity. In the following case no
 ; exception is raised and curried function is returned.
 #;(check-exn exn:fail:contract:arity? (λ () (map sqr '(1 2 3) '(3 4 5)))))

; abstract-types
(define-type T 
  (</c 2)
  (between/c 4 8))

(:: g [Num T .. -> Num]
  (define/. g
    x --> (* 2 x)
    x y ... --> (+ 4 x)))



; "list"
(define-type (List a)
  null?
  (cons: a (List a)))

(:: f1 ((List Num) -> Num)
  (define (f1 x) (apply + x)))

(define-formal Leaf Node)
(define Empty 'Empty)

(define-type (Tree A)
  'Empty
  (Leaf: A)
  (Node: (Tree A) (Tree A)))

(define tA (Node (Node (Leaf 5)
                       Empty)
                 (Node (Node Empty
                             (Leaf 6))
                       (Leaf 2))))
(define tB (Node (Leaf 'a)
                 (Node (Leaf 'b)
                       (Node (Leaf 'c)
                             Empty))))

(define/c (tfold f x0 g)
  (/. 'Empty --> x0
      (Leaf x) --> (g x)
      (Node l r) --> (f (tfold f x0 g l)
                        (tfold f x0 g r))
      x --> (error "The argument must be a Tree. Given" x)))

(:: total (-> (Tree Num) Num)
  (define total (tfold + 0 id)))

(test-case 
 "abstract types"
 (check-equal? (g 6 4)  10)
 (check-equal? (g 6 4 5)  10)
 (check-exn exn:fail:contract:blame? (λ () (g 6 5 3)))
 
 (check-equal? (f1 '(1 2 3))  6)
 (check-equal? ((Tree Int) tA) #t)
 (check-equal? (not ((Tree Sym) tA)) #t)
 (check-equal? ((Tree Sym) tB) #t)
 (check-equal? (total tA)  13)
 
 (check-exn exn:fail:contract:blame? (λ () (f1 4)))
 (check-exn exn:fail:contract:blame? (λ () (f1 '(1 2 x))))
 (check-exn exn:fail:contract:blame? (λ () (total tB))))


(:: accum ((B A -> A) A (Num -> B) Num Num -> A)
  (define (accum f x0 g a b)
    (let F ([i a])
      (if (> i b)
          x0
          (f (g i) (F (+ i 1)))))))

(:: sum ((Num -> Num) Num Num -> Num)
  (define sum (accum + 0)))

(:: sumsqr (Num Num -> Num)
  (define/c (sumsqr) (sum sqr)))

(:: table ((Num -> A) Num Num -> (list: A ..))
  (define table (accum cons '())))

(test-case
   "curring"
   (check-equal? (accum cons '() (cons 'a) 1 3)  '((a . 1) (a . 2) (a . 3)))
   (check-equal? (sum sqr 1 3)  14)
   (check-equal? (sumsqr 1 3)  14)
   (check-equal? (table sqr 1 3)  '(1 4 9)))


; "mutual satisfaction"
(:: Sqr (Num -> Num)
  (define (Sqr x)
    (* x x)))

(:: h ((A -> B) A -> B)
  (define (h g x)
    (g x)))

(test-case
 "mutual satisfaction"
 (check-equal? (h Sqr 5)  25))