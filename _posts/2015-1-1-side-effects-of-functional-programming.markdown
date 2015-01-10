---
layout: post
disqus: true
title:  "The Side-effects of Functional Programming"
description: "How does learning functional programming affect the way you write imperative code? From a perspective of traditional, imperative programming, functional programming seems strange and counterintuitive. Yet there is beauty in its strangeness, though it might be difficult to see at a glance. Once you see it, everything changes."
date:   2015-1-10
tags: 
- functional-programming
- introductory
- haskell
- ocaml
---

The lack of side-effects and immutability are definitive
characteristics of functional programming: its declarative paradigm
expresses clearly that variables cannot be altered after their
declaration. How does understanding this rule affect the writing of
ordinary imperative code, after the programmer, having learned and
understood immutable code, returns to imperative programming?

<!--break-->

What happens when a layperson familiar with one or many imperative
languages but not with functional programming, starts learning it?
What are the biggest barriers of entry?

If we disregard matters of syntax, the first thing that will stand out
will be *immutability*. How does one modify a variable after it has
been declared? Why can't one modify variables after they've been declared?

Understanding the concept of immutabilityis vital.  There are many
other foreign concepts later on that will boggle the mind, type
classes, algebraic data types, higher order functions&mdash;all
important, and vital as well&mdash;in this article, I will argue that
just the concept of immutability has a profound effect on how the
programmer *programs*, and it will alter the way the programmer writes
and understands imperative code.

### There Are No Variables

In functional languages, e.g., Haskell and OCaml (and the ML family),
no declared variable really is a variable, in the sense that its value
can *vary*. They are all functions, a variable defined `let foo =
3`&mdash;an ordinary declaration&mdash; is just a function that takes
no parameters and returns the value `3`. Because these languages rely
on type inference, the compilers can automatically deduce from looking
at the returned type that foo is an integer variable&mdash;that is to
say, a function that *takes no parameters* and returns an integer.

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
declare counters such as `i++` and rely on their steady updating, we
fix an index `i` that points somewhere in memory and with each
iteration the index is adjusted to an arbitrary direction, commonly,
one step ahead, or maybe we just need to do something `n` times, print
a string, or count sums.

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
perform unsafe computations inside a safe environment&mdash;in
Haskell, the IO monad.

In Haskell, to interact with the outside world, you must encapsulate
functions into a stateful computation, which the compiler understands
have runtime-only considerations. Other languages such as OCaml aren't
as strict and let you escape into the outside world whenever, and
conveniently has a type `unit` which essentially is a value that
conveys no meaning, much like the `void` of the C world.

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
I mentioned the concept of "moments of declaration", e.g.[^2],

~~~ haskell
x = 1                              -- x's moment of declaration
y = x + 3                          -- y's moment of declaration
bar = map (\z -> z * z) [1 .. y]  -- bar's moment of declaration
~~~

all of the values above see only anything that precedes them, nothing
that comes after. This paradigm embedded itself deeply in my mind, to
the extent that it transformed my imperative code to be written in
this style, in the "let" fashion. It also led me to discover a concept
I call *context piling*.

### Context piling

Lines in computer programs tend to have a *context*, which means that
to properly understand the content of a line, one must look at the
lines surrounding it.  This is the case with the little Haskell
snippet above: the declaration of `x` has no context, `y`'s context
contains `x`, and `bar` has `y` and by extension also `x` in its
context.

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
I prefer functions return values. Any sort of byrefs[^1] or passing
references is absolutely forbidden. *This may have performance implications*.

### 2. Minimize stateful and complex objects, use objects as containers

Objects are less about them doing things, more about them being used
as container and encapsulating similar concepts. I believe this was
the original intent of objects in Simula.

### 3. If you need stateful objects, make it explicit and easy to understand

`database.Erase()` is probably a lot easier to understand than
`tomato.Explode()` though slightly less fun. This idea has a lot to do
with naming things, a significant challenge in programming.

### 4. Type classing, sort of: inherit interfaces, not classes

[Type classes](http://en.wikipedia.org/wiki/Type_class) are a powerful
way to implement ad hoc polymorphism, and though interfaces operate on
values and not on types, interface allow a similar fine-grained
control on program logic.

Class inheritance and multiple class inheritance bring only pain and
regret, and code using them is prone to overengineering and
unnecessary code entropy. Although interfaces are
[vastly inferior](http://cstheory.stackexchange.com/questions/9731/type-classes-vs-object-interfaces)
to type classes, having classes implement interfaces (or abstract
classes, the difference is minor) will make code safer, easier to
understand, and easier to deconstruct.

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
