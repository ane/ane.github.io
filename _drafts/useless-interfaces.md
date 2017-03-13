---
title: Useless interfaces, or, trait distillation
layout: post
date: 2017-03-13T00:00:00
tags:
  - programming
---

A feature that often irks me in object-oriented code is the prevalence of useless
interfaces. Interface isn't meant literally here: this applies to traits of Rust/Scala and protocols
of Clojure as well.

The advice of *planning for the interface* is just and solid, but people tend to go to great lengths
of following this to the extreme. It is not uncommon to see people design a module or class by
defining its interface first, with an actual implementation following later. 

One eagerly designs an interface as follows:

```scala
trait Mediator {
  def validate(r: Request): Boolean
  def postpone(r: Request): Postponed[Request]
  def frobnicate(a: Request, b: Request): Frobnicated[Request]
}
```

Then, the implementation, in a class called `MainMediator` or `DefaultMediator`, in a separate
directory, implements the `Mediator` interface:

```scala
class MediatorImpl extends Mediator {
  def validate(r: Request): Boolean = { ... }
  def postpone(r: Request, d: Duration): Postponed[Request] = { ... }
  def frobnicate(a: Request, b: Request): Frobnicated[Request] = { ... }
}
```

Dependents of the `Mediator` trait then naturally get their dependency provided with a constructor
argument:

```scala
class Resequencer(m: Mediator, c: Clock) {
  def resequence(requests: Seq[Request]): Seq[Postponed[Request]] = 
    requests map { r => m.postpone(r, c.randomDelay()) }
}

val m = Mediator()
val c = Clock()
val foo = new Foo(m)
```

This pattern is older than the sun, and has been a characteristic of object-oriented programming
ever since. Fundamentally, it is alright to separate implementation from specification, but where it
goes wrong is the *overuse* of this paradigm.

This is dependency injection on the toilet. There is no fundamental reason why a class or module
like `Mediator` warrant an extra interface *when it is likely that you will never provide a second
implementation*. 

At a glance, Guy Steele's influential *plan for growth* idea from his "Growing a Language" talk
seems to contradict what I just said. Shouldn't defining an interface help us plan for future,
secondary implementations of the `Mediator`? Perhaps a different kind of a `Mediator`? 

Removing the `Mediator` trait and simply renaming its only implementation will still keep the code
working, with the benefit that there are fewer lines of code now, and it isn't any harder to extend.

This is actually more in line with Steele's idea. It doesn't say anywhere a trait or interface cannot be
*distilled* from base implementations. In other words, when our intuition says to plan for
repetition -- patterns -- we should *identify* them. The Gang of Four book was never a recipe book
for building great programs. It was a catalog! They observed several kinds of large-scale systems
and programs and extracted repetetive behaviours in the code, patterns. They never said that to do
things right, one ought to use the visitor pattern, or that not using it would lead to bad programs.

So, the wise coder thinks, this behaviour I have specificed may be repetitive, let me *first* create
a construct that lets me share the repetition (an interface), and then proceed with the
implementation. This is fine if the actual code is known to be repeated, but by seeing interfaces as
a hammer and every bit of code as a nail, you will soon bury yourself in pointless dependency
injection scenarios.

It may be just as easy to first create a base implementation and once you must duplicate its
behaviour, only *then* create the abstract implementation. You might actually need to spend *less*
total time wiring up the interface, since you observed the repetition. Creating an abstract
implementation first always involves a deal of speculation and this is not reliable.

Of course, all of is much easier in functional programming where you can provide a method just by passing a
higher-order function.

```scala
class Foo(postponer: Request => Postponed[Request], delayer: =>Duration) {
  def resequence(requests: Seq[Request]): Seq[Postponed[Request]] = 
    requests map { r => postponer(r, delayer()) }
}

// ...
val m = Mediator()
val c = Clock()
val foo = new Foo(m.postpone, c.randomDelay)
```

One sees that a higher-order function like the above can be just as well represented by a trait with
a single method. If you only need that method, you should depend only on that. With a structural
type system it is easy to decompose types. An alternative is to stack traits, and in languages like
Scala this is fairly easy.

```scala
trait Validator {
  def validate(r: Request): Boolean
}

trait Postponer {
  def postpone(r: Request): Postponed[Request]
}

trait Frobnicator {
  def frobnicate(a: Request, b: Request): Frobnicated[Request]
}

trait Mediator extends Validator with Postponer with Frobnicator
```

Now you can treat `Mediator` as a `Validator` without caring about the other traits. If `Foo` needs
only `validate`, it can easily depend on just the `Validator` aspect of the `Mediator` trait. This
becomes easier to test: now you need to mock only the `Validator` trait.
