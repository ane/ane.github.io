---
layout: post
disqus: true
title:  "The Side-effects of Functional Programming"
description: "How does learning functional programming affect the way you write imperative code? From a perspective of traditional, imperative programming, functional programming seems strange and counterintuitive. Yet there is beauty in its strangeness, though it might be difficult to see at a glance. Once you see it, everything changes."
date:   2015-1-10
tags: 
- fp
- oop
---

Functional programming forces programmers to think differently. It
requires programmers to conceptualize programs as declarations of
certain assertions, while imperative programming makes the programmer
a foreman of a control flow. 

The fact that everything is an expression, the objective of a function
is *always* to return a value, iterations are *mappings* from a source
to a target, `null` values are (usually) safely handled at compile
time, pattern matching lets functions test their input value extremely
tersely; all of these seem counterintuitive from the world of
imperative programming yet are tremendously practical concepts.

> "In mathematics you don't understand things. You just get used to them." &mdash;John von Neumann

While these concepts seem strange and esoteric, and while they take
time to learn and understand, they aren't ultimately difficult.

This post isn't about learning them, though, or what they are. This
post is about what happens *after you learn them*.

Can functional patterns creep into imperative code? Yes they can, in
fact, it will have tremendous implications on the way one writes
imperative code.

### So It Shall Be Declared

> In computer science, a function or expression is said to have a side
> effect if, in addition to returning a value, it also modifies some
> state or has an observable interaction with calling functions or the
> outside world. For example, a function might modify a global
> variable or static variable, modify one of its arguments, raise an
> exception, write data to a display or file, read data, or call other
> side-effecting
> functions. ([Wikipedia](http://en.wikipedia.org/wiki/Side_effect_(computer_science)))

In imperative programming, mutable variables are everywhere. We
declare counters such as `i++` and rely on their steady updating, we
fix an index `i` that points somewhere in memory and with each
iteration the index is adjusted to an arbitrary direction, commonly,
one step ahead, or maybe we just need to do something `n` times, to
print a string, or to count sums.

Loops in functional programming work in a different way: they are
mappings, from one collection to another, when lists of integers are
morphed into a list of squares, or they are summed into a total.  The
principle of declaration is fundamental. Functional programmers *say*
that this result squared list is the application of a function
`square` on each of the members of another list, imperative
programming has us create `n` squares and insert them into a list at
the `i`th position. In functional programming, the upper limit `n` is
trivial, in imperative programming it is necessary.

Doing something `n` times in functional programming is tricky, because
the pattern is sometimes invalid. Any loop is fundamentally a
*mapping* from one source to another; a mapping without a target is
nonsensical. A common trick around this is to wrap the action in
something that conveys no value (e.g. `unit` in OCaml) or simply
discard the results, again, no `i++` is necessary.

### Schrödinger's Monad and Feline Thunks

Most functional languages employ a concept of *immutability*. This
means that variables cannot change after declaration. In imperative
programming this is common: `i++` above is a great example of
this. But in many functional languages doing the following is simply
not allowed.

~~~haskell
foo = 1
foo = 2
~~~

While Haskell is the only language that categorically disallows any
mutation (though possible using the `ST` construct), this is invalid
in a lot of languages.

The notion immutability imparts a strong sense of having to really
think when variables ought to be changed. If variables are read-only,
and everything is an expression, the idea of changing an abstract
state veers towards composotion of results. This means that instead of
having parts of the program modify a shared state, the state is
constructed by joining different computations in a pipeline.

This pattern is sometimes silly, though; immutable data structures are
awkward and *in most cases* inefficient compared to their imperative
variants, though exceptions *do* occur. On the other hand,
immutability is fantastic for parallellization. Software transactional
memory is trivial to implement in functional languages.

The lack of side-effects is really only a feature of Haskell. Most
functional languages allow mutation, sometimes explicitly; purity
alone doesn't impact the programmer as much as immutability
does. Local immutability forces one to program differently: more about
values, less about manipulating memory.


## Effects On The Programmer

Functional code has to be written in a manner drastically different
from imperative programming, so much so that one of the biggest
burdens for a new programmer learning functional programming often
stumbles on the basic blocks of that paradigm.

For our though experiment, let's again assume an experienced
programmer but a novice in functional programming, learns functional
programming and progresses to an intermediate level. Our programmer
then goes back to writing imperative code.

I can predict what happens based on my experiences and
observations. I learnt FP almost by accident, by stumbling on the then-new
F# language via a typo in a C#-related Google search, and trying it out.
"Hey," I thought, "this is interesting!". I had the chance to take some
courses on FP in university and learnt quite a deal more about it, though
initially Haskell went over my head in a *swoosh*.

Since then, I've had some chance to employ FP professionally (Erlang and
some F#), most of it has been left to hobby projects, and most of that has been
Haskell.

Over the years, while doing FP mostly on the side, I noticed a fundamental
change in the way I coded. But before I go any further on that, let us go back
to the concept of "moments of declaration", e.g.[^2], 

~~~haskell
x = 1                              -- x's moment of declaration
y = x + 3                          -- y's moment of declaration
bar = map (\z -> z * z) [1 .. y]   -- bar's moment of declaration
~~~

Here, all of the expressions above see only the values that precede
them, and everything that comes after them is invisible. This paradigm
embedded itself deeply in my mind, to the extent that it transformed
my imperative code to be written in this style, in the "let"
fashion. It also led me to discover a concept I call *context
piling*.

### Context piling

Lines in computer programs are surrounded by *context*: their meaning
can be deduced by looking at the surrounding lines.  This is the case
with the little Haskell snippet above: the declaration of `x` has no
context, `y`'s context contains `x`, and `bar` has `y` and by
extension also `x` in its context.

The readability of code is *all about parsing the context*. There are
two types of context: *forward* context, where the state of a variable
is altered past its declaration, and *backward* context, where state
at any given line is constructed from code preceding it. Imperative
languages often contain both forward and backward context, but in
functional programming code is declared based on backward context *only*.

This significant difference is why the correctness of functional code
is easy to verify. It's not just the type system, it's also the way
programs are built, by extending a context in a linear fashion,
instead of zig-zagging here and there, modifying state at a whim.

In an imperative language, we may define a variable and assign values
to it, and over the course of the computation it may take new values,
one will always be looking in *two* directions. This leads to what I
call *context piling*, the buildup of context that ultimately leads to
code entropy.

This isn't just about code readability, it extends to
architecture. Functional code composes well. One can use the type
system present in many functional languages to define abstractly what
code modules do. Functions can be seen as opaque implementors of this
defined *program algebra*, as long as code conforms to this algebra,
it is easy to layer functions over each other to create a composable
architecture. For more about this, someone wrote a great blog post
about how functional programming affects software architecture:
[How does functional programming affect the structure of your code?](https://lorgonblog.wordpress.com/2008/09/22/how-does-functional-programming-affect-the-structure-of-your-code/). See
also
[this Stack Overflow question about functional programming architecture](http://stackoverflow.com/questions/89212/functional-programming-architecture).

## New Paradigms

During the course of learning functional programming, I noticed a lot
of changes in how I wrote imperative code. This list is not
exhaustive:

### 1. Minimize or avoid code with opaque side effects

Instead of writing functions or methods that mutate their parameters,
I prefer functions return values. Think with values, not with memory
addresses. Byrefs[^1] are discouraged. *This may have performance
implications in some languages*.

### 2. Minimize stateful and complex objects, use objects as containers

Objects are less about them doing things, more about them being used
as containers and for encapsulating closely related
variables&mdash;something akin to micromodules at the type level. I
believe this was the original intent of objects in Simula.

### 3. If you need stateful objects, make it explicit and easy to understand

`database.Erase()` is probably a lot easier to understand than
`tomato.Explode()` though slightly less fun. This idea has a lot to do
with naming things&mdash;a significant challenge in programming.

### 4. Type classing, sort of: inherit interfaces, not classes

[Type classes](http://en.wikipedia.org/wiki/Type_class) are a powerful
way to implement ad hoc polymorphism, and though interfaces operate on
values and not on types, interfaces allow a similar fine-grained
control on program logic.

Class inheritance and multiple *class* inheritance have disastrous consequences. Not only do objects become opaque and hideously complicated, such designs are prone to being over-engineered.

Although interfaces are
[vastly inferior](http://cstheory.stackexchange.com/questions/9731/type-classes-vs-object-interfaces)
to type classes, they both share the idea what can be most accurately
described as the lowest form of contract progamming. Having classes
implement interfaces&mdash;OOPs type classes&mdash;will make code safer, easier to understand, and
easier to deconstruct.

### 5. Define new variables, rely on backward context, avoid forward context

Declaring new variables in the functional style creates code that is
easy to understand. When you declare a new variable based on backward
context, you invalidate the backward context and thus your code is
more about the *line context* than any other context.

### 6. Static typing if you can

Because nobody likes dynamic typing. It only leads to awful code. A
bonus if the typing is strong, i.e., you cannot assign `"cat"` to an
`int`, which you can in C (though modern compilers will produce a
warning).

### 7. Lazy evaluation is your friend

Generators like `yield` in C# or Python are a fantastic way of making
code that would otherwise be ineffiecnt become lean and
efficient. Lazy evaluation may not be as pervasive in those languages
as it is in Haskell, where everything is lazily evaluated, but where
it can be used, it can be used to a great effect.

---

I attribute most of these changes to learning functional
programming. These paradigms aren't unlearnable without learning
functional programming, on the contrary, I think some of these are a
result of careful scrutiny and focus on producing good code, avoiding
bad patterns and anti-patterns.


## Effects on quality

I'm not wise enough to comment on whether these changes constitute an
*improvement* on code quality. I have only noted the changes. Their
effect on the quality of my code is hard to evaluate. I've noticed a
change in the workflow and the way I debug things, and also the kinds
of programming environments in which this style works better.

The style I've gravitated to, in imperative programming, thrives in a
statically and strongly typed language, in dynamic and weakly typed
languages it is prone to requiring breakpoints.  This is easy to
explain. A coding style with lots of let statements has lots of
assignments and function calls, the return values are explicitly bound
to a certain type, a type checking compiler will spot any errors; the
only errors you may encounter are semantic, that is, the value you
might be expecting is semantically nonsensical&mdash;the square of an
integer turns out to be -4, or something equally silly&mdash;but is
always correct in terms of typing. Semantic bugs are *much* easier to
correct&mdash;and debug&mdash;than undefined behaviour.

In a dynamic language, where variables can arbitrarily change their
type, e.g. JavaScript, Python, or even C, this isn't as easy, as the
compiler won't be there to do type checking. If anything, I've learned
that dynamic typing is idiotic, and languages that are designed with
dynamic weak typing are terrible. Thankfully, new languages seem to be
following the static typing school of thought (Go, Rust, Swing, Nim).

# Conclusion

Functional programming imposes a new paradigm of programming on the
programmer, and this style has considerable side-effects on the way
our programmer writes imperative code. In this article, I outlined
what these changes were&mdash;based on my experiences&mdash;I await
the reactions of others to see whether my observations were true to
them as well. The side-effects I mentioned more or less resulted in
imperative code borrowing the good parts of functional programming and
throwing away the bad parts of imperative programming.

It is much harder to judge if these changes led to improvements, since
code quality is difficult to evaluate. While functional code and its
expressiveness tends to be counterintuitive in small programs, in
which short imperative programs often make more sense, the functional
style most likely scales better in larger programs.

For now though, I need more data to make an assertion if such a style
used in imperative programming affects code quality in any way.

[^1]: No mutable parameters, e.g., `out parameter` in C#
[^2]: I avoided `map (**) [...]` for clarity.
