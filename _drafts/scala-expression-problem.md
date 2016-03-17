---
layout: post
title: Scala and the Expression Problem
disqus: true
date: 2016-03-17
tags: 
  - plt
  - scala
---

I previously wrote about the [expression problem in OCaml]({% post_url 2016-01-08-the-expression-problem-as-a-litmus-test %}), 
and I thought I'd continue the series and
talk about how the problem can be avoided in Scala. Unsurprisingly, the most idiomatic Scala
solution is actually quite unique and relies on sub-traits and trait inheritance.

Let's rewind. The expression problem asks this:

> The goal is to define a datatype by ases, where one can add new cases to the datatype and new
> functions over the datatype, without recompiling existing code, and while retaining static type
> safety (e.g., no casts).


