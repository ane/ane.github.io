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
 <div class="micro">
 <a href="{{ site.url }}{{ post.url }}" class="micro-date">
   {{ post.date | date: "%B %d, %Y %H:%M"}}
 </a>
 
 {{ post.content }}
 </div>

 {% unless forloop.last %}
   <hr>
 {% endunless %}
{% endfor %}
