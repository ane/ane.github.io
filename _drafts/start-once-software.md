---
layout: post
date: 2015-1-1 12:00 UTC
title: Start-once software
summary: Our development tools are transitioning away from batch oriented processing
disqus: true
---

Software development tools are in a state of flux. Specifically, tools that
analyze code or data, like linters and type checkers, are heading towards a
direction in which they are started once, not over and over again. This is in
contrast with the old *batch-oriented* model, where tools effectively live and
die doing their work in the span of a single execution.

Although a continuously running process might be very expensive in terms of
resources, we have to remember that these days, RAM is cheap. For a process as
vital as type checking, the speed that can be gained is reason enough to move
into this direction.

The *other* direction is to stay in batch more: fire up, run analysis, report
results, die. This works if the load you're working with isn't big. If the
workload is large, and can benefit from dynamic updates, it actually makes more
sense to compute the initial model of the system to be analyzed, and then
perform *incrementally* updates to the model when the system changes.

I was inspired by this [this comment on Hacker News](https://news.ycombinator.com/item?id=10271755):

> Over and over I see reports of iteration speed being critical to
> real-world projects, and that's certainly my experience.  
> 
> But it's something I rarely see featured in tool design. So many of
> our tools are still batch oriented: they start from scratch, read
> everything, process everything, and then exit. That made sense in an
> era where RAM and CPU were expensive. But now that they're cheap, I
> want tools that I start when I arrive in the morning and kill when I
> go home. In between, they should work hard to make my life easy. 
> 
> If I'm going to use a type checker, I want it to load the AST once,
> continuously monitor for changes, and be optimized for incremental
> changes. Ditto compilers, syntax checkers, linters, test runners,
> debugging tools. Everything that matters to me in my core feedback
> loop of writing a bit of code and seeing that it works.
> 
> For 4% of my annual salary, I can get a machine with 128GB of RAM and
> 8 3.1 GHz cores. Please god somebody build tools that take advantage
> of that.

Arguably, the batch mode made sense in the past, when resources weren't as
plentiful as they are now. Now, we can afford a type checker that sits in the
background and eats up half a gigabyte of memory, as long as it helps us write
better code, and *runs quickly*.

To this end, one could call such software *start-once software*[^2], which

1. Is launched once via some mechanism and given a target to monitor
2. Continuously updates its analysis model of the target in an incremental
or otherwise dynamic fashion
3. Upon updates, informs the user of the changes in the model and their
   relevance to the target

In this case, the target could be a collection of source files (a "project"), 
the model the compilation errors present in the source files, and the relevance
is a way of communicating those errors to the user.

The basic idea can be taken from Facebook's [Flow](http://www.flowtype.org)
which does exactly this (I believe another static analysis tool called Hack from
Facebook does this as well): when you launch it initially, it boots up a server
that keeps the state of the AST in memory. The next call to the program
*connects* to that server, runs the analysis there, and reports the
results. There's an initial up-front cost to all of this from starting the
server but subsequent calls become faster.

There are some pseudoimplementations of this paradigm: you can have a batch
process that is run every time the *target* changes, and then do step
three. This is of course more like the system described above, but the
difference is that the model state is lost in between batch runs. Watcher-based
tools are a bit reminiscient of
[the Chinese room experiment](https://en.wikipedia.org/wiki/The_Chinese_Room):
such tools don't really have a persistent *understanding* of the model, but due
to its ingenious and crude approach, we get a subtle impression of such an
understanding.

In start-once software, the goal is to have the model always in memory and
perform incremental updates. Such a program can react quickly to massive changes
in a codebase. Naturally, speed comes at the cost of memory, but as mentioned in
the quote, if it makes development faster, I think this is a perfectly
justifiable cost.

This doesn't only apply to static analysis tools: this can work with any
streaming data. Memory is cheap, but speed always isn't. A good example is a log
processor that computes the state of some system based on the content of some
logs. A start-once processor would continuously monitor the log inputs and update its model
of the system. If it has to churn through a lot of logs at the start, it may
have an start-up delay, but because the model is persistent, any changes to the
model can be computed quickly.

Storing the model can be done in two ways. If RAM becomes a limitation (it
shouldn't), a fast database should be used. There's a caveat with this:
databases *solely* exist because of the prohibitively high cost of ephemeral
memory compared to the cost of non-volatile memory. We had to invent some kind
of storage that wasn't ephemeral, because ephemeral storage was very
limited. This is no longer true[^1]. Now that memory is cheap (4GB of DDR3 is 50
US$ on newegg), this isn't so much of a threat anymore.

Precautions can be taken in the software in case of a irreversible fault. The
model could be stored as a persistent image&mdash;yes, raw memory or an accurate
representation thereof, or a database&mdash;and then instantly loaded. Once the program
recovers, it restores the model immediately, reducing the boot time.

This model also be extended to web servers: instead of recompiling everything at
every request (hello PHP), one could compile *once* and then compile changes
incrementally. This idea isn't new: *hot swapping* has been around for decades,
and its advantages are obvious. Heavy-duty services that take a while to reload
and restore benefit massively of hot swapping. This is routine in the JVM,
Erlang and Lisp worlds. Instead of shutting down your engine to upgrade it, you
simply replace the parts to be upgraded with new ones.

Extending this to static analysis isn't a massive step. If the philosophy works
with server programs I see no reason why it couldn't work with data analysis
tools. At the cost of ephemeral resources like memory, I want static analysis
tools that can handle large codebases and compute any change big or small in a
fraction of a section.

I hope more tools will adopt this model. We certainly do have the resources now.

## Addendum: examples of start-once static analysis

### [Flow](http://flowtype.org)

A static analysis tool for JavaScript by Facebook, written in OCaml. Upon
launch, it starts a server that runs initial analysis and monitors for
changes.

### [Hack](http://hacklang.org/)

A PHP-inspired gradually typed programming language for the HHVM virtual
machine. It runs a type checker in the background in the same way as Flow
does. Also in OCaml!

### [gocode](http://github.com/nsf/gocode)

Auto-completion service for Go. It uses a client-server model where completion
requests are sent to the completion server via a JSON-based RPC.


[^1]: To a degree, anyway. Massive datasets are hard to fit in memory, but I
    wouldn't be surprised if it comes with the benefit of more speed, it may be
    a good idea even for large datasets (e.g. half a terabyte in size).
[^2]: Facebook uses the term "online" when describing Flow
    
