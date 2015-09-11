---
layout: post
disqus: true
title:  "Rust is sufficiently high-level"
description: "The Rust programming language is described as a language primarily designed for systems programming. Systems programming languages tend to be very perfomant, but the performance may come at a cost to the programmer."
date:   2015-09-10
tags: 
- rust
---

==blah== _hello_ ~~wt blah 

```rust
// This code is editable and runnable!
fn main() {
    // A simple integer calculator:
    // `+` or `-` means add or subtract by 1
    // `*` or `/` means multiply or divide by 2

    let program = "+ + * - /";
    let mut accumulator = 0;

    for token in program.chars() {
        match token {
            '+' => accumulator += 1,
            '-' => accumulator -= 1,
            '*' => accumulator *= 2,
            '/' => accumulator /= 2,
            _ => { /* ignore everything else */ }
        }
    }

    println!("The program \"{}\" calculates the value {}", program, accumulator);
}
```
              
