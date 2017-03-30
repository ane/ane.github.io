---
layout: post
date: 2016-10-14
title: "Communicators: Actors with purely functional state"
summary: "or, why mutable state is dangerous"
disqus: true
tags:
  - scala
  - erlang
---

In Scala, Akka actors, as in the traditional [Actor model](http://en.wikipedia.org/wiki/Actor_model), may
modify private state. The accepted convention is to have a mutable object (e.g. a
`Map`), a `var`, and mutate it like so:

```scala
class Library extends Actor {
  var books = scala.collection.mutable.Map.empty[String, String]
  
  def receive: Receive = {
    case AddBook(isbn, title) => books += (isbn -> title)
  }
}

object Library {
  case class AddBook(isbn: String, title: String)
}
```

This is a bad idea. There are several reasons for this. First, Scala eschews `var`s, they should
only be used when absolutely necessary (read: never). There is also an additional need for
thread-safety for the collection, not because of the `receive` method itself. The `receive` method
is
[guaranteed to run inside a single thread](http://doc.akka.io/docs/akka/2.4.11/general/jmm.html). However,
an unsuspecting user might still launch a `Future` and modify the collection, leading to
unpredictable behaviour. Such concurrent mutations on a `var` put strain on the garbage collector,
in fact, it often necessitates the existence of a garbage collector.[^1] Lastly, as with any mutable
state and possible lack of referential transparency, the code can become hard to reason about.

Thankfully, Akka actors offer a possibility to do this completely functionally. The function
`context.become` allows an Actor to change its `receive` method on-the-fly. In other words, it lets
the Actor change its state and communication model. Here's the above implemented using this
paradigm:

```scala
class Library extends Actor {
  def receive = active(Map.empty)
  
  def active(books: Map[String, String]): Receive = {
    case AddBook(isbn, title) => {
      // for immutable maps, += returns a new collection
      context.become(active(books += (isbn -> title))) 
    }
  }
}
```

The `active` function returns a new `Receive`, receiving the current actor *state* as its
parameter. Adding logic to it is now easy: 

```scala
class Library extends Actor {
  def receive = active(Map.empty)
  
  def active(books: Map[String, String]): Receive = {
    case AddBook(isbn title) => {
      if (books.size < 10) {
        context.become(active(books += (isbn -> title)))
      } else {
        sender() ! "Too many books"
      }
    }
  }
}
```

The above code is now thread-safe and doesn't use mutable collections, but what if our logic gets
more complicated? What if we need to talk to another Actor, or talk to the sender of the message?
This is where we stumble upon a design feature of Akka: *all* of its Actors are actually compiled
down into a callback-based implementation. There is no guarantee that a `Future` launched in a
receive case will be running in the same thread as the next! One could argue that this is not a
feature but a *flaw*, but I won't go that far. Hence, code dealing with Futures in Akka actors needs to deal with the unforgiving reality that there is no
guarantee of thread safety. Case in point:

```scala
class Library(popReservation: String => Future[String]) extends Actor {
  def receive = active(Map.empty)
  
  def active(books: Map[String, String]): Receive = {
    case AddBook(isbn, title) => { ... } // as before
    case AskForBook(isbn) => {
      popReservation(isbn) foreach { i =>
        // AAH!!!
        context.become(active(books - i))
        sender() ! s"Here you go: $i"
      }
    }
  }
}

```

Why am I screaming in the comments? First, as calling `map` for our Future launches a new thread, we
have no idea whether `sender()` returns the same value in the new thread, and second, we may be
modifying the books collection concurrently with other threads - leaving the garbage collector to
collect our mess. So we strain the GC *and* risk giving the book to the wrong caller! 

Since the actual execution of a Future is left to the execution context, which in the case of Actors
is the `ActorSystem`s dispatcher, we may or may not be invoking `sender()` in the right thread
&mdash; there is simply no guarantee. We can't reason about it, it has been hidden from us.

To deal with this, Akka has introduced the `pipe` pattern, which is an implicit given to Futures
which solves this:


```scala
class Library(popReservation: String => Future[String]) extends Actor {
  def receive = active(Map.empty)
  
  def active(books: Map[String, String]): Receive = {
    case AddBook(isbn, title) => { ... } // as before
    case AskForBook(isbn) => {
      // launch another thread
      val reservation: Future[String] = popReservation(isbn) map { i =>
        s"Here you go: $i"
        context.become(active(books - isbn)) // AAH!
      }
      // but sender() is still the same
      reservation pipeTo sender
    }
  }
}
```

Another option is to fix the reference of `sender`:

```scala
val s = sender()
val reservation: Future[String] = popReservation(isbn) map { i =>
  s ! s"Here you go: $i"
  context.become(active(books - isbn)) // AAH!
}
```

Ok, now we've fixed `sender()`, but what about the `books` collection? Let's add a `PopBook(isbn:
String)` case class, and handle that for removals:

```scala
class Library(popReservation: String => Future[String]) extends Actor {
  def receive = active(Map.empty)
  
  def active(books: Map[String, String]): Receive = {
    case AddBook(isbn, title) => { ... } // as before
    case PopBook(isbn) => context.become(active(books - isbn))
    case AskForBook(isbn) => {
      // launch another thread
      val reservation: Future[String] = popReservation(isbn) map { i =>
        s"Here you go: $i"
        self ! PopBook(i)
      }
      // but sender() is still the same
      reservation pipeTo sender
    }
  }
}
```

Sending messages to `self` is always thread-safe - the reference does not change over time. So, at
this point, it seems clear that making actor code thread-*sane* involves the use of:

* immutable state - call `context.become` with a closure over the new actor state, 
* converting asynchronous state modifications as messages to be handled later, and 
* making sure the `sender()` reference is consistent

What about complicated states? What if we need to react differently to these messages, e.g., when
the library is closed? I sense that you're about to mention Akka's `FSM` construct, which
builds a state machine, encapsulating state and transitions to what is essentially syntactic sugar,
and on the surface, seems like a good idea.

## Enter Akka FSMs

At a closer look, it essentially leads us to repeat the same mistakes as above, and the arguments
against it are argumented [here](https://github.com/alexandru/scala-best-practices/blob/master/sections/5-actors.md#55-should-not-use-akka-fsm){:target="_blank"}. In
summary, it boils down to:

1. Akka FSM's is too restrictive. You cannot handle multi-step or complicated state transitions, and
   modeling undeterministic behaviour is impossible.
2. You are tied to Akka completely, you must use Akka testkit for your tests. Anyone who has worked
   with testkit knows this to be a burden.
3. State transitions have identity instead of being truly functional, that is, FSMs alter the
   *current* state instead of *producing* a new one.
   
Moreover, and I think this is the biggest shortcoming, the Akka FSM are finite-state *automata*
&mdash; they are characterised by the state transition function `(Input, State) => State`. Since we
know actors are more about communication than anything else, this model is insufficient, and what we
need is a state machine that can produce *output*: a finite state *transducer*. Its state transition
function has the signature `(Input, State) => (Output, State)` - every transition produces an
output, and Scala can model this efficiently: 

```scala
trait FSA[State, Input, Output] {
  def transition(s: State, i: Input): (Option[Output], State)
}
```

   
With all these flaws, despite being a nice idea at a glance, it's obvious that for any complicated
logic Akka FSM's aren't sufficient. 

Let's envision a radical version of actors, accounting for all the flaws described above:

* State transitions should be about producing a new state, i.e. `(Input, State) => (Output, State)`
* Actor computations will deal with asynchronous code, we must deal with this intelligently
* Keep I/O logic out of actors - the actor only communicates with the external world
* Actors should only mutate their state with with `context.become`

The last bullet point is especially important, as it constrains state changes
to be entirely functional, as you can simply make a function `def foo(state:
State): Receive`, and keep calling it recursively, by transitioning states
thusly:

```scala
def active(state: State): Receive = {
  case someInput: Input => context become active(state)
}
```

This idea is not new. Erlang actors have worked like this for actual decades,
and arguments for using this method in Scala can be found left and right, summarized particularly well in
Alexandru Nedelcu's [Scala best practices](https://github.com/alexandru/scala-best-practices/blob/master/sections/5-actors.md#52-should-mutate-state-in-actors-only-with-contextbecome). 

```erlang
active(Sum) ->
  receive 
    {From, GetValue} -> From ! Sum;
    {n} -> active(Sum + n)
  end.
```

Putting emphasis on the last point, I've come up with a moniker called *communicators*.

## Actor, meet communicator

Let's define the `Communicator` trait first independently:

```scala
trait Communicator[State, Input, Output] extends Actor {
  /** This is the initial actor state */
  def initial: State

  /** The state transition function */
  def process(state: State, input: Input): Future[(Option[Output], State)]

  /** The output processing function */
  def handle(state: State, output: Output, origin: ActorRef): Future[Unit]
}
```

`initial` is simply the initial state machine state, `process` is the state transition function and
`handle` is the function that will deal with dispatching the result of `process`. Because we're
producing content in another thread, we want to make sure the reference of `sender` is fixed, and by
using this with the `pipeTo` pattern, we get thread safety. Let's extend the `Actor` trait to get
`receive`

```scala
trait Communicator[State, Input, Output] extends Actor {
  /** This is the initial actor state */
  def initial: State

  /** The state transition function */
  def handle(state: State, product: Output, origin: ActorRef): Future[Unit]

  /** The output processing function */
  def process(state: State, input: Input): Future[(Option[Output], State)]
  
  def receive = active(initial)
  
  /** I/O handling which the deriving class must implement */
  def active(newState: State): Receive
}
```

The `active` function is the actual output-producing function. The user is left to define three
things:

* the initial actor state in `initial`
* the output dispatch function `handle`
* the state transition function `process`
* the `active` function which handles input and output

To see this in action, first, let's define the application states.

```scala
object Library {
  // Library state
  case class LibraryState(open: Boolean, books: Map[String, String])

  // Input alphabet
  sealed trait LibraryInput
  case class SetOpen(o: Boolean)                  extends Input
  case class AddBook(isbn: String, title: String) extends Input
  case class GetBook(isbn: String)                extends Input

  // Output alphabet
  sealed trait LibraryOutput
  case object SorryWeAreClosed                        extends Output
  case object DoNotHaveIt                             extends Output
  case object SorryReserved                           extends Output
  case class Book(isbn: String, title: String)        extends Output
  case class Reservation(isbn: String, title: String) extends Output
}
```

The actual state is just a case class: this gives us the nice `copy` function for easy updates. Then
we use polymorphism to implement the input and output alphabets. Then we implement the actor itself:

```scala
class Library(getReservation: String => Future[Boolean])
    extends Communicator[LibraryState, LibraryInput, LibraryOutput] {

  import Library._

  def initial = State(false, scala.collection.immutable.Map.empty)

  override def active(newState: LibraryState): Receive = {
    case (output: LibraryOutput, origin: ActorRef) => handle(output, origin)

    case input: LibraryInput => {
      val origin = sender()
      process(newState, input) map {
        case (output, state) =>
          output foreach { o =>
            self ! (o, origin)
          }
          self ! state
      }
    }
  }

  override def process(state: State, input: Input): Future[(Option[Output], State)] =
    input match {
      case SetOpen(o) => Future.successful((None, state.copy(open = o)))

      case (GetBook(_) | AddBook(_, _)) if !state.open =>
        Future.successful((Some(SorryWeAreClosed), state))

      case GetBook(isbn) => {
        val book =
          for {
            (isbn, title) <- state.books.get(isbn)
          } yield {
            getReservation(isbn) map { reserved =>
              if (!reserved) {
                (Some(Book(isbn, title)), state.copy(books = state.books - isbn))
              } else {
                (Some(SorryReserved), state)
              }
            }
          }

        book getOrElse Future.successful((Some(DoNotHaveIt), state))
      }

      case AddBook(isbn, title) =>
        Future.successful((None, state.copy(books = state.books + (isbn -> title))))
    }

  override def handle(state: State, output: Output, origin: ActorRef): Future[Unit] = {
    Future {
      origin ! output
    }
  }
}
```

## Decoupling Akka

So, now we've made a very thin actor, with little I/O logic inside it, but it's still an
actor. Let's decouple it entirely from actor semantics. First, we define a `StateMachine[I, O]`
trait:

```scala
trait StateMachine[I, O] {
  def process(input: I): Future[(Option[O], StateMachine[I, O])]
}
```

And excise the state logic from the Communicator, moving it to the `State` case class:

```scala
case class LibraryState(open: Boolean, books: Map[String, String], getReservation: String => Future[Boolean])(
    implicit ec: ExecutionContext)
    extends StateMachine[LibraryInput, LibraryOutput] {
    
  def process(input: LibraryInput): Future[(Option[LibraryOutput], LibraryState)] = {
    input match {
      case SetOpen(o) => Future.successful((None, copy(open = o)))

      case (GetBook(_) | AddBook(_, _)) if !open =>
        Future.successful((Some(SorryWeAreClosed), copy()))

      case GetBook(isbn) => {
        val book =
          for {
            title <- books.get(isbn)
          } yield {
            getReservation(isbn) map { reserved =>
              if (!reserved) {
                (Some(Book(isbn, title)), copy(books = books - isbn))
              } else {
                (Some(SorryReserved), copy())
              }
            }
          }

        book getOrElse Future.successful((Some(DoNotHaveIt), copy()))
      }

      case AddBook(isbn, title) =>
        Future.successful((None, copy(books = books + (isbn -> title))))
    }
  }
}
```

You may be wondering: wait, where's the `handle` implementation? We kept that out from the state
machine class since it's not its responsibility - so we keep that in the Communicator:

```scala
class Library(getReservation: String => Future[Boolean])
    extends Communicator[LibraryInput, LibraryOutput, LibraryState] {
  import context.dispatcher

  def initial = LibraryState(false, scala.collection.immutable.Map.empty, getReservation)

  override def handle(output: LibraryOutput, origin: ActorRef): Unit = origin ! output

  override def active(newState: LibraryState): Receive = {
    case (output: LibraryOutput, origin: ActorRef) => handle(output, origin)

    case state: LibraryState => context become active(state)

    case input: LibraryInput => {
      val origin = sender()
      newState.process(input) map {
        case (output, state) => {
          output foreach { o => 
            self ! (o, origin)
          }
          self ! state
        }
      }
    }
  }
}

```

So, all state is kept neatly in a separate entity that's entirely unit testable in its own right
without having to rely on Akka testkit or the like -- input and output dispatch and state
transitions are done in the `active` method.

I know the state case class manipulation introduces more boilerplate, but as long as that
boilerplate isn't complicated, I think this is a fair compromise. Plus, one can
use [lenses](https://github.com/julien-truffaut/Monocle) to remove some of the boilerplate, e.g., 
by defining handy update functions. One could cook up something doggedly interesting using [Cats](http://typelevel.org/cats) and
`StateT` - as long as you provide a function of the kind `(I, S) => (Option[O], S)`, the sky is the limit.

*Thanks to Jaakko Pallari (@jkpl) for previewing this.*

[^1]: This is actually false, as Aaron Turon, a core Rust developer, proves in his article about [getting lock-free structures without garbage collection](demonstrates).
