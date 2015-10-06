---
layout: post
disqus: true
title:  "Rust is sufficiently high-level"
description: "The Rust programming language is described as a language primarily designed for systems programming. Systems programming languages tend to be very perfomant, but the performance may come at a cost to the programmer."
date:   2015-09-10
tags: 
- rust
---

From a programmer, Rust demands safety and responsibility. In return, it gives performance and
freedom. After all, it is a low-level systems programming language, and as such, to do anything will
*usually* require more code than in other high-level languages. The biggest reason for this is that
Rust requires manual memory management and is strict about memory safety. This results in a steep
learning curve and it will take some time before an unfamiliar programmer groks things.

Fear not, the amount of additional code needed is not high. Rust's syntax is very terse, favouring
words like `mut`, `impl`, `pub`, and `Fn` to express its semantics. One must specify
[lifetimes](https://doc.rust-lang.org/book/lifetimes.html), [mutability](https://doc.rust-lang.org/book/mutability.html ), and
[ownership](https://doc.rust-lang.org/book/references-and-borrowing.html). Rust does its
best to minimize management by enforcing things like
[RAII](https://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization), but nonetheless code
can be a bit more verbose than in other languages.

Comparing snippets from [Rosetta Code](http://rosettacode.org/wiki/Concurrent_computing ) we can
see the differences between Rust and other languages. The chosen snippet is called *Concurrent
computing* and its idea is simple: the words "Enjoy", "Rosetta", and "Code" must all be printed in
any order from different threads. The Rust code for this is as follows:

```rust
extern crate rand;
use std::thread;
use rand::thread_rng;
use rand::distributions::{Range, IndependentSample};
 
fn main() {
    let mut rng = thread_rng();
    let rng_range = Range::new(0u32, 100);
    for word in "Enjoy Rosetta Code".split_whitespace() {
        let snooze_time = rng_range.ind_sample(&mut rng);
        let local_word = word.to_owned();
        std::thread::spawn(move || {
            thread::sleep_ms(snooze_time);
            println!("{}", local_word);
        });
    }
    thread::sleep_ms(1000);
}
```

We can compare this to a Scheme implementation in Racket. Of course, comparing anything to a Lisp is
a bit unfair, so we'll also compare it to an implementation in C. 

```racket
#lang racket
(for ([str '("Enjoy" "Rosetta" "Code")])
  (thread (λ () (displayln str))))
```

This one is much more interesting, C isn't a garbage collected language (Racket, being a Scheme,
is), and what is more, it uses [OpenMP](http://openmp.org/wp/ ), so it's working behind the scenes
to make the code run in parallel.

```C
#include <stdio.h>
#include <omp.h>
 
int main()
{
	const char *str[] = { "Enjoy", "Rosetta", "Code" };
	#pragma omp parallel for num_threads(3)
	for (int i = 0; i < 3; i++)
		printf("%s\n", str[i]);
	return 0;
}
```

Unlike the C and Racket implementations, the Rust implementation is a bit more elaborate. It sleeps
a random amount of time in every thread so that the threads finish in truly random order. If the
sleeps weren't present, they would execute in any order guaranteed by the OS. The threads are native
OS threads (so are the others). What is remarkable is that in the Rust code, we must be explicit of
the following:

  * When sampling a random number using `ind_sample`, we must pass a mutable reference to the
    random number generator. The generator may need to modify its state, and only a mutable
    reference to `self` is allowed to do so.
  * When iterating over the words, we must call `to_owned` for the string so that the string is no
    longer borrowed but *owned*, so that it can be passed to the new thread.
  * The closure for the spawned thread is a
    [move closure](https://doc.rust-lang.org/book/closures.html#move-closures ). Such closures have
    their own stack frame. This is necessary for threads because they may outlive the parent. If you
    remove all calls to `thread::sleep`, you will not see anything.

Sounds like a lot of effort? We can simplify the code by removing all the calls to sleep, since the
others aren't sleeping either. The Racket `thread` procedure waits for its result to complete, and
so does the C version. We can remove any randomness by waiting on the threads using join guards:

```rust
use std::thread;
 
fn main() {
    let mut guards = Vec::new();
    
    for word in "Enjoy Rosetta Code".split_whitespace() {
        let local_word = word.to_owned();
        let guard = thread::spawn(move || {
            println!("{}", local_word);
        });
        guards.push(guard);
    }
    
    for g in guards.into_iter() {
        g.join().unwrap();
    }
}
``` 

Perhaps less obtrusive, but the important elements remain: ownership, mutability and move
semantics. Even from such a simple example it is evident that writing simple stuff in Rust takes a
bit more effort.

## Create, Read, Update, Delete

If you're interested in performance and memory safety, Rust is the way to go. The small list of
features I listed above is only a small part of Rust. With its focus on safety and performance, Rust
is great for embedded systems, compilers, window managers and so forth. What about user
applications? Website backends? Would you write a simple
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete ) web application in Rust?




