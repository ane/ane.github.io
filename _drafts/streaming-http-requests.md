---
layout: post
title: "Streaming HTTP requests in akka-http"
date: 2016-10-17
tags:
  - scala
  - akka
  - reactive-streams
---

<figure class="figure pull-md-right m-l-2">
<img src="/images/streaming-http/first.png" class="figure-img img-fluid">
<figcaption class="figure-caption">Figure 1. Input sources to an application</figcaption>
</figure>

[Akka streams](http://doc.akka.io/docs/akka/2.4/scala/stream/index.html) is the
[reactive streams](http://doc.akka.io/docs/akka/2.4/scala/stream/index.html) implementation of the
[Akka toolkit](http://akka.io). It lets you model computations as data flows while abstracting away
the underlying concurrency and parallelism. That is to say, the developer is free to model the data
in a computation as a *flow* of data from one place to another. Now, while this is an exciting
subject by itself, this post isn't about reactive programming, but a particular use case for it. I
assume some familiarity with reactive programming and the terms Akka Streams uses, so if you find
some of the terms confusing, refer to the Akka documentation for more information. To those familiar
with the former but not with the latter, a Flow is a Processor.

## Problem description

Our particular quandary is that we want to build an application (see Figure 1) which consists of a
unidirectional datastream from a set of input sources (files, a message queue, a HTTP interface),
propagating them from `A` to `C`, and so on. 

If we build this as a Akka Strems flow, conceptually, it could look like this:

```scala
// the sink
val sink: Sink[String, Future[Done]] = Sink.foreach[String](x => println(x))

// a silly flow
val flow: Flow[String, String, NotUsed] = Flow[String].map(x => x + "!")

// our sources
val mq = Source.single("hi from mq")
val rest = Source.single("hi from rest api")
val file = Source.single("hi from a file")

// run sources to the sink
mq.via(flow).runWith(sink)
rest.via(flow).runWith(sink)
file.via(flow).runWith(sink)
```

The thing to remember is that internally this code does **not** look like the things in Figure 1, at
all. This is because these flow stages are blueprints: they describe how inputs are connected to
outputs, but it is not as if the `sink` is concretely targeted as a value. It is simply a building
block that is used in an actual flow. It is the actual call to `runWith` that produces a computation
-- materializing a value -- but not the actual `Sink` itself.

It is particularly easy to construct a `Source[T, ...]` from a message queue and a file, but the
HTTP part is tricky. The thing to remember is that the *above code does not do anything*: it is
simply a *blueprint* of a reactive program. It says "wire these sources together, merge their
outputs, send them to A, and from there finally to C", but it doesn't do anything until we
*materialize* it. 

<figure class="figure pull-md-right m-l-2">
<img src="/images/streaming-http/second.png" class="figure-img img-fluid">
<figcaption class="figure-caption">Figure 2. Hooking our flow to the HTTP server flow.</figcaption>
</figure>

This is where akka-http jumps in. In akka-http, a web server consists, at a low level, from
a `Flow[HttpRequest, HttpResponse, NotUsed]`. We are interested in getting our `Message` elements
out of the `HttpRequest` and propagating them further downstream, and not particularly interested in
giving the HTTP client anything more descriptive than a `HTTP 201 Created`. 

If we wire our flow as a part of this flow, still, *nothing happens*, because it's a blueprint. The
blueprint gets materialized into a flow when a HTTP connection comes, and once the connection dies,
the flow dies. So even if we manage to hook our flow as a part of the HTTP server flow like in
Figure 2, we end up destroying every the main flow once every HTTP request ends. This demonstrated
by the following snippet:

```scala
import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.{HttpRequest, HttpResponse}
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{Flow, Sink}
import akka.util.ByteString
import akka.{Done, NotUsed}
import com.typesafe.scalalogging.StrictLogging

implicit val system       = ActorSystem()
implicit val materializer = ActorMaterializer()

import system.dispatcher
```
This brings us the necessary elements into view. First, we need the final stage of the flow,
the sink. It materializes into a `Future[Done]` which will complete when the stream completes.

```scala
// the sink
val sink: Sink[String, Future[Done]] = Sink.foreach[String](msg => println(msg))
```

Next, a simple appender processing stage.

```scala
// the processing Flow in the middle
val flow: Flow[String, String, NotUsed] = Flow[String].map(s => s + "!").log("middle-flow")
```

Here's the funny part: we need to extract the data inside the `HttpEntity`, but as that is a
`Source[ByteString, ...]` we complete that source by folding its contents into a string. Looks more
complicated than it is in reality. Actual unmarshalling is a lot simpler than this.

```scala
// turn requests into messages
val toMsg: Flow[HttpRequest, String, NotUsed] =
    Flow[HttpRequest]
    .mapAsync(1)(req => {
        val content = req.entity.dataBytes.runFold(ByteString.empty)(_ ++ _)

        content.map(_.decodeString("UTF-8"))
    })
    .log("to-msg")
```

Hooking the flows together couldn't be simpler: this plugs the `Sink` end of the `Flow`, creating a `Sink`.

```scala
// hook flows together
val msgsToFlow = toMsg.via(flow).to(sink)
```

Now we create the request flow. the `.alsoTo` method sends the flow elements to a `Sink`, and then
returns the stream, effectively broadcasting the flow to two places. That is the *yoink* part above.

```scala
// the request flow, sending also to toMsg
val route: Flow[HttpRequest, HttpResponse, NotUsed] =
    Flow[HttpRequest].alsoTo(msgsToFlow).map(_ => HttpResponse(200, entity = "Thanks!"))
                      // ^ yoink!

// run server
Http().bindAndHandle(route, "localhost", 8080)
```

Running the snippet yields the following:

```bash
$ curl -X POST -d'hello' localhost:8080
Thanks!

... in our application ...
DEBUG akka.io.TcpListener - New connection accepted
DEBUG akka.stream.Materializer - [rest] Element: HttpResponse(200 OK,List(), ...)
DEBUG akka.stream.Materializer - [to-msg] Element: hello
DEBUG akka.stream.Materializer - [middle-flow] Element: hello!
hello!
DEBUG akka.stream.Materializer - [rest] Downstream finished.
DEBUG akka.stream.Materializer - [to-msg] Upstream finished.
DEBUG akka.stream.Materializer - [middle-flow] Upstream finished.
```

