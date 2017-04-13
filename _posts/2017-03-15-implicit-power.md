---
layout: post
title: Implicit power
date: 2017-03-15T00:00:00
tags:
  - scala
---

Scala gets lots of flak for implicits. Some of the feedback is justified: implicits in Scala can be
quite intimidating or confusing for beginners. That does not justify their dismissal, as implicits,
in all of their flavours, when used correctly, can be actually quite simple and powerful.

I recently had to do a refactoring for large program. The codebase was old, and wasn't designed to
cope with the sort of change I was going to introduce, and I didn't have much time either. Pressed
for time, but compelled by a modicum of professional pride, I didn't want to half-ass the task by
adding jury-rigged solutions that would have left me feeling dirty and empty inside, at worst,
leaving a rotting mess to future developers---me.
<!--break-->
The codebase itself was simple, but large. Its task was more or less to serve as a REST API in front
of a high-availability, fast database (Cassandra). One part of the program provided abstractions
called *collections* of database tables. Each collection had a set of methods (such as `get`) that
were then translated to a database query to fetch *entities*. An entity is a piece of data
encapsulating some value. Using a fictional and simplified example of an `Bork` from a database:

``` scala
case class Bork(id: Int,
                date: ZonedDateTime,
                frobnicate: Decimal)

trait Borks {
  // find a bork by id
  def get(by: Int): Future[Option[Bork]]
}

// ... in another place, another module

class BorksImpl extends Borks {
  def get(by: Int): Future[Option[Bork]] = {
      // fetch by UUID from the database
  }
}
```

Each collection trait was implemented by a real class (like `RealEntries`), hiding database logic
behind a concrete implementation. Other parts of the program accessed these entities via the
collection trait, like the API front here:

``` scala
val borks: Borks = ...

// spray dsl
pathNamespace("borks" / IntNumber) { id =>
  get {
    complete {
      borks.get(id).toJson
    }
  }
}
```

The database in question was Cassandra, in which this *database* abstraction doesn't really exist,
as databases in Cassandra are actually just prefixes called *keyspaces* that map to physical
directories on the disk. These keyspaces have some properties that separate one keyspace from
another, but the point is that they are unlike traditional SQL databases: you need not *connect* to
a database, you can simply switch your query for the table `Foo`, in keyspace `A` to `B`, by
switching `A.Foo` to `B.Foo`. So, in Cassandra, these keyspaces are opaque and you can simply choose
the appropriate keyspace with the right namespace in the table name part of the query.

The task was to support multiple, concurrent databases of entries. Previously, this program operated as a
monolith, i.e. there was ever only *one* database it was operating on. Support was needed for
concurrent access to several (possibly non-finite) databases, and the support had to come quickly.

Turns out the simple solution -- instantiate one `BorksImpl` for each keyspace -- was not available,
as there could be entities in one *shared* keyspace mapping to other keyspaces. So, one collection
like `BorksImpl` needed to know which keyspaces it was supposed to query, because this information
is unavailable to the caller.

A way around the splitting and namespacing was consolidation, but this introduced security
problems. We couldn't simply consolidate all the entries into the same database, as we had access
limitations -- callers of `get` acting on keyspace `Foo` were not allowed to see the data in
keyspace `Bar`. This justified the creation of a split by keyspace, isolating data for the purposes
of permission control. This also destroyed the possibility of the above solution, i.e., instantiate
one `BorksImpl` for each keyspace, because *one* `BorksImpl` might have needed to query for data
from many keyspaces.

So, a request with an id `123` comes in at `/borks/123`, the application uses the central lookup
table to find the target keyspace. The initial implementation looked like this.

``` scala
trait Borks {
  // find a bork by id
  def get(namespace: String, by: Int): Option[Bork]
}

// ... in another place, another module

class BorksImpl extends Borks {
  def get(namespace: String, by: UUID): Option[Bork] = {
      // fetch by UUID from the database
  }
}
```

And update the caller API: 

``` scala
val borks: Borks = ...

pathPrefix("borks" / IntNumber) { id =>
  queryNamespace(id) { namespace =>
    get {
      complete {
        borks.get(namespace, borkId).toJson
      }
    }
  }
}
```

This was fairly simple, but painful, as the `get` methods of collections like `Borks` may have
called other methods on other collections, nesting calls ever downward, as shown below in the
example, where `Borks` calls `barks.get` and so forth.  As a result, I had to deal with adding the
`namespace: String` parameter to *all* methods on all collections. Remember, adding the namespace
method as a *field* was not an option -- the namespace was an extra parameter to every method
invocation.

So I was dealing with transforming code that looked like this:

``` scala
val barksImpl: Barks = ...
def aggregateWithBarks(id: Int, barks: Set[Int]): Future[Seq[Borks]] = {
   val aggregates = get(id) map { b =>
     b map { bork => 
       barks flatMap { bark =>
         barksImpl.get(bark.id) match {
            ...
         }
       }
     }
   }
   ...
}
```

and by adding `namespace` everywhere, I had to transform it into

```scala
val barksImpl: Barks = ...
def aggregateWithBarks(namespace: String, id: Int, barks: Set[Int]): Future[Seq[Borks]] = {
   val aggregates = get(namespace, id) map { b =>
     b map { bork => 
       barks flatMap { bark =>
         barksImpl.get(namespace, bark.id) match {
            ...
         }
       }
     }
   }
   ...
}
```


So I had to add `namespace: String` to `barks.get` and `borks.aggregateWithBarks`. Sounds tedious?
Well, imagine there weren't just one call to `barksImpl.get`, but tens, and imagine there weren't
just two collections, but a hundred -- and tens of thousands of lines to refactor.

Specifically, I didn't want to keep adding `namespace, ` into every method call inside a method call,
but chose to make it implicit instead.  This way, I needed only pass the implicit parameter around,
and I didn't need to modify any of the nested method calls. I typed the namespace with a custom case
class and added it as an implicit argument:

``` scala
case class Namespace(namespace: String)

trait Borks {
  def get(id: Int)(implicit namespace: Namespace) = ...
  def aggregateWithBarks(id: Int, barks: Set[Int])(implicit namespace: Namespace) = ...
}

trait Barks {
  def get(id: Int)(implicit namespace: Namespace) = ...
}
```

So, that was one particularly nice use case for implicit parameters. The good thing is that if the
datastore is redesigned cleanly so that you cannot access from one namespace (keyspace) to another,
all you need is to instantiate BorksImpl and set `implicit val namespace = ...` upon instantiation, and
the code will work just fine. Implicit parameters let me implement a painful refactoring very
quickly.

Naturally, had I had more time, I would've done the separation properly, implemented namespacing
rules more clearly, completely redesigning the database, and so forth. Anyway, with Scala implicits,
I was able to do a non-proper solution in a way that did not elicit a "jesus christ what a hack"
feeling. It didn't pollute my code too much and it will be easy to *refactor out* when it's no
longer needed.

And, it turned out, I was able to benefit from other implicits: conversions and arguments. I needed
the ability to convert from the `Namespace` entity into a `String`, as I had in the querybuilder
syntax. I needed only to insert `namespace` instead of having to write `namespace.namespace`.

``` scala
object Namespace {
  implicit def namespace2String(n: Namespace): String = n.namespace
}

Session.prepare(QueryBuilder.insertInto(namespace, table).values(...))
```

Another nice thing was using implicit arguments. The REST API gets the namespace from the URI segment
as a parameter to the anonymous function. If I called `borks.get` I would have needed to put an
`implicit val n: Namespace = namespace`. I avoided that using the implicit argument method:

``` scala
val borks: Borks = ...

pathPrefix("borks" / IntNumber) { id =>
  queryNamespace(id) { implicit namespace: Namespace =>
    get {
      complete {
        borks.get(borkId).toJson
      }
    }
  }
}
```

The `implicit namespace: Namespace =>` is equivalent to having `namespace => implicit val n:
Namespace = namespace; ...`. Very useful if you're calling methods requiring implicits in closures,
though potentially hazardous, if you're not typing your implicits! A simpler example:

``` scala
trait Vyx {
  def frobnicate(num: Int): Int
}

// contrived example, makes no sense
def foo(i: Int)(implicit vyx: Vyx) = {
   i * vyx.frobnicate(num)
}

val foo = Seq("one", "two", "three") map { implicit v: Vyx => foo(1) }
```

It's a good idea to type your implicit values as defining an `implicit x: X` will yoink any implicit
`X` in scope, and if this `X` happens to be a basic type like `String`, and you're not careful, you
end up with the wrong implicit value.

Implicits weren't a new thing to me, this was just a scenario where I was able to simultaneously
benefit from many kinds of implicits Scala has to offer (parameters, conversions and
arguments). They let me perform an annoying refactoring quickly and painlessly, in a manner that was
also future-proof. 


