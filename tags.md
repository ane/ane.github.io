---
layout: page
title: Tags
---

<div class="row">
<div class="col-sm-12 col-lg-10 offset-lg-1">
{% include tagcloud.html %}
<p>
Here are all posts sorted by their tags.
</p>

<!-- Get the tag name for every tag on the site and set them
to the `site_tags` variable. -->
{% capture site_tags %}{% for tag in site.tags %}{{ tag | first }}{% unless forloop.last %},{% endunless %}{% endfor %}{% endcapture %}

<!-- `tag_words` is a sorted array of the tag names. -->
{% assign tag_words = site_tags | split:',' | sort %}

{% for item in (0..site.tags.size) %}{% unless forloop.last %}
{% capture this_word %}{{ tag_words[item] }}{% endcapture %}
<h4 class="hilink" id="{{ this_word | cgi_escape }}">{{ this_word }} <small class="text-muted">{{ site.tags[this_word].size }} posts</small></h4>
<ul>
{% for post in site.tags[this_word] %}{% if post.title != null %}
<li><a href="{{ post.url }}">{{ post.title }}</a> &mdash; <date class="text-muted">{{ post.date | date: "%-d %B, %Y" }}</date></li>
{% endif %}{% endfor %}
</ul>
{% endunless %}{% endfor %}
</div>
</div>


