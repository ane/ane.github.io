---
layout: post
disqus: true
date: 2016-01-08
category: OCaml
title: The expression problem as a litmus test 
---

The [expression problem](https://en.wikipedia.org/wiki/Expression_problem) is a famous problem in
programming languages. 

> "The Expression Problem is a new name for an old problem. The goal is to define a datatype by
> cases, where one can add new cases to the datatype and new functions over the datatype, without		
> recompiling existing code, and while retaining static type safety (e.g., no casts)."

Using *interfaces* (like in Java) as the datatype example, the problem simply asks whether it is
possible to derive the interface and add new methods to the interface, without having to recompile
existing code or to resort to using casts.

Obviously, in a OOP language it's easy to derive interfaces, but the problem uncovers the rigidity
of the type system: you can't modify (i.e. extend) the interface, because you have to modify all the
classes classes that implement the interface.

Conversely, in functional programming languages, adding new methods operating on the interface is
easy. Consider the canonical OCaml example:

```ocaml
type shape = Circle of float | Rectangle of float * float

let area shp = match shp with
    Circle radius -> 3.14159 *. radius *. radius
  | Rectangle (width, height) -> width *. height
  
let vertices shp = match shp with 
    Circle _ -> infinity
  | Rectangle (_, _) -> 4
``` 

So in FP, you could create a function called `volume` that computes the volume for the existing
types, and you needn't touch the above code. However, as soon as you do that, you realize you've
made a silly mistake: our shapes are *flat* so their volume is zero. Quickly, you realize you need a
three-dimensional `Cube` shape.

```ocaml
let volume shp = match shp with
    Circle _ -> 0.
  | Rectangle _ -> 0.
  | Cube s   -> a *. a *. a        (* Cube isn't defined *)
```

Oops!

Here's the onion: to get the `Cube` working, you'll have to modify the existing code in two places:
the definition of `shape` *and* both methods `area` and `vertices`.

In OOP, this isn't the case, since you can just derive the new `IShape` interface and be done with
it, but the problem arises when you're adding the `volume` function, because you need to modify
`IShape`, and thus every class that derives it.

In FP, adding new functions over the datatypes is easy, but adding new cases to the datatype is
tricky, because you have to modify existing functions. In OOP, adding new functions over the
datatype is hard, because you need to modify each implementation; adding new cases to the datatype
is easy, since all you need to do is derive the interface. FP has invented a multitude of ways to
deal with this problem, ranging from type classes, traits to protocols; OOP usually solves with
either patterns or open classes. Ruby's
[refinements](http://devblog.avdi.org/2015/05/20/so-whats-the-deal-with-ruby-refinements-anyway/)
can be used for this purpose as well.

## Polymorphic variants

That's a quick introduction to the problem. I think the expression problem is a perfect
[litmus test](https://en.wikipedia.org/wiki/Litmus#Uses) of sorts for programming languages, that
is, the measure of the expressive power of the language is the quality of the solutions the language
presents to the expression problem.

The expression problem is theoretically solvable in any language, but to varying degrees of
elegance. In Java one must resort to using the
[visitor pattern](https://en.wikipedia.org/wiki/Visitor_pattern), and in my mind this is the most
inelegant way of going about it. I would rate the solutions on a spectrum: with the most *basic*
solution being the visitor pattern, at the other end we have something like
[polymorphic variants](http://www.math.nagoya-u.ac.jp/~garrigue/papers/fose2000.html) and type
classes. Multimethods and protocols are somewhere in between.

When you compare polymorphic variants of OCaml with Haskell's type classes, there's a marked
difference in brevity. Polymorphic variants are succincter than type classes but cannot provide the
same level of type safety.

```ocaml
type shape = [ `Circle of float | `Rectangle of float * float ]

let area shp = match shp with
    `Circle radius -> radius *. radius *. 3.14159
  | `Rectangle (w, h) -> w *. h

let vertices shp = match shp with
    `Circle radius -> infinity
  | `Rectangle (w, h) -> 4.
```

Not too different from the above declaration, the type is surrounded with brackets and the types are
preceded with backticks. Recreating the volume function is easy.

```ocaml
let volume shp = match shp with
    `Circle _ -> 0.
  | `Rectangle _ -> 0.
  | `Cube a -> a *. a *. a
```

So now I've extended the `shape` type with another type `Cube`, and I haven't touched `vertices` and
`area` functions. The `volume` function can be done even more succinctly:

```ocaml
let short_volume shp = match shp with
    (* no volume in two dimensions! *)
    #shape -> 0.
  | `Cube a -> a *. a *. a
```

It is also possible to constrain the polymorphic variants:

```ocaml
let flatten shp = match shp with
    #shape as x -> x
  | `Cube a -> `Rectangle a
```

The type of this function is
``[ < `Circle of float | `Cube of float | `Rectangle of float * float ] -> [> shape]``. The
`[< A | B]` means a closed type: it can be only `A` or `B`, but nothing else, and `[> Foo]` means
"Foo or something else". So the `flatten` function accepts `Circle`, `Rectangle` or `Cube` and
returns a `shape` (or possibly something else). Trying to run ``flatten (`Sphere 4)`` produces a
type error:

```
# flatten (`Sphere 3);;
Characters 8-19:
  flatten (`Sphere 3);;
          ^^^^^^^^^^^
Error: This expression has type [> `Sphere of int ]
       but an expression was expected of type
         [< `Circle of float
          | `Cube of float * float
          | `Rectangle of float * float ]
       The second variant type does not allow tag(s) `Sphere
```

However, the following code compiles:

```ocaml
type polytope = [ shape | `Cube | `Octahedron ]

let frobnicate pt =
  let flattened = flatten pt in
  match flattened with
    #shape -> "Already flaaat!"
  | `Octagon -> "Eight coorneeeeerss"
```

The compiles, although we didn't tell the compiler that `flatten` does not return
``Octagon``. There are two ways to fix this: either explicitly annotate `pt` to be of type
`polytope`, which produces this error:

```
Error: This expression has type polytope
       but an expression was expected of type
         [< `Circle of float | `Cube of float | `Rectangle of float * float ]
       The second variant type does not allow tag(s) `Octahedron
```

It is possible to further constrain the type with type annotations. We can make sure that the
`flatten` function returns *only* flat shapes: 

```ocaml
let safe_flatten shp : [< shape] = match shp with
    #shape as x -> x
  | `Cube a -> `Rectangle a
  | `Sphere r -> `Circle r
```

This produces the error:

```
Error: This pattern matches values of type [? `Octagon ]
       but a pattern was expected which matches values of type shape
       The second variant type does not allow tag(s) `Octagon
```

## Not a silver bullet

Unfortunately, polymorphic variants are *problematic*. The problem with polymorphic variants is you
quickly reach an absurd level of complexity and are forced to use annotations or subtyping to ensure
maximal type safety. So although polymorphic variants are *nice*, and they do let us solve the
expression problem, they're an unsteady compromise between type safety and brevity. You can
certainly make elegant abstractions with them but they get unwieldy quickly. They aren't as
efficient compared to regular variants either.

So what are the options? In OCaml 4.02, you can use *extensible variant types*: 

```ocaml
type boring_shape = ..
type boring_shape += Circle of float | Square of float
                                                   
let boring_area shp = match shp with
    Circle r -> r *. r *. 3.14159
  | Square a -> a *. a
  | _ -> 0.

type boring_shape += Rectangle of float * float
let radical_area shp = match shp with
    Circle _ as c -> boring_area c
  | Square _ as s -> boring_area s
  | Rectangle (w, h) -> w *. h
  | _ -> 0.
``` 

An extensible variant is defined using `..`, and extension is done with the `+=` operator. The
caveat is that you must handle the default `_` case in pattern matching. Extensible variants are
another neat trick for solving the expression problem.

## A measure of expressive power

The expression problem is a great litmus test that measures the expressive power of a
programming language. The actual measurement of the test can be either the brevity of the code or
its type safety. The solutions range from the clumsy Visitor Pattern in Java to polymorphic and
extensible variants in OCaml and to type classes in Haskell. Clojure and Elixir have
[protocols](http://clojure.org/protocols) that are both quite nice but not so type-safe since both
are dynamically typed languages. What is more, since the expression problem is also about type
safety, then strictly speaking the problem isn't valid in a dynamic language. Any Lisper knows that
Lisps *are* super expressive anyway.





