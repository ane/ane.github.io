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

Your first instinct is to *look* at them, but what if the communication method is subtler than that?
What if you're&mdash;figuratively&mdash;deaf and cannot eavesdrop?

This problem arises when you have a non-trivial of distributed components talking to each other
accross various mediums and protocols. Consider this simple example: 

<center>
![A simple example](/images/are-my-services-1-simple.png)
</center>

*arrows indicate flows of information, i.e. x &rarr; y means x sends information to y*

You could assume **A** is a logging system, **B** is a message queue and **C** is a cache. We want
to be able to query the cache quickly for log events and rely on the message queue of transporting
them from **A** to **C**, while *preferably* having **A** not be dependent on **C**.

The illusion is that while there are neither code nor protocol dependencies between **A** and **C**,
a semantic dependency *does* exist. It's all in our heads! **A** is content on dumping information
towards **B**, but what we're really interested in is messages getting through all the way to **C**.

## Tolerating faults

What if the chain breaks? What happens when A can't push messages onward to B, and we get a
blackout? Who gets notified? C doesn't know what's happening in A, it's just not getting
information! In line of the original question, if I can see both A and C are doing fine, but they're
not talking to each other? Who failed?

With such a simple case this is easy, but let's build a more complicated network:

<center>
![A slightly more complex example](/images/are-my-services-2-not-so-simple.png)
</center>

Let's assume each one of these components is an independent service, each load balanced and with
redundancies that aren't visible beyond the node itself, and that communication is done over a
computer network using some protocol.

In the Internet world, with the TCP protocol, commucation is reliable and error-checked. That means,
if A were a network element and wanted to send things over to C, in case of a succesful delivery C
will acknowledge this back to A.

For various reasons, it may be that in a distributed service network this approach is not
feasible. This is the cost of abstractions: when you enforce loose coupling, you have to deal with
the consequences of looseness. We *could* build the Logger aware of the user-facing Application but
that may be overkill.
