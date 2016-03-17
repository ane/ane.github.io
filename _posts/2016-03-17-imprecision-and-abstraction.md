---
layout: post
title: Imprecision and abstraction
disqus: true
date: 2016-03-30
tags: 
  - general
  - fp
---

What is the point of abstractions? 

We want to hide things. We want to generalize things. We want to extend things.

Why are mathematical abstractions so intractable? Why is the 
[Wikipedia page on functors](https://en.wikipedia.org/wiki/Functor) incomprehensible to someone not
used to mathematical formalisms? Why does it sound so vague?

When approaching abstractions, for educational purposes, it is sometimes easier to think of
analogies or similes. We can conceptualize the idea of functors of "procedures" that operate on things inside
"boxes", or we can study relational algebra using Venn diagrams.

These analogies are dangerous, because they are vague. Formalisms leave no room for interpretation
because they are exact not whimsically, but because of the pervasive imprecision of the human mind.

Let's take an analogy that's very approachable but quite dangerous. Explaining modular arithmetic
can done with clocks. The analogy would go like this: 

> You see, when you have a number modulo 12, think of it as a clock. If x is over 12, think
> of like like the hand of a clock looping over, and you're back where you started.

The problem with such an analogy is that not everybody uses 12-hour clocks. Most of Europe uses a
24-hour clock with no distinction between AM and PM. Of course, they are also taught to understand
that "sixteen" means "four" since nobody builds 24-hour analog clocks (yet). That aside, it's still
very possible, that when explaining the above analogy to someone accustomed to 24-hour clocks,
they'll get confused since what comes after 12, is 13, not 0.

This is a basic but fundamental example: things like functors, semigroups, monads, and categories,
are a bit intractable for a reason: there's no room left for interpretation. 

Mathematical formalisms pare fundamental ideas into pure forms. Your intuition can't get in the way
and corrupt them.

The obvious downside is that these formalisms are harder to understand. I wager that this is for the
better because down the road there are concepts so high-level one can't even begin to think in
analogies, and it will only slow one down.

There was a turning point in my math studies when I stopped trying to grok things using
analogies. My approach to topology was geometrical. I tried to visualize
[limit points](https://en.wikipedia.org/wiki/Limit_point) in my mind and in vain, because the mind
can't bend itself around more than three spatial dimensions. Granted, visualizing
[hypercubes](https://en.wikipedia.org/wiki/Hypercube) was possible ("like a cube is made of sides, a
hypercube is made of cubes")... kind of.

Stopping this perilous habit, I started to memorize laws instead. That changed the language of maths
for me, forever. I wasn't understanding relations via shapes or arrows, but by basic axioms and
mathematical laws. It wasn't too long before I started to visualize concepts using these laws.

I stopped staring concepts in the eye, looking for hidden meanings behind
[bounded sets](https://en.wikipedia.org/wiki/Bounded_set). I simply read
the definition, thought "huh", and memorized it. Slowly, by building towards other related concepts
and set theory I quickly understood what the law meant, without trying to grok the hidden meaning.

Once that became a habit, it became easy and changed my approach forever: let go of
intuition. Abstract ideas are hard by definition and they need to be understood piece by piece, from
the ground up. 

This is why any explanation of a precise thought, like a mathematical formalism, using something
imprecise like an analogy, is a fallacy doomed to fail.

When functional programmers try to explain basic ideas like semigroups or functors, they often find
themselves in an apologetic mire of simplifications. This is doomed to fail. Give concrete examples
of how a functor works. Don't illustrate them as operations that can map stuff in boxes to other
boxes. Invent a problem and solve it using a functor. After all, they're such a basic concept, even
those writing non-functional code end up doing them all the time.

Let the abstraction sink in. Because it's the only thing that will survive.

