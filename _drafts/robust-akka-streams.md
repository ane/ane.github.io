---
title: Circuit Breakers and Akka Streams
layout: post
disqus: true
date: 2016-11-07T00:00:00
tags:
  - scala
  - akka
  - rx
---

Handling errors in
[Akka Streams](http://doc.akka.io/docs/akka/2.4/scala/stream/stream-introduction.html) is
drastically different from traditional Akka error handling, which uses
[supervision trees](http://doc.akka.io/docs/akka/2.4/general/supervision.html)
to do fault tolerance. 

In the supervision tree model, each actor forms a tree with its child actors, and each parent actor
to any child actor can choose how to react when that child actor fails, that is, throws an
exception. If a child actor throws an `ArithmeticException`, its parent or supervising actor
can choose how to react. It can, for example, reboot the actor or terminate it, or it can escalate
the error to its own parent actor, or it can restart itself and thus restart all child actors.

Like many things in Akka, this idea is originally from
[Erlang](http://erlang.org/documentation/doc-4.9.1/doc/design_principles/sup_princ.html), so it's a
product of careful refinement.

Akka Streams adopts parts of the supervision tree in its model, but as the model is fundamentally
different from the actor model, it's quite another beast. The model borrows the idea of
*supervision* from the actor model and the reason for it is simple: by default, Akka Streams
implements its streams using actors. So when you're using Akka Streams you're typically running
actors, and this is obvious, as you need a materializer --- which usually is an `ActorMaterializer`
--- to run it, and you need an `ActorSystem` to run that.

I find Akka Streams to be a significant improvement over the actor model, for many reasons, most
significantly because they're type safe and stable.

There are some quirks in the design, however. Actors are designed to be more or less online all the
time, which creates the need for a supervisor that ensures this is the case. Streams on the other
hand materialize when there is data to be processed. A *materialized* Stream is always more or less
finite, although the stream itself is not. What happens when a materialized stream fails? Suppose a
stream element causes an irrecoverable crash? Here, Akka Stream offers error handling in the form of
*stop*, *resume* and *restart*. Stop means the stream will crash and any elements in-flight will be
discarded. Resume means the erroring element will cause it to be discarded, and restart discards any
accumulated state.

Consider the case where your stream has a switch stage which will either discard the element or pass
it through, and this switch is based on an external resource. The switch can return either `true` or
`false`, and works like this:

```scala
def askSwitch(str: String): Boolean = ???

val switch: Flow[String, String, NotUsed] =
  Flow[String]                        // accepts x: String
    .map { s => (s, askSwitch(s))}    // convert to (x: String, y: Boolean)
    .collect { case (s, true) => s }  // discard elements where y is false, back to x: String
```

If our `askSwitch` returns Futures, we do it like this

```scala
def askSwitch(str: String): Future[Boolean] = ???

val switch: Flow[String, String, NotUsed] =
  Flow[String]
    .mapAsync(1) { s => askSwitch(s) map { b => (s, b) }}
    .collect { case (s, true) => s }
```

This switch can be wired into any flow, e.g., `Source("a", "b", "c").via(switch).map(...).to(...)`
as a filtering element.

The `askSwitch` function can do anything, but let's assume it's calling an external resource, like
an API, or a database. What happens if that stage starts breaking and the external resource is
producing errors? Do we fail the stream? Do we discard the elements with a resume strategy? 

If we fail the stream, the elements not yet processed are lost. If we restart the stream, we will
still encounter the same error, so nothing is gained. If we use the resume strategy, we will simply
keep discarding the elements, so nothing is produced. We want to obviously find a fall-back scheme
in cases where the external switch falls apart.

To this end, we introduce a *circuit breaker*. The
[circuit breaker pattern](http://martinfowler.com/bliki/CircuitBreaker.html) works like real-life
circuit breakers: we monitor a certain process for failures, e.g. by setting a failure threshold,
and once that is reached, we trip the breaker, causing it to be *open*. Then, every request will
start failing. If requests start working, we revert the circuit to the *closed* state, in which case
requests start working.
