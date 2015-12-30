---
layout: post
date: 2015-12-07 12:00:00 UTC
title: Start-once software
summary: Our development tools are transitioning away from batch oriented processing
disqus: true
tags:
  - software
---

Software development tools are in a state of flux. There are two competing
directions towards which static analysis tools&mdash;like linters and
type checkers&mdash;are heading. 

The traditional direction is to operate in a *batch* model. Fire up, perform analysis, report
results, and die. This is a proven method. Batch-oriented software has been around for ages, and it
works really well if the data you're working with isn't large.

The new direction is an *online* model: an analysis tool starts, calculates its
data, reports results, and then stays *on*, monitoring for changes. When changes
occur, the program analyzes the changes, and recomputes the effects. This
execution model is efficient: incremental updates are easier to calculate than
starting from scratch. This approach is arguably more modern[^3], since we're
leveraging the full potential of a client-server model.

The obvious caveat is such a process will eat up memory. These days this is
becoming less and less of a problem, since a gigabyte of desktop-quality DDR3
memory costs about [US$5](http://www.newegg.com/Product/Product.aspx?Item=N82E16820231314&cm_re=ddr3-_-20-231-314-_-Product).

However, if the workload is large, say 100k-1M lines, it actually makes more
sense to compute an initial "model" of the system, and then *incrementally*
update the model when the system changes.

My line of reasoning was inspired by [this comment on Hacker News](https://news.ycombinator.com/item?id=10271755):

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
background, eating up half a gigabyte memory, and most of us won't even *blink*
at that, as long as it helps us write better code&mdash;and runs quickly.

To this end, one could call such software *start-once software*[^2], which

1. Is launched **once**, via some mechanism and given a target, e.g. a codebase, to
   monitor for changes
2. Computes an initial **model**, the analysis, of the target
3. Whenever changes occur it instantly **recomputes** a new model and informs
   the user of the effects of the changes. 

In this case, the target could be a collection of source files (a "project"), 
the model the compilation errors present in the source files, and the relevance
is a way of communicating those errors to the user.

The basic idea can be taken from Facebook's [Flow](http://www.flowtype.org)
which does exactly this when you launch it initially, it boots up a server that
keeps the state of the AST in memory. The server runs the analysis and the client
reports the results. There's an initial up-front cost to all of this from
starting the server but subsequent calls are fast.

There are some pseudo-implementations of this paradigm: you can have a batch
process that is run every time the target changes, and then do effectively what
is done in step three above. This is *kind of* what I described above, but the
difference is that any model is lost inbetween batch runs.

In fact, file system notification based batch processes remind[^4] me of the
[the Chinese room experiment](https://en.wikipedia.org/wiki/The_Chinese_Room):
such tools don't really have an *understanding* of the model that is
**persistent**, but due to a simultaneously crude and brilliant approach, we get the
subtle impression that such a persistent, evolving understanding actually exists.

In start-once software, the goal is to always keep the model in working memory
and update it incrementally. Such a program can react quickly to massive
codebase changes. Naturally, speed comes at the cost of memory, but as mentioned
in the quote, if it makes development faster, I think this is a perfectly
justifiable cost.

This line of thinking doesn't apply only to static analysis tools. It can work
with any streaming data. Memory is cheap, but speed always isn't. A good example
is a log processor that computes the state of some system based on the content
of some logs. A start-once processor would continuously monitor the log inputs
and update its model of the system. If it has to churn through a lot of logs at
the start, it may have an initial delay but because the model is persistent, any
changes to the model can be computed quickly.

Storing the model can be done in two ways. If RAM becomes a limitation (will
it?), a fast database should be used. AFter all, databases *solely* exist
because of the prohibitively high cost of ephemeral memory compared to the cost
of non-volatile memory. Traditionally!

Previously, because of the cost of ephemeral memory, we had to invent a cheaper
form of storage. Now that memory is cheap, this isn't so much of a threat
anymore.

When it comes to fault-tolerance, precautions can be taken. The model could be
stored as a persistent image&mdash;yes, raw memory or an accurate representation
thereof, or a database. Once the program recovers, it restores the model
immediately, reducing the boot time.

This model also be extended to web servers: instead of recompiling everything at
every request (hello PHP), one could compile *once* and then compile changes
incrementally. This idea isn't new: *hot swapping* has been around for decades,
and its advantages are obvious. Heavy-duty services that take a while to reload
and restore benefit massively of hot swapping. This is routine in the JVM,
Erlang and Lisp worlds.

Instead of shutting down your engine to upgrade it, you simply replace the parts
to be upgraded with new ones. 

Extending this to static analysis tools isn't a massive step. If the philosophy
works with server programs I see no reason why it couldn't work with data
analysis tools. At the cost of ephemeral resources like memory, I want static
analysis tools that can handle large codebases and compute any change big or
small in a fraction of a section.

I hope more tools will adopt this model. We certainly do have the resources now.

## Addendum: examples of start-once static analysis tools

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
requests are sent to the completion server via a JSON-based RPC. Conversely,
every other Go-related static analysis tool
([there are lots](http://dominik.honnef.co/posts/2014/12/an_incomplete_list_of_go_tools/))
is using the batch approach. That's fine, since Go seems to be vehemently
opposed to anything modern and advanced, and *sometimes* justifiably so. In this
regard Gocode is a rare gem among the Go tooling ecosystem.


[^1]: To a degree, anyway. Massive datasets are hard to fit in memory, but I
    wouldn't be surprised if it comes with the benefit of more speed, it may be
    a good idea even for large datasets (e.g. half a terabyte in size).
[^2]: Facebook uses the term "online" when describing Flow
[^3]: Yes, I know REPLs have been around since the eighties, but this isn't
    exactly the same thing.
[^4]: They aren't *exactly* the same thing. Since I'm talking about computer
    programs performing some kind of data analysis, and mentioning the Chinese
    room experiment, I realize that I'm opening a massive can of worms; the
    comparison is a mere *simile* here. The users of continuous
    (i.e. inotify-based) batch analysis tools are on the observing end of the
    Chinese room experiment.
