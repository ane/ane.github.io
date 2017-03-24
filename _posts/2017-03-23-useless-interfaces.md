---
title: Useless interfaces 
layout: post
date: 2017-03-23T00:00:00
disqus: true
tags:
  - programming
---

A feature that often irks me in object-oriented code is the prevalence of useless
interfaces. Interface isn't meant literally here: this applies to traits of Rust/Scala and protocols
of Clojure as well.

The advice of *planning for the interface* is just and solid, but people tend to follow this tip to
the extreme. It is not uncommon to see people design a module or class by defining its interface
first, with an actual implementation following later.

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

This pattern is older than the sun, and has been a characteristic of modern, inheritance-based
object-oriented programming for ages. Fundamentally, it is alright to separate implementation from
specification, but where it goes wrong is the *overuse* of this paradigm, or when this separation is
superfluous.

This separation is superfluous when it serves no purpose. You could as well call it dependency
injection on the toilet. There is no fundamental reason why a class or module like `Mediator`
warrant an extra interface *when it is likely that you will never provide a second implementation*.

At a glance, Guy Steele's influential *plan for growth* idea from his "Growing a Language" talk
seems to contradict what I just said. Shouldn't defining an interface help us plan for future,
secondary implementations of the `Mediator`? Perhaps a different kind of a `Mediator`? 

Removing the `Mediator` trait and simply renaming its only implementation will still keep the code
working, with the benefit that there are fewer lines of code now, and it isn't any harder to extend.

This is actually more in line with Steele's idea. It doesn't say anywhere a trait or interface
cannot be *distilled* from a base implementations. In other words, when our intuition says to plan
for repetition -- patterns -- we should *identify* them. The Gang of Four book was never a recipe
book for building great programs. It was a catalog! They observed several kinds of large-scale
systems and programs and extracted repetetive behaviours in the code, patterns. They never said that
to do things right, one ought to use the visitor pattern, or this other pattern, otherwise your
programs will be bad.

Back to interface distillation. Programming is about getting rid of repetition. The more experienced
the programmer, the better they get at noticing patterns of repetition. The downside is that this
may also lead to overengineering for repetition.

So, an experienced programmer thinks, this behaviour I have specificed may be repetitive, let me
*first* create a construct that lets me share the repetition (an interface), and then proceed with
the implementation. This is fine if the actual code is known to be repeated, but by seeing
interfaces as a hammer and every bit of code as a nail, you will soon bury yourself in pointless
dependency injection scenarios.

It may be just as easy to first create a base implementation and once you must duplicate its
behaviour, only *then* create the abstract implementation. You might actually need to spend *less*
total time wiring up the interface, since you observed the repetition. Creating an abstract
implementation first always involves a deal of speculation and this is not reliable.

The more experienced programmer understands that you don't always need to plan for repetition. In
fact, repetition is good sometimes. Not every shared functionality needs to be extracted to its own
module, because sometimes, shared dependencies will be bad. 

The approach I suggest is to in order to produce modularity as a side effect, structure your program
into small, reusable pieces. Don't create huge, monolithic interfaces. Functional programming shows
us that dependency injection can be done just by passing a function.

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
Scala this is fairly easy. You could as well decompose `Mediator` into `Validator`, `Postponer`, et
cetera, ideally interfaces should be fairly homogenous in their purpose: if your interface defines
methods for reading, keep that interface separate from the writing interface, and if you need read
and write just compose the interfaces together, and so on.

It also helps if your language is powerful enough to do without excessive DI -- the reason why
horrors like Spring exist is that Java simply wasn't expressive enough to do dependency injection
the traditional way without setting your hair on fire. That, and for some odd reason, people thought
writing constructor arguments was so painful it warranted a gigantic framework for it.

Overall, it's usually a good idea to toy around first with the concrete, and then extract the
abstraction. Going the other way around is a dangerous swamp. It's certainly something I've used to
do -- overengineer for patterns *a priori* -- but I found better results by getting my hands dirty,
by writing repetitive code first and then cleaning it up. 
