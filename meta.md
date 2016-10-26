---
layout: page
title: About
---

<div class="row">
<div class="col-sm-9">
<h2>About</h2>
{% capture my-include %}{% include me.md %}{% endcapture %}
{{ my-include | markdownify }}

</div>
<div class="col-sm-3">
<div class="card bg-faded">
<img class="card-img-top" src="/images/me.jpg" style="width: 100%">
<div class="card-block">
<a class="h1 card-link" href="http://github.com/ane"><i class="fa fa-fw fa-github-square"></i></a>
<a class="h1 card-link" href="http://twitter.com/anewtf"><i class="fa fa-fw fa-linkedin-square"></i></a>
<a class="h1 card-link" href="http://twitter.com/anewtf"><i class="fa fa-fw fa-twitter-square"></i></a>
</div>
</div>
</div>
</div>
</div>
