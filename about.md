---
layout: page
title: About
---

<div class="row" itemscope itemtype="https://schema.org/AboutPage">
    <div class="col-sm-12 col-lg-10 offset-lg-1">
        <div class="card bg-faded float-sm-right ml-3 mb-2" style="width: 150px">
          <img title="Reykjavik, Iceland, 2010 and a Romeo y Julieta No. 2." lass="card-img" src="/images/me.jpg" style="width: 100%">
        </div>
        {% capture my-include %}{% include me.md %}{% endcapture %}
        {{ my-include | markdownify }}
    </div>
</div>
