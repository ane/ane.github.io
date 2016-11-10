---
layout: page
title: About
---

<div class="row">
    <div class="col-sm-12 col-lg-10 offset-lg-1">
        <div class="card bg-faded float-sm-right ml-2 mt-3" style="width: 258px">
            <img class="card-img" src="/images/me.jpg" style="width: 100%">
        </div>
        <h2>About</h2>
        {% capture my-include %}{% include me.md %}{% endcapture %}
        {{ my-include | markdownify }}
    </div>
</div>
