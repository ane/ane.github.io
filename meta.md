---
layout: page
title: About
---

I'm a Finnish&ndash;French software engineer living in Jyväskylä, Finland.

This blog is mainly about programming and software. For a bit of background, you can read a
[a meta post of sorts]({% post_url 2016-01-01-before-we-begin %}) that describes the tone of the
writings you will find on this site.

You can drop me an [email](mailto:ane@iki.fi) or find me on [Github](https://github.com/ane).

Everything on this site unless otherwise explicitly stated is licensed under
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

<section>
    {% if site.posts.size > 0 %}
    <h2 class="page-header">Blog posts</h2>
    <ul>
        {% for post in site.posts %}
        <li>
            <a href="{{ post.url }}">{{ post.title }}</a> &mdash; <date class="text-muted">{{ post.date | date: "%d %B, %Y" }}</date> 
        </li>
        {% endfor %}
    </ul>
    {% else %}
    <h3>:-(</h3>
    <p>I'm sorry, but there are no posts.</p>
    {% endif %}
    <h3>Tags</h3>
    {% assign tags = site.tags | sort %}
    {% for tag in tags %}
    <span class="site-tag">
        <a href="/tags/{{ tag | first | slugify }}/" style="font-size: {{ tag | last | size  |  times: 4 | plus: 80  }}%">{{ tag[0] | replace:'-', ' ' }}({{ tag | last | size }}){% unless forloop.last %},{% endunless %}</a>
    </span>
    {% endfor %}
</section>
