---
layout: page
title: About
---

<div class="row">
    <div class="col-sm-12 col-lg-10 offset-lg-1">
        <h2>About</h2>
        {% capture my-include %}{% include me.md %}{% endcapture %}
        {{ my-include | markdownify }}
    </div>
</div>
