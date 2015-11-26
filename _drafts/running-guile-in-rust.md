---
layout: post
date: 2015-1-1 12:00 UTC
title: Embedding a Guile interpreter in Rust 
summary: Shows how to embed a Guile Scheme REPL in a Rust program 
disqus: true
---

[Guile](http://www.gnu.org/software/guile/) is a
[Scheme](https://en.wikipedia.org/wiki/Scheme_%28programming_language%29)
implementation that is the official extension language of the GNU
project. To this end, it has been designed to be easily embeddable
into other languages, featuring excellent 
[C interoperability](http://www.gnu.org/software/guile/docs/master/guile.html/Programming-in-C.html#Programming-in-C).

With this in mind, I set out to experiment a little bit. Just like
Guile, [Rust](http://www.rust-lang.org) boasts great C
interoperability. I thought it would make for a fun experiment to try
to get the two to talk together &mdash; that's right, embedding the
Guile interpreter inside a Rust program!

Never mind the why. Why not? 

# First steps

I wanted the program to compile and run via [Cargo](https://crates.io). This was something
I wasn't going to compromise on. I didn't want to fumble around with
giving `rustc` the right command arguments, or to invoke any strange
intermediary programs. It was going to be `cargo run` or bust.

To start, in order to link a program with Guile, I needed the
appropriate linker and compiler flags. For a C program, obtaining them
could be done with `pkg-config` on the command line:

```bash
$ pkg-config guile-2.0 --libs
-lguile-2.0 -lgc 
$ pkg-config guile-2.0 --cflags
-pthread -I/usr/include/guile/2.0
```

Using these in Rust was straightforward. The Rust book's
[FFI guide](https://doc.rust-lang.org/book/ffi.html) gave some
directions as to linking by using the `#[link=...]` directive, but I
felt it was easier to use the `pkg-config` crate to generate a
[build script](http://doc.crates.io/build-script.html) that handled
this for me.

Build scripts are Rust programs that generate instructions for
Cargo. `pkg-config` (the Rust crate) generates such Cargo instructions in
the vein of the real-world `pkg-config` program. To get the Guile
libraries linked, I used the following build script, called `build.rs`
in the project root folder:

```Rust
extern crate pkg_config;

fn main() {
    pkg_config::Config::new().statik(true).find("guile-2.0").unwrap();
}
```

This will link the Guile library statically (though I'm not sure it
will work) to the program. To use the `pkg-config` crate inside the
build script, I needed to set up the project dependencies. Note that
since the `pkg-config` crate was used in the build script, it was a
*build dependency*, hence it went under the `[build-dependencies]`
section. This is what the `Cargo.toml` file looked like after adding
that:

```toml
[package]
name = "guiletest"
version = "0.1.0"
authors = ["..."]
links = "guile-2.0"
build = "build.rs"

[dependencies]
libc = "0.2.2"

[build-dependencies]
pkg-config = "0.3.6"
```


