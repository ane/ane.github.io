---
layout: page
title: Tags
---

<div class="row">
<div class="col-sm-9">
Here are all posts sorted by their tags.

<!-- Get the tag name for every tag on the site and set them
to the `site_tags` variable. -->
{% capture site_tags %}{% for tag in site.tags %}{{ tag | first }}{% unless forloop.last %},{% endunless %}{% endfor %}{% endcapture %}

<!-- `tag_words` is a sorted array of the tag names. -->
{% assign tag_words = site_tags | split:',' | sort %}

{% for item in (0..site.tags.size) %}{% unless forloop.last %}
{% capture this_word %}{{ tag_words[item] }}{% endcapture %}
<h4 id="{{ this_word | cgi_escape }}">{{ this_word }} <small class="text-muted">{{ site.tags[this_word].size }} posts</small></h4>
<ul>
{% for post in site.tags[this_word] %}{% if post.title != null %}
<li><a href="{{ post.url }}">{{ post.title }}</a> &mdash; <date class="text-muted">{{ post.date | date: "%-d %B, %Y" }}</date></li>
{% endif %}{% endfor %}
</ul>
{% endunless %}{% endfor %}
</div>
<div class="col-sm-3">
<div class="card card-block">
<h5 class="card-title">Tag Cloud</h5>
{% assign tags = site.tags | sort %}
{% for tag in tags %} <span class="site-tag"> <a href="/tags.html#{{ tag | first | slugify }}" style="font-size: {{ tag | last | size | times: 32 | plus: 50  }}%">{{ tag[0] | replace:'-', ' ' }}{% unless forloop.last %}{% endunless %}</a> </span> {% endfor %}
</div>
</div>
</div>

