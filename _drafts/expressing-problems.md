---
layout: post
tags: [plt]
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
type shape = Circle of float | Square of float * float

let area shp = match shp with
    Circle radius -> 3.14159 *. radius *. radius
  | Square (w, h) -> width *. height
  
let vertices shp = match shp with 
    Circle _ -> infinity
  | Square (_, _) -> 4
```

So in FP, you could create a function called `volume` that computes the volume for the existing
types, and you needn't touch the above code. However, as soon as you do that, you realize you've
made a silly mistake: our shapes are *flat* so their volume is zero. Quickly, you realize you need a
three-dimensional `Cube` shape.

```ocaml
let volume shp = match shp with
    Circle _ -> 0.
  | Square _ -> 0.
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

That's a quick introduction to the problem. I think the expression problem is a perfect
[litmus test](https://en.wikipedia.org/wiki/Litmus#Uses) of sorts for programming languages, that
is, the measure of the expressive power of the language is the quality of the solutions the language
presents to expression problem.

The expression problem is theoretically solvable in any language, but to varying degrees of
elegance. In Java one must resort to using the
[visitor pattern](https://en.wikipedia.org/wiki/Visitor_pattern), and in my mind this is the most
unelegant way of going about it. I would rate the solutions on a spectrum: with the most *basic*
solution being the visitor pattern, at the other end we have something like
[polymorphic variants](http://www.math.nagoya-u.ac.jp/~garrigue/papers/fose2000.html). Type classes,
multimethods and protocols are something in between. 

Why are polymorphic variants at the very end, that is, the most elegant solutions? What makes them
better than type classes, for instance?



