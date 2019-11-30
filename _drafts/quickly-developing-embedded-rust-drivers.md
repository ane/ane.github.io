---
layout: post
title: Quickly developing embedded drivers in Rust
date: 2019-11-25T00:00:00
---

Developing drivers for embedded devices is fun! You get to deciper datasheets
and debug like crazy! You'll also doubt your breadboard even works or that your
microcontroller or host platform has faulty hardware. 

In general, embedded device driver development is *mostly* about sending
arbitrary commands down some serial bus. This means that when you develop a
driver, you'll be looking at a datasheet and wondering how to get a sensor
reading.

Typically, if you're directly using a device that's connected to a
microcontroller that's connected to your development machine, the setup looks
like this:

{:.diagram}
```
 ┌─────────────┐            ┌─────────┐           ┌────────────┐
 │             │  USB, SWD, │         │ SPI / I2C │            │
 │   Desktop   ├───────────>│   MCU   ├──────────>│   Device   │
 │             │            │         │    etc.   │            │
 └─────────────┘            └─────────┘           └────────────┘
```

If your goal is to develop a Rust driver to be used in embedded devices, there
are several ways to do this. Assuming the device you're talking to is using a
fairly common interface like I2C, SPI or UART, you can use the [embedded-hal]()
hardware abstraction layer when writing your device driver to get platform and
device agnostic traits to use for data transfer. After all, most of the
development for an embedded device driver is about sending and receiving data
from the target device. You choose a microcontroller that [supports the
HAL](https://github.com/rust-embedded/awesome-embedded-rust/#hal-implementation-crates)
you need and start developing.

The first approach is doing your development directly on a microcontroller wired
into the target device. This requires being able to debug, let alone flash, the
example program on your microcontroller. Using OpenOCD and GDB over JTAG is
fairly common, but the downside is that you have to reprogram the
microcontroller every time you change something. Additionally, the resource
constraints of the target device apply. Given a proper board support crate
however this isn't hard, in fact, OpenOCD and GDB work quite nicely in Visual
Studio Code, for example. Typically, it goes like this:

```

But for the *prototyping* part of driver development this is probably a bit
slow: you're constrained by the `#![no_std]` environment, you're forced to write
embedded Rust. If all you need is to transmit data over some pins, surely you
don't have to do the prototyping in a `#![no_std]` environment! 

If you don't want to develop directly on a microcontroller, there are
alternatives. After all, what we're talking about here is just sending data
over, e.g., SPI, surely there must be easier ways to use this interface than
going through a microcontroller? Well, sure! For instance, we have the
[linux-embedded-hal]() crate that implements the HAL traits for a device that
has direct Linux support for the common interfaces, like Raspberry Pi. 

So, plug your Pi into a breadboard, wire it up to the device, and run your Rust
code on the Pi. This, too, has alternatives. You can code directly (over SSH)
on the Raspberry Pi, but since a Pi (or its many equivalents) are not as
powerful as modern desktop computers, Rust can be slow to compile on these
things. The other alternative is to use
[cross](https://github.com/rust-embedded/cross) to cross-compile the binary
on your desktop and upload it to your target machine.

So you're still down to some sort of "remote" workflow where you edit your code
on your main working environment, like a desktop computer. Is there an
alternative way to do this? Surely, don't modern desktop computers have the
ability to use, let's say, I2C? 

Well, I2C and SPI and GPIO ports probably haven't been seen in desktop computers
since the eighties (?) so there could be things that give you GPIO access over
USB. Well, turns out FTDI makes just a chip like that! The [FTDI232H]() exposes
I2C, SPI and GPIO over USB, and the Linux kernel has had support for FTDI for
ages. This means you can directly interface with your target device from your
desktop computer. What is more, there is a Rust HAL library called
[ftdi-embedded-hal]() that gives you HAL implementations for this, so you can
actually develop against embedded HAL traits *on your desktop machine*.

But, sadly, ftdi-embedded-hal isn't quite there yet. There is no crate on
[crates.io](), so you must use a Git dependency. GPIO *input* isn't supported
either, you can only receive stuff from I2C or SPI.

That said, compared to Raspberry Pi, where you must either cross compile and SSH
your binary on the device, or develop directly on the Pi which incurs somewhat
slow compilation times, this is much faster!

Going back to the development workflow for writing a driver in Rust, I've found
that the easiest approach is, assuming you've just about unwrapped the devices
and unsheathed your breadboard, is to first wire things up and test using some
other language or framework, like CircuitPython or Arduino. This gives proof
that the components *work* and the wiring is OK, all you need now is to fart the
right kind of data down the peripheral interfaces -- in Rust.

So, after we have the wires in place, where do we start? Do we go straight to a
microcontroller? Do we use a Raspberry Pi? Should you use a FTDI GPIO over USB
device? The table below summarizes the key differences:

{:.table.table-bordered.table-sm}
| Execution environment | Compiler unit | `#![no_std]` required? | Flash or uploading required | Compilation |
|:----------------------|---------------|:-----------------------|-----------------------------|:------------|
| Microcontroller       | Desktop       | yes                    | yes                         | fast        |
| Raspberry Pi (SSH)    | Remote        | no                     | no                          | slow        |
| Raspberry Pi (Cross)  | Desktop       | no                     | yes                         | fast        |
| Desktop (using FTDI)  | Desktop       | no                     | no                          | fast        |

While compiling and flashing for the MCU is the most accurate method, in the
sense that you're writing bare-metal code, you still need to flash it into the
microcontroller. RPi and FTDI based systems are not bare metal, although you can
write bare-metal stuff for a Raspberry Pi, if that's your thing (why?). So, what
are the pros and cons of each?

Microcontroller

: Programming directly to the microcontroller is the most authentic
  (i.e. bare-metal) approach, but for driver development you'll have to write
  fully embedded software.
  
  ##### Pros
  
  * Bare-metal -- the code is already `#![no_std]`
  * Compilation is done on the desktop machine, which is fast
  * Debugging is easy with a debugger attached
  
  ##### Cons
  
  * Microcontroller constraints apply
  * Debugging requires a debugger
  
Raspberry Pi (or any other SBC with peripherals)

: Using a single-board computer like Raspberry Pi has the benefit of being able
  to run a real operating system on it. This means you have things like SSH and
  even a text editor that you can run on it. But, it's still a relatively slow
  system compared to a modern desktop computer.
  
  ##### Pros
  
  * No hardware or software constraints, it's a real operating system with
    peripherals!
  
  ##### Cons
  
  * Not the fastest machine for compiling Rust
  * You're working remotely over SSH (unless you're coding *on* the Pi)
  * You'll have to write new code for the embedded example
  * Debugging 
  
Desktop machine with FTDI

: Using FTDI gives your desktop machine a bunch of peripherals over USB. This is
  pretty cool, but these devices still aren't well supported by the embedded
  Rust ecosystem.
  
  ##### Pros
  
  * Direct interface to the target component
  * Debugging happens on the same machine
  
  ##### Cons
  
  * Not a bare metal environment, you'll have to test it on actual devices
  
