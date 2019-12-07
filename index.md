---
layout: default
title: Home
---

## Welcome!

Hi! This is my website. I use it to write and share about things I do with
computers. Most of them are computer-related anyway, ranging from various
programming topics to electronics to general software development
practices. There's also a [blog](/blog/) that contains blurbs of thought in
chronological order.

### Writing

Things I've written in random order by category:

  * [Distributed tracing](/tracing/)
  * [Embedded development](/embedded/)
  * [Electronics projects](/projects/), also known as my personal *Internet of Shit*

### Recent blog posts

<ul>
{% for post in site.posts limit: 5 %}
 <li class="list-unstyled"><small class="text-muted text-monospace mr-1">{{ post.date | date: "%d %b %Y"}}</small> <a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
