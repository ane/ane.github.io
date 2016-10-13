---
layout: page
title: About
---

<div class="row">
<div class="col-sm-9">
I'm a Finnish&ndash;French software engineer living in Jyväskylä, Finland. I work at [Qvantel](http://www.qvantel.com).

This is my website. There's a blog, which is mainly about programming and software. For a bit of background, you can read a
[a meta post of sorts]({% post_url 2016-01-01-before-we-begin %}) that describes the tone of the
writings you will find on this site. Longer, non-programming related essays are in the 'essay' category.

You can drop me an [email](mailto:ane@iki.fi) or find me on [Github](https://github.com/ane).

Everything on this site unless otherwise explicitly stated is licensed under
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). 

***

<h3>Archive</h3>

Here's an archive of the site's contents.

{% if site.posts.size > 0 %}
<h5>Blog</h5>
<ul>
    {% for post in site.posts %}
    <li><a href="{{ post.url }}">{{ post.title }}</a> &mdash; <date class="text-muted">{{ post.date | date: "%-d %B, %Y" }}</date></li>
    {% endfor %}
</ul>
{% if site.categories['essay'].size > 0 %}
<h5>Essays</h5>
<ul>
{% for post in site.categories['essay'] %}
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
{% for tag in tags %} <span class="site-tag"> <a href="/tags/{{ tag | first | slugify }}/" style="font-size: {{ tag | last | size | times: 32 | plus: 50  }}%">{{ tag[0] | replace:'-', ' ' }}{% unless forloop.last %}{% endunless %}</a> </span> {% endfor %}
</div>
</div>
</div>
