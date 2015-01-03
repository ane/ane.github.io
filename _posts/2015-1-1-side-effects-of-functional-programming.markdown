---
layout: post
disqus: true
title:  "The Side-effects of Functional Programming"
date:   2015-1-2 12:00:00
tags: 
- functional-programming
- introductory
- haskell
- ocaml
---
The lack of side-effects and immutability are definitive
characteristics of functional programming: its declarative modus
expresses clearly that variables cannot be altered after being
declared. How does understanding this style affect the writing of
ordinary imperative code, after the programmer, having learned and
understood immutable code, returns to imperative programming?

<!--break-->

Let's assume a layperson, familiar to one or many imperative languages
but to no functional languages whatsoever, starts learning functional
programming, using a friendly language such as OCaml. Two things will
stand out immediately. How does one modify a variable after it has
been declared? Why can't one modify variables outside a declaration?

Understanding these concepts, immutability and the lack of
side-effects (or purity for the latter, if you will), is vital.  There
are many other foreign concepts later on that will boggle the mind,
type classes, algebraic data types, higher order functions&mdash;all
important but in this article, I will argue that just immutable values
and the lack of side-effects alone have a profound effect on how the
programmer *programs*, and those concepts will alter the way the
programmer writes and understands imperative code.

## Introduction: immutability and side-effects

This article explains side-effects and immutability for someone
who isn't that familiar with functional programming, and then goes
on to the main point, how knowledge of such features impacts writing
ordinary imperative code. Readers familiar with the topic can proceed
directly to the section titled "Effects On The Programmer".

### There Are No Variables

In functional languages, e.g., Haskell and OCaml (and the ML family),
no declared variable really is a variable, in the sense that its
value can *vary*.  They are all functions, a variable defined `let foo = 3`
is just a function that takes no parameters and returns the value
`3`. Because these languages rely on type inference, the compilers can
automatically deduce from looking at the returned type that foo is an
integer variable&mdash;that is to say, a function that *takes no
parameters* and returns an integer.

Since zero-parameter functions are functions, by the magic called
*currying*, any function with `n` parameters can be called with `n-1`
parameters, where n is greater than 0. To illustrate, the canonical
example `let plus a b = a + b` can be used in another function like
this: `let plusOne = plus 1`.  The type of plus is `int -> int -> int`,
which can be read as "take an integer, another integer, and
produce an integer".  The type of `plusOne` is `int -> int` since one
of its arguments has been fixed, calling `plus 1`
returns *a new function* with one fixed argument.

In fact, any function taking `n` arguments is actually just `n`
functions taking one argument each! Our canonical example `plusOne`
first returns a function taking the first argument `a`&mdash;which binds a
to a fixed value&mdash;and returns another function taking `b`,
whereby `a` is fixed, and returns `a + b`.

Since there really aren't any variables, just function calls, it
follows that variables cannot really be altered, *because they
aren't variables*&mdash;they are values. What implications does this have?

### So It Shall Be Declared

> In computer science, a function or expression is said to have a side
> effect if, in addition to returning a value, it also modifies some
> state or has an observable interaction with calling functions or the
> outside world. For example, a function might modify a global
> variable or static variable, modify one of its arguments, raise an
> exception, write data to a display or file, read data, or call other
> side-effecting
> functions. [Wikipedia](http://en.wikipedia.org/wiki/Side_effect_(computer_science))

In imperative programming, mutable variables are everywhere. We
declare counters such as `i++` and rely on their steady updating all
the time. We fixing an index `i` that points somewhere in memory and
with each iteration the index is adjusted to an arbitrary direction,
commonly, one step ahead: `i++`. Or maybe we just need to do something
`n` times, print a string, update the counter.

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

Because everything is *declared to be something*, a value, or a
function, or a mapping, these declarations remain steady and unchanged
throughout execution.  We fix the result of `squaredIntegers[]` to be
a result of a mapping, not the iterated consequence of an explicit action.

In rough terms, our code cannot alter anything, it can only use those
variables known at its *moment of declaration*, i.e., what knowledge is
visible to it: the declared code that precedes it. Our code has no
side-effects, it only produces more values to be evaluated further.

So if we cannot have side-effects, then how do we interact with the
outside world? How do we read files or write output to the screen?


### Schrödinger's Monad and Feline Thunks

If functions cannot have side effects, interacting with the outside
world&mdash;e.g. input and output in the von Neumann model of
computing&mdash; will be difficult. Some languages, such as OCaml and
F#, both derived from the Standard ML family of languages, which
permit side effects to a degree and it must be explicit, let you
readily exit to the outside world, Haskell encapsulates any I/O into
the IO monad, whereby any I/O actions are evaluated at runtime, hence
not having any effect at compile time, functions are read-only values
after all!

The IO encapsulation lets Haskell implement randomization, since
functions are *declared* to always return or act the same way, we must
wrap randomization into the IO monad because it tells us, among other
things, that this is to be evaluated at runtime. Values not evaluated
at compile time, or due to lazy evaluation at runtime, are known as
*thunks* in Haskell.

Because functions are declared to return the same result every time,
IO events are deemed "unsafe", and hence the encapsulation lets us
perform unsafe computations inside a safe environment&mdash;in Haskell, the
IO monad.

In Haskell, to interact with the outside world, you must encapsulate
functions into a stateful computation, which the compiler understands
have runtime-only considerations. Other languages such as OCaml aren't
as strict and let you escape into the outside world whenever, and conveniently
has a type `unit` which essentially is a value that conveys no meaning,
much like the `void` of the C world.

To summarize, immutability and the lack of real side-effects are key
features in functional languages, while some languages allow it
*explicitly* (OCaml and F#, to name a few), in general, languages such
as Haskell encourage you to think in a manner completely different to
traditional imperative programming. This paradigm is a menace: it has
profound effects on how the programmer writes code.

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
observations. For a background, I had my first steps with OCaml some
five years ago and then found Haskell in university, where it baffled
me and went over my head until I groked its beauty.  I learned it on
the side, and I later studied type theory and some principles of
programming languages, to understand how languages work at a higher
level. During that time, I did imperative programming in a variety of
languages (Python, C#, C++) to name a few at work; functional
programming and having fun with it was entirely a hobby.

Over the years, I noticed a strange change in the way I code. Before,
I mentioned the concept of "moments of declaration", e.g.,

~~~ haskell
x = 1                              -- x's moment of declaration
y = x + 3                          -- y's moment of declaration
bar = map (\z -> z ** 2) [1 .. y]  -- bar's moment of declaration
~~~

all of the values above see only anything that precedes them, nothing
that comes after. This paradigm embedded itself deeply in my mind, to
the extent that it transformed my imperative code to be written in
this style, in the "let" fashion. It also led me to discover a concept
I call *context piling*.

### Context piling

A key characteristic of this method is that *the current line you are
looking at counts*. Code readability improves tremendously, because
you can read it line-by-line and not ponder over the ever growing
context accumulated from the lines above&mdash;you see the variables, but
they are read-only definitions. This avoid what I call the *context
piling*, where code relies too much on its preceding blocks with
actual variables and mutated state.

Of course, functional languages also have contexts, where the values you are
looking at have some meaning defined above, but in functional programming,
the key difference is that **the context is always defined before**. The lack of side
effects is also subtly illustrated in the snippet above: `x` and `y` cannot
touch `bar`, and `bar`s semantics can be easily deduced by looking *up*.

In an imperative language, we may define a variable and assign values
to it, and over the course of the computation it may take new values,
one will always be looking in *two* directions. This leads to increased code entropy.

Functional programming affected my imperative object-oriented code in
this many striking fashions:

1. Avoid side effects, prefer functions that take parameters and return values,
  **especially** in OOP, no byrefs[^1]!
2. Minimize stateful objects, use objects as containers and
  for encapsulation
3. If you need stateful objects, make it explicit and easy to understand
4. Use interfaces a bit like type classes, multiple inheritance *of
interfaces* is OK
5. Avoid context piling by let defining new variables with visible and clear moments of
  declaration
6. Avoid `object.DoSomething()` 
7. Rely on lazy evaluation and generators (`yield` in C# or Python)

I attribute all of these changes to learning and understanding
functional programming. Point **1** is obvious: when functions take
parameters and return values, we fix a context for them, no black
magic and altering the outside world will happen. Points **2-3** are
due to structures and record types present in functional
programming. Objects are less about them doing things, more about them
being used as container and encapsulating similar concepts. I believe
this was the original intent of objects in Simula. Point **4** brings
us to interfaces, they can be used to implement a type class system
that is *kind* of like type classes, except you inherit and implement
instead of relying on structural typing. Point **5** is the effect of
immutability and the lack of side effects, and point **6** reinforces
the first notion of having objects be simple containers for
information.  Lastly, **7** is about lazy evaluation and generators,
these are very fun concepts that can be used to make code that would
otherwise be inefficient to use the trick of laziness to become very
efficient.


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
code quality is difficult to judge. I will follow up on this in an
upcoming post where I will discuss code entropy and code scalability,
and how the composability of functional programming may be used to fix
this. For now, to make a valid assertion on code quality I need
more data.

[^1]: No mutable parameters, e.g., `out parameter` in C#
