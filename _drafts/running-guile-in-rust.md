---
layout: post-toc
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

## Building the REPL

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce sit amet eleifend elit, quis feugiat
risus. Aenean condimentum ultricies eros a mattis. Fusce aliquam neque id commodo finibus. Sed
varius non urna non commodo. Nunc mollis vehicula dapibus. Aenean nec leo pharetra, tincidunt nibh
ac, tempor ex. Etiam eleifend tincidunt elementum. Fusce nec nulla id mi ullamcorper fringilla et
id velit.

Fusce sed tempus metus, sit amet vehicula dolor. Nullam et molestie ex. Nulla non tincidunt
sem. Integer est eros, suscipit a magna et, rhoncus consequat metus. Nulla facilisi. Integer
bibendum porttitor dui maximus venenatis. Aenean ut purus ligula. Proin tempus tincidunt ipsum, non
pellentesque velit dapibus sed. Etiam vitae vehicula diam. Nunc ac porttitor nibh, id faucibus
lectus. Mauris vehicula ex vitae tellus euismod sagittis. Cras sed turpis eget mi pellentesque
pellentesque.

## Type equivalencies

Sed tempor odio sit amet turpis fermentum, vel laoreet est feugiat. Nulla non vehicula sem. In nec
tellus finibus risus rhoncus dapibus quis at lorem. Vestibulum finibus imperdiet metus, vitae
pharetra eros bibendum euismod. Nam dictum porttitor elit, quis viverra neque convallis at. Proin
bibendum elementum placerat. Maecenas ultricies erat quis dapibus semper. Suspendisse
potenti. Mauris commodo cursus lorem sed posuere. Duis cursus turpis elit, non eleifend dui interdum
in.

## Static or dynamic?

Nulla non tincidunt urna. Fusce sapien lorem, sodales a eros sed, suscipit facilisis justo. Mauris
consectetur quam in massa faucibus tincidunt. Duis consequat nisl non eros sagittis blandit. Quisque
efficitur libero at sapien pharetra aliquet. Nulla tempor turpis consectetur nibh posuere, ac dictum
diam luctus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;

Morbi lobortis arcu convallis sagittis ornare. In molestie erat lacus, a feugiat dui volutpat
in. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In eu odio
vitae felis venenatis dapibus eu quis elit. Sed facilisis lectus felis, a vehicula felis molestie
sit amet. Aliquam volutpat eleifend hendrerit. Aliquam non feugiat magna.

# Calling Rust from Guile

Praesent iaculis tortor est, vitae porttitor arcu imperdiet et. Vivamus auctor felis euismod tellus
aliquam, ac tempor mi posuere. Vestibulum nec lorem sed metus fermentum maximus ac blandit sapien.

Pellentesque ultricies dolor nulla, in porta turpis tristique ut. Duis vehicula augue eget odio
dignissim, eu tincidunt diam accumsan. Curabitur mattis arcu congue mauris suscipit
ultricies. Praesent dignissim vehicula neque.

Phasellus ipsum nibh, feugiat sed ipsum sed, luctus rutrum orci. Ut sed ipsum non erat congue
tincidunt. Nulla et sapien quam. Ut maximus posuere diam, et varius orci scelerisque
ullamcorper. Sed quis molestie lorem.

## Rust types in Scheme

Sed tempor odio sit amet turpis fermentum, vel laoreet est feugiat. Nulla non vehicula sem. In nec
tellus finibus risus rhoncus dapibus quis at lorem. Vestibulum finibus imperdiet metus, vitae
pharetra eros bibendum euismod. Nam dictum porttitor elit, quis viverra neque convallis at. Proin
bibendum elementum placerat. Maecenas ultricies erat quis dapibus semper. Suspendisse
potenti. Mauris commodo cursus lorem sed posuere. Duis cursus turpis elit, non eleifend dui interdum
in.

Praesent iaculis tortor est, vitae porttitor arcu imperdiet et. Vivamus auctor felis euismod tellus
aliquam, ac tempor mi posuere. Vestibulum nec lorem sed metus fermentum maximus ac blandit sapien.

Pellentesque ultricies dolor nulla, in porta turpis tristique ut. Duis vehicula augue eget odio
dignissim, eu tincidunt diam accumsan. Curabitur mattis arcu congue mauris suscipit
ultricies. Praesent dignissim vehicula neque.

Phasellus ipsum nibh, feugiat sed ipsum sed, luctus rutrum orci. Ut sed ipsum non erat congue
tincidunt. Nulla et sapien quam. Ut maximus posuere diam, et varius orci scelerisque
ullamcorper. Sed quis molestie lorem.

# Conclusion

Nulla non tincidunt urna. Fusce sapien lorem, sodales a eros sed, suscipit facilisis justo. Mauris
consectetur quam in massa faucibus tincidunt. Duis consequat nisl non eros sagittis blandit. Quisque
efficitur libero at sapien pharetra aliquet. Nulla tempor turpis consectetur nibh posuere, ac dictum
diam luctus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;

Morbi lobortis arcu convallis sagittis ornare. In molestie erat lacus, a feugiat dui volutpat
in. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In eu odio
vitae felis venenatis dapibus eu quis elit. Sed facilisis lectus felis, a vehicula felis molestie
sit amet. Aliquam volutpat eleifend hendrerit. Aliquam non feugiat magna.



