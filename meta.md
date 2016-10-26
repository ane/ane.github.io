---
layout: page
title: About
---

<div class="row">
<div class="col-sm-9">
{% capture my-include %}{% include me.md %}{% endcapture %}
{{ my-include | markdownify }}

<h3>Archive</h3>
<p>Here's an archive of the site's contents.</p>

{% if site.posts.size > 0 %}
<h5>Blog</h5>
<ul>
    {% for post in site.posts %}
    {% if post.category == nil %}
    <li><a href="{{ post.url }}">{{ post.title }}</a> &mdash; <date class="text-muted">{{ post.date | date: "%-d %B, %Y" }}</date></li>
    {% endif %}
    {% endfor %}
</ul>
{% if site.categories.essays.size > 0 %}
<h5>Essays</h5>
<ul>
{% for post in site.categories.essays %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
{% endif %}
{% else %}
<h3>:-(</h3>
<p>I'm sorry, but there are no posts.</p>
{% endif %}
</div>
<div class="col-sm-3">
<div class="card card-block">
<h5 class="card-title">Tag Cloud</h5>
{% assign tags = site.tags | sort %}
{% for tag in tags %} <span class="site-tag"> <a href="/tags.html#{{ tag | first | slugify }}" style="font-size: {{ tag | last | size | times: 32 | plus: 50  }}%">{{ tag[0] | replace:'-', ' ' }}{% unless forloop.last %}{% endunless %}</a> </span> {% endfor %}
</div>
</div>
</div>
