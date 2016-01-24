---
layout: post
title: Are my services talking to each other?
date: 2016-01-31
tags: 
  - architecture
---

I am faced with an interesting thought experiment, in which I ask:

> If I can see two of my friends, and I know they should be communicating to each other, what is the
> simplest way of making sure they are doing so?

Your first instinct is to *look* at them and *listen*, but what if the communication method is subtler than that?  What if you are, metaphorically speaking, deaf, and cannot eavesdrop their messages?

This problem arises when you have a non-trivial amount of distributed components talking to each other
accross various mediums and protocols. Let's start from the basics and consider this simple example:

<center>
![A simple example](/images/are-my-services-1-simple.png)

<small>
*arrows indicate flows of information, i.e. x &rarr; y means x sends information to y*
</small>
</center>

You could assume **A** is a logging system, **B** is a message queue and **C** is a cache. We want
to be able to query the cache quickly for log events and rely on the message queue of transporting
them from **A** to **C**, while *preferably* having **A** not be dependent on **C**.

The illusion is that while there are neither code nor protocol dependencies between **A** and **C**,
a semantic dependency *does* exist. It's all in our heads! **A** is content on dumping information
towards **B**, but what we're really interested in is messages getting through all the way to
**C**. So in reality, if we superimpose dependencies on top of information flows, we end up with
this:

<center>
![A simple example, part two.](/images/are-my-services-3-simple.png)
</center>

## Tolerating faults

What if the chain breaks? What happens when A can't push messages onward to B, and we get a
blackout? Who gets notified? C doesn't know what's happening in A, it's just not getting
information! In line of the original question, if I can see both A and C are doing fine, but they're
not talking to each other? Who failed?

With such a simple case this is easy, but let's build a more complicated network:

<center>
![A slightly more complex example](/images/are-my-services-2-not-so-simple.png)

<small>
<em>A - an event log; B - a message queue; C - a cache; E - app backend; A - a user-facing
application; I - a business intelligence system; S - a storage system</em>
</small>
</center>

Let's assume each one of these components is an independent service, each load balanced and with
redundancies that aren't visible beyond the node itself, and that communication is done over a
computer network using some protocol.

The depicted network consists of a set of applications that all in one way or the other build on top
of an event log, A. In one branch, there's a fast queryable cache for the event log, the app backend is an interface
for the cache (like a REST API), and the storage acts as a long-term backup system. The second
branch consists of a business intelligence system that analyzes the event log data and does
something with it. 

Indirectly, there are dependency arrows that emanate from the root of the network tree (A) to its
leaves S, P and I. From an observer's perspective, these are the relationships that
matter. Furthermore, we can see those dependencies, but we build the code in such a way that it does
not. The event log simply dumps data to a message queue, and that's it.

<center>
![A slightly more complex example](/images/are-my-services-4-not-so-simple.png)

<small>
<em>Implied dependencies</em>
</small>
</center>

The inherent hazard in all this, of course, is that there's a communication error. Even though we
(hopefully) built the system following the
[robustness principle](https://en.wikipedia.org/wiki/Robustness_principle), data isn't flowing from
the root node to the leaf nodes and we have to quickly identify where the disconnect happened.

## Seeing is not enough

Our first instict is to peer at the logs. So we go through each *edge* in the network and see if
there's a fault. This means looking at least at *n-1* edges for each fault! Something that gives me *visibility* is not enough in this case. I am interested in the flow of
information from one place or the other. Thus using service discovery tools like ZooKeeper do not
solve the problem. The thought experiment already assumes that the nodes are there, only the
communication between them is broken.

In the Internet world, with the TCP protocol, commucation is reliable and error-checked. That means,
if A were a network element and wanted to send things over to C, in case of a succesful delivery C
will acknowledge this back to A.

For various reasons, it may be that in a distributed service network this approach is not
feasible. This is the cost of abstractions: when you enforce loose coupling, you have to deal with
the consequences of looseness. We *could* build the Logger aware of the user-facing Application but
that may be overkill.

What about centralization? If all nodes are logging their events to a centralized place, we have now
introduced a dependency for *all* nodes.
