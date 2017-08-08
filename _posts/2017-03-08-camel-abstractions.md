---
title: Apache Camel and the price of abstractions
layout: post
disqus: true
date: 2017-03-08T00:00:00
tags:
  - java
  - clojure
  - camel
---

[Apache Camel](http://camel.apache.org/) is a routing and mediation engine. If that doesn't say
anything to you, let's try this: Camel lets you connect endpoints together. These endpoints can
vary. They can simple local components, like files, or external services like ActiveMQ or web
services. It has a common language format for the data, so that your data can be
protocol agnostic, and an intuitive DSL for specifying the connections and how the data should be
processed between messages.
<!--break-->

The common language consists of *exchanges* and *messages*. These are translated into
protocol-specific formats (like a HTTP request) by components, which provide the technical
implementation of that service, i.e., the translation of a simple `Message` into an actual HTTP
request.

The connection method is an intuitive DSL that speaks in terms such as `from` and `to`. Informally,
you can create a route that can, for example, read messages *from* ActiveMQ, and write them *to* a
file. The language is much richer than this, grouping together things like aggregation, filtering,
routing, splitting, load balancing, the list goes on.

Choosing what component to instantiate is done using an URI. An URI will identify the target
component, e.g., `rabbitmq://myserver:1234/...` instantiates
the [RabbitMQ](https://www.rabbitmq.com/) [component](http://camel.apache.org/rabbitmq.html),
`file:...` instantiates the [file component](http://camel.apache.org/file2.html), `netty4:...`
instantiates the Netty component (version 4.0). As long as the component is available in the
classpath, it will be instantiated in the background by Camel. The total number of
available [components](http://camel.apache.org/components.html) is huge! You have e.g.:

* ActiveMQ, RabbitMQ, Kafka, AVRO connectors
* Files and directories
* REST, SOAP, WSDL, etc.
* More esoteric ones like SMPP -- yes, you can send SMSes with Camel!

So what's the point? Let's assume we need to integrate an upstream system Xyz into Bar. Xyz provides
data to you using a binary JSON format, using some known protocol, like ActiveMQ. Then you need to
apply some transformations to the data, finally sending it to Bar, which accepts XML, and requires
the information to be POSTed to `someURL`.

In a non-camel setting, using your favorite language, to do this, you 

1. Using an ActiveMQ connector, you build your queue reader and de-serializer
2. Apply your business logic (whatever that is) to the de-serialized data
3. Transform into XML
4. POST the data towards `someURL` using some HTTP library

Fairly straightforward, right? All you need are an ActiveMQ library, a HTTP library and something
that works with JSON and XML.

Here's where it gets hairy. Three months in, you are informed that the upstream source is converting
to RabbitMQ. Oh well, you think, it's nicer, faster, and implements a saner version of AMQP, why
not. So you refactor ActiveMQ to RabbitMQ and there it is.

The point of Camel is this. The previous step requires you to manually refactor your ActiveMQ logic
to RabbitMQ. But you're just sending messages, you don't really care about the protocol. You're just
sending messages to an endpoint, it's the *data* you should care about, nothing else.

So here's when Apache Camel comes in. It let's you specify an URL like

```
rabbitmq://localhost/blah?routingKey=Events.XMC.*
```

to use the RabbitMQ component, and to painlessly switch to Kafka, you'd add a dependency to the
`camel-kafka` artifact and specify the URL as

```
kafka:localhost:9092?topic=test
```

and the Camel Kafka component handles message delivery for you. Since you're sending canonical camel
messages, you needn't trouble yourself on how this message is already sent. It is likely that you
will have to add or remove some message headers though.

Now, you may be asking, *is that it*? Is it really that simple?

The answer is that it depends. Some components are better than others. If you want to be truly
protocol and component agnostic, and you want to refactor from protocol `Foo` to `Bar` just by
switching the URL of `foo://...` to `bar://`, you need to make sure that

1. You can configure everything for that endpoint using the URI
2. Message exchanges do not require extra shenanigans to work (no custom headers or a special format
   required)

Case in point, let's compare switching from [ActiveMQ](http://camel.apache.org/activemq.html)
to [RabbitMQ](http://camel.apache.org/rabbitmq.html). The first glaring difference is that the
ActiveMQ component does not accept the host part in the URI. So we need to do something like

```java
CamelContext ctx = new DefaultCamelContext();
ctx.addComponent("activemq", 
    ActiveMQComponent.activeMQComponent("tcp://USER:PASS@HOSTNAME?broker.persistent=false"));
```

This makes any `activemq:...` URI in the context `ctx` connect to the parameters configured.

Conversely, the RabbitMQ component lets you directly set this in the URI part (multiple addresses can be
given with the `addresses` parameter). So if you're going with ActiveMQ to RabbitMQ, your code
actually becomes simpler, but the complexity merely moves to the URI. The other way around, you have
to move your URI-configuration to actual code (or XML, but please, *don't*).

So where does this lead us? Ideally, the situation is that given between a choice between three
components, you could use an external configuration file that configures a simple URI. The right
component is identified based on the URI, pulled out of the classpath. This assumes that, in order
of importance,

1. the endpoints are volatile and _finite_ and can vary between different implementations,
2. each implementation has a Component which is in the classpath, and
3. said volatility varies often enough it warrants dynamic configurability via configuration editing
   and app restarts.

If **all** of the above hold true, Camel might a good fit for you. Otherwise, I'd be careful: the
abstraction isn't free! What this leads to is a kind of *complexity shoveling*: although with the
RabbitMQ component we don't need to use *code* to configure it, we move it to the URI. So it's still
a configuration point. Yet, it's a *nicer* configuration point. As in the example above, we see that
the connection contains three configurable variables `USER`, `PASS`, and `HOSTNAME`. So, *in
addition* to having to configure the system using code, we have to still configure it otherwise,
lest we hard-code the values into the application.

The above approach suffers from decentralization: you now have *two* places where you customize your
system. The first is defining the custom component for a system in **code**. The second is
configuring said custom component via other means. 

Our ability to centralize configuration -- any configuration, not just that of Camel -- depends on
the power of the configuration language. Too powerful, you end up in DSL hell. Not powerful enough,
people write their [own horror shows](http://camel.apache.org/spring.html) to add power.

Lastly, we run in the problem of universal pluggability, or universal composition. We imagine that
systems like Camel let us "run anything" and "connect everything", but the reality is
different. Systems are usually made of a finite set of components. For practical purposes, it makes
no sense to depend on every Camel component. Therefore, you need to pick your dependencies from this
finite set of known endpoints. This effectively shatters the myth of universal pluggability.

Most importantly though, nobody really *needs this*. What really matters is the simplicity of
extension. A well designed component is completely configurable through its URI parameters. These
are easy to add to your Camel-based system: you only need to understand the new configuration, add
the dependency and you're done.

In summary, if you're considering Apache Camel, make sure you check both of these, of which the
second is most important. 

1. The components are volatile and you need to change them often, so that you can justify the
   pluggable hole (the changing URI!)
2. The components you want *exist* and are completely configurable via that pluggable hole

If you're unsure of the first item, you can still treat Camel as a lazy way to future-proof the
system, e.g., by using one component now, while knowing that another may be used in the future. To
that end, you need to make sure that the components fit the above requirements.

I'm currently working on a
[Clojure library](http://github.com/ane/llama) for a Clojure-based routing DSL. It's shaping up to
be quite nice! Here's an example of the routing DSL:

``` clojure
(route (from "netty4-http:localhost:80/foo")
       (process 
         (comp println body in))
       (to "rabbitmq://localhost:5672/foo"))
```

My goal is to make the DSL terse and functional (which the current model really isn't) and to add
[Akka Camel](http://doc.akka.io/docs/akka/current/scala/camel.html) Consumers and Producers to
it. The nice thing about Clojure is that the macro system lets me define these really easily!

Overall, Camel is a nice abstraction, well worth the effort and years that has been put into
it. It's not a *free* abstraction, since there's always a slight compatibility or configuration
overhead. If it works, it removes programmers from the protocol level, moving them to
the data level. This is the level where you should be working at, if your goal is to shuffle data
around. For this purpose, when it works, Camel is excellent.

Conversely, if it doesn't, it puts programmers at an awkward position: you're still
working with both data and protocol, *and* you have the overhead of the framework to deal
with. Worse, your code is now polluted by the requirements of *Camel endpoints*, when the goal of
Camel is to completely remove the requirements imposed by endpoints in general.

That said, in integration scenarios, Camel works *most of the time*, so you should always have a
think about it before you start using it.
