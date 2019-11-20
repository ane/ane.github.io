---
layout: post
title: Embedded Rust and WiFi
date: 2019-11-20T00:00:00
---

Earlier this year, in May or so, I started having fun with hobby electronics,
and ended up playing around with Rust in embedded devices, microcontrollers and
the like. Actually it's the other way around, I first wanted to write some Rust,
and found out that Rust has a thriving embedded ecosystem, and proceeded to buy
some microcontroller dev boards (and upgrading my "lab" equipment from 2003),
and started writing Rust on them.

**It's fun!** The last time I did any embedded was in 2003, when I was 15 or so,
and things were *way* different back then. The affordable microcontrollers were
8-bit turds like PIC8, and the hot stuff was AVR. C was the only language that
was around and information on the net was scarce. Then, Arduino happened, and
things started improving.

Now in 2019, sixteen years later, things are *much* easier. [You can program
MCUs in Python!](https://circuitpython.org/) Clock speeds run in the hundreds of MHz and there are tens
of kilobytes of RAM. The internet is full of tutorials.

Rust, given its nice high-level abstractions and package management, has [an
amazing embedded ecosystem](https://github.com/rust-embedded/awesome-embedded-rust). All you need is their build tool and GDB with
ARM support. Using a HAL is actually a real abstraction: implement a single HAL
API, like [I<sup>2</sup>C](https://docs.rs/embedded-hal/0.2.3/embedded_hal/blocking/i2c/index.html), and your device is usable by anyone. As of
writing some things are still missing from the Rust HAL library, like USB and
CAN support, but it's slowly building up.

Anyway, WiFi. Wireless connectivity on a little microcontroller is an extremely
nice way of getting your toy device on the internet. Most likely the most
popular WiFi microcontroller devboard is the ESP32, which costs about 10 EUR. If
you want to write Rust on this thing though, there are problems: the ESP32 is
using a Xtensa LX6 processor, which doesn't (yet) have mainline LLVM support,
you'll have to use C or CircuitPython.

<figure class="float-sm-right ml-3">
  <img src="/images/esp32_wroom.jpg" class="figure-img img-fluid" width="150px"/>
  <figcaption class="figure-caption">ESP-WROOM32 </figcaption>
</figure>

Fine, if your goal is to get something *working*, it's probably not a good idea
to use Rust for WiFi enabled toy devices. But if you want to do something *fun*,
doing this with Rust is a **great** idea!

So how to get WiFi working with embedded Rust? The answer is simple: use a
microcontroller where you *can* use Rust and a WiFi *coprocessor*, where one
microcontroller runs your Rust program and the WiFi coprocessor runs its custom
firmware which has WiFi support. The firmware has its own TCP stack so the
interface between the two processor is fairly high-level, at the level of
"here's a password, connect to this network". The two microcontrollers would use
SPI or some other interface to talk to each other and transfer data.

So you need a microcontroller with WiFi support and a firmware to boot! Turns
out there are a few good choices: the [ESP-WROOM32](https://www.google.com/search?client=firefox-b-d&q=esp-wroom32) from Espressif running
the [Adafruit NINA-W102](https://www.google.com/search?client=firefox-b-d&q=esp-wroom32) firmware or [ATWINC1500](https://www.microchip.com/wwwproducts/en/ATwinc1500) from Microchip running
its own firmware. The nice thing about the Adafruit firmware is that there's a
[CircuitPython implementation with SPI](https://github.com/adafruit/Adafruit_CircuitPython_ESP32SPI), so reimplementing this in Rust looks
to be straightforward. The ATWINC1500 libraries are hidden somewhere in Atmel
Studio so I'm not going to dig that out just yet!

<figure class="figure float-sm-right w-25 ml-3">
  <img src="/images/airlift_breakout.jpg" class="figure-img img-fluid"/>
  <figcaption class="figure-caption">The ESP32-WROOM-32 is also available as a
  breakout with SPI support from <a href="https://www.adafruit.com/product/4201">Adafruit</a>.</figcaption>
</figure>

The alternative would be to build WiFi support yourself on some microcontroller
that has WiFi. With the ESP32 being badly supported by LLVM and thus Rust, the
other option is ATWINC1500 which is built on the Cortus APS3, building Rust for
that is another here-be-dragons I'd rather not explore. Lastly, there's the
[WM-N-BM-09](https://www.acalbfi.com/be/IoT-and-Wireless/WiFi-802-11/p/WiFi-IoT-Module--IEEE-802-11-b-g-n/0000008OKP) from USI that is a STM32F205RG paired with a Broadcom 43362 WiFi
module. This is available in the [Adafruit WICED Feather](https://www.adafruit.com/product/3056) and the [Particle
Photon](https://docs.particle.io/photon/). With STM32 being widely supported in embedded Rust, it should be
possible to write a WiFi program on such a microcontroller. Then there's the
[u-blox NINA W102](https://www.u-blox.com/en/product/nina-w10-series) which is another ESP32 based WiFi microcontroller, used in
various [Arduino WiFi products](https://store.arduino.cc/arduino-wifi-shield).

That said, building a WiFi "firmware" in Rust is quite a Herculean task, though
not impossible! You essentially need a functioning TCP/IP stack and implement a
WiFi layer on top. That would be possible with [smoltcp](https://www.googlpe.com/search?client=firefox-b-d&q=smoltcp), a Rust TCP/IP stack
suitable for embedded devices.

However, for the time being, I think I will stick with using ESP32-WROOM or
ATWINC1500 with preloaded WiFi ready firmware. Here's a comparison table of the
different WiFi microcontrollers I found:

{:.table.table-bordered.table-sm}
| Microcontroller | Architecture    | "Coprocessor" firmware | Interface | Free SDK/library                    |
|:----------------|:----------------|:-----------------------|-----------|:------------------------------------|
| ESP-WROOM32     | Xtensa LX6      | Several[^2]            | SPI       | WiFiSpi (C), Adafruit CircuitPython |
| u-blox W102     | Xtensa LX6      | Several                | SPI       | *ditto*                             |
| ATWINC1500      | Cortus APS3S    | Yes, proprietary       | SPI, UART | Arduino WiFi101 (C)                 |
| WM-N-BM-09      | ARM (STM32F205) | Several[^1]            | SPI       | Several                             |

[^1]: Depends on the vendor, Adafruit is based on 
    [Cypress WICED](https://www.digikey.com/en/resources/wiced-iot-platform)
    which is proprietary, but the Particle Photon uses FreeRTOS.

<figure class="figure float-sm-right w-25 ml-3">
  <img src="/images/atwinc1500.jpg" class="figure-img img-fluid"/>
  <figcaption class="figure-caption">There's also a breakout for the ATWINC1500.</figcaption>
</figure>

Based on the chart I would go either with the ESP32-WROOM-32 or the
ATWINC1500. The ESP32-WROOM-32 is both cheaper and easier to develop for compared
to the ATWINC1500, but the ATWINC1500 seems to be a bit more performant and
reliable.

Anyway, this led me to choose ESP32-WROOM-32 as the WiFi "coprocessor". What's
next is writing a Rust library that can control the ESP32 over SPI. This should
be fairly straightforward, since I can essentially reimplement the [Adafruit
CircuitPython ESP32-SPI driver](https://github.com/adafruit/Adafruit_CircuitPython_ESP32SPI) in Rust. That's going to be fun! First I'll
need a development board, I'll most likely use the [Adafruit AirLift Shield](https://www.adafruit.com/product/4285)
on top of a [Adafruit Metro M0](https://www.adafruit.com/product/3505). Why the Metro M0? Well, it has a JTAG header
so I can use SWD to debug what's going on, instead of repeatedly flashing the
binary to the bootloader.

Once I have the board, the next step is to build the SPI interface and some sort
of socket abstraction that works over the SPI interface. Seems like there is no
[real abstraction for
sockets](https://github.com/rust-embedded/embedded-hal/issues/146), and there's
no `#![no_std]` library for things like HTTP let alone MQTT... this is going to
be interesting! 

To put it simply, the Rust embedded ecosystem isn't super mature yet. It's
getting there. That's not a problem, if I really need to get my toy device (like
a temperature sensor over WiFi), I can write the necessary Python/Arduino C++ in
a few hours, and I have something that works. But a large part of my resurgent
hobby electronics adventures is being able to write Rust in bare-metal
systems. The breadboarding and soldering parts are fun as well, but my main
interest is in programming. Anyway, this looks like a pleasant challenge! 

[^2]: There's [Arduino NINA](https://github.com/arduino/nina-fw) ([Adafruit's
    fork for ESP32-WROOM-32](https://github.com/adafruit/arduino-esp32)),
    [NodeMCU](https://nodemcu.readthedocs.io/en/master/) and so on. 
