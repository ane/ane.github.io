---
layout: page
permalink: /micro
title: Microblog
---

{:.text-muted}
This is my microblog. This is cross posted to
[micro.blog/ane](http://micro.blog/ane). There is a [RSS feed](/feed-micro.xml) available.

{% assign micro = site.micro | sort: 'date' | reverse %}

{% for post in micro %}
<div class="micro micro-lg" id="{{ post.date | date: "%Y%m%d%H%M" }}">
  <h6 class="text-uppercase">
    <a style="color: #bbb;" href="{{ site.url }}{{ post.url }}">{{ post.date | date: "%A, %B %d, %Y at %H:%M" }}</a>
  </h6>
  
  {{ post.content }}
  
  {% unless forloop.last %}
    <hr class="my-4"/>
  {% endunless %}
</div>
{% endfor %}
