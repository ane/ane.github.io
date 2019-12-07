{% assign posts = include.collection | sort: "date" | reverse %}
{% for post in posts %}

[{{ post.title}}]({{ post.url }})
: {{ post.excerpt | truncatewords: 30 }}

{% endfor %}
