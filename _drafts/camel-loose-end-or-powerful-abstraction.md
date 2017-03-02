---
title: Universal reactive streams with Apache Camel
layout: post
disqus: true
date: 2017-03-02T00:00:00
tags:
  - java
  - clojure
  - scala
  - akka
  - camel
  - rx
---

Apache Camel is an enterprise integration framework with powerful abstractions for consuming and
producing messages from external services, and for wiring two or more services together. What is
particularly nice is the level of abstraction, to read from an endpoint all you need is the Camel
component (a library dependency) and a valid URI for connecting to it.

What is particularly interesting is that doing reactive systems using Camel is relatively easy. When
wiring two Camel endpoints together with a [`Route`](http://camel.apache.org/routes.html), it is a
pull-based system. So, consumers will poll upstream for new messages.

Usually, as specified in the [Reactive Manifesto](http://www.reactive-manifesto.org), in reactive
programming we'd prefer a *push-based system*. This means that downstream consumers *react* to
events rather than ask for them, this is the push--pull dichotomy. With push-based systems it's
easier to implement [back pressure](https://en.wikipedia.org/wiki/Back_pressure). Back pressure
ensures that *a fast producer does not overwhelm a slow consumer*. This prevents downstream
consumers from getting out of memory errors. What is tremendously more important is that back
pressure can flow throughout the stream. Back pressure is signaled by downstream consumers to
upstream producers along the protocol.

You may now be wondering, wait, if one has back pressure, isn't it a hybrid push--pull system? Yes,
because downstream signaling upstream that it has room for more elements, is effectively the same
thing as polling the consumer for more elements, only that the producer can react to this signal and
send items. Conversely, if production exceeds demand, the model switches to *push*. 

Remember that the Reactive Manifesto is fundamentally about *API design*. It specifies the
`.request(N)` method for the Subscriber, which signals demand to the Publisher. When you cross
network boundaries, what if such a signal gets lost? How does the Publisher react, does it switch to
a push-model? What if the Publisher is itself a Subscriber to another upstream Publisher? It turns
out, the answer to this isn't entirely simple. (More on this later.)

A larger motivation is to connect different systems together reactively. This may sound more
difficult than it is, although it's definitely not *simple*. I'll show an example built using Camel,
and provide a Clojure DSL for creating reactive streams out of Camel endpoints.

## Apache Camel

When it comes to network boundaries, [Apache Camel](http://camel.apache.org/) is an enterprise
integration framework. It lets you connect any two services together, provided they have
*components* --- Camel modules for talking to that system. The beauty of it is that your code can be
agnostic of the target protocol, as you connect services via URIs,
e.g. `rabbitmq://myserver:1234/exchangeName?routingKey=blah`. This will instantiate
the
[RabbitMQ](https://www.rabbitmq.com/) [Camel component](http://camel.apache.org/rabbitmq.html). The
total number of available [components](http://camel.apache.org/components.html) is huge! You have
e.g.:

* ActiveMQ, RabbitMQ, Kafka, AVRO connectors
* Files and directories
* REST, SOAP, WSDL, etc.
* More esoteric ones like SMPP -- yes, you can send SMSes with Camel!

The idea is that as long as there is a component for it, you can consume or produce message to
it. Better yet, you don't actually have to instantiate anything in particular, the component loading
will be done based on the URI. So, if you want to read from RabbitMQ, serialize them into JSON, do
some transformations, and finally send them as SMSes to a
[SMPP](https://en.wikipedia.org/wiki/Short_Message_Peer-to-Peer) endpoint you need the following:

1. Dependencies available for Camel, [camel-rabbitmq](http://camel.apache.org/rabbitmq.html)
   and [camel-smpp](http://camel.apache.org/smpp.html)
2. Endpoint URIs, `rabbitmq://host:1234/exchange?...` and
   `smpp://user@host:2775?password=password?systemType=Fsub_Fdel&dataCoding=3`, etc.
3. A Camel `RouteBuilder` that defines `.from("rabbitmq://...")` and `.to("smpp://...")`
4. A Camel `Processor` that does the transformation in-between

The high-level version seems like an extremely powerful abstraction -- service integration never got
any easier. Sometimes though, it's not as easy as it looks, as you'll have to do type conversions
from one format to the other. Without any configuration, Camel sends data as raw bytes, so if you
want to read JSON from RabbitMQ, transform it into an actual SMPP message, and send it.

Here's a concrete Java example of a service that reads from RabbitMQ and then sends them to a
file. It reads from an exchange `myExchange` from a direct queue called `blargh` and then pumps them
to a file called `blargh.txt`, appending results to the end of the file as messages are received.

```java
public class RabbitToFile {
  public static void main(String args[]) throws Exception {
    CamelContext context = new DefaultCamelContext();
    context.addRoutes(new RouteBuilder() {
      public void configure() {
        from("rabbitmq://localhost:5672/myExchange?queue=blargh")
                .to("file:output?fileName=blargh.txt&fileExist=append");
      }
    });
    context.start();
  }
}
```

This simple example simply wires the two endpoints together. What if we want to simply read a
message from ActiveMQ, log its contents, and send it to nowhere in particular? For this, we need to
implement a `Processor`.

```java
public class ActiveMQProcessor {
    public static void main(String args[]) throws Exception {
        CamelContext context = new DefaultCamelContext();
        Processor logMessages = new Processor() {
            Logger logger = LoggerFactory.getLogger("ActiveMQProcessor");
            public void process(Exchange exchange) throws Exception {
                String content = exchange.getIn().getBody(String.class);
                logger.info("Got content: {}", content);
            }
        };
        context.addRoutes(new RouteBuilder() {
            public void configure() throws Exception {
                from("activemq:queue:foobar").process(logMessages).to("mock:nowhere");
            }
        });
        context.start();
    }
}
```

As you can see, we need to supply an *endpoint* in the form of `mock:nowhere`. This is because Camel
routes are *wirings*, i.e., connections between two places. This creates a continuously running
stream, Camel handles polling for you.

The beauty of all this is that as long as there is a Camel component for the endpoint, this will
work with all of them, as long as your URI is well-defined. Naturally, some components do not
translate so well
