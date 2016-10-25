---
title: Web development has become weird
date: 2016-10-25
layout: post
tags:
  - web
---

Call me old-fashioned, call me a curmudgeon, but I think modern web development has become stupid
and superficial. The unending quest towards single-page apps (SPAs) has made web development 
extremely painful and the current trend is diverging towards seven different directions at once. On
one end, we have rich SPAs that can be built as native applications, or we have something
[completely orthogonal](https://github.com/ampproject/amphtml), of which a
[schism](https://timkadlec.com/2016/02/a-standardized-alternative-to-amp/) is beginning to form.

The underlying problem is unfortunately that the web is being misused as an application container
instead of the original text transport protocol it was made to be. It's no use crying over spilled
milk; the web has been subverted, transformed, improved upon, so much so we don't know what the
original even [might have looked like](we've subverted it, transformed it, no, *hijacked* and
improved it). I'm not complaining, the idea of the web of being "just" a
[Wikipedia](http://wikipedia.org) sounds *so* boring.

## How it was

In 2006, the hot new thing was Ruby on Rails or Django. If you weren't using them, odds were you
were using PHP or ASP.NET. Most intranet software ran on SharePoint or, I kid you not,
WordPress. Users didn't really care either way.

People liked Rails and Django because they made web development stupidly simple. No more SQL, just
create your models and migrations. An architecture that made sense, MVC, was applied and web apps
became a little bit better and the overall development experience improved about ten times as much.

Of course, the web was slower back then. Chrome wasn't around, so JavaScript usage was very
limited. Google began prototyping under-the-hood requests in Gmail around 2006, but before that
nobody had heard of AJAX. The concept of doing more than one page request per page load was
completely unheard of. The users liked faster page loads, so when Chrome came around with V8,
customers did suddenly give a shit about what browser they used.

## Where it all began

On the surface, the appeal in SPAs was obvious. It started with Gmail and AJAX. No more slow page
loads, the applications behaved like native applications, and soon they even
[looked](http://getbootstrap.com) like them! Innovative as that was, now we're beginning to use so many
web applications that are in the web *only* that we're slowly starting to forget what the native app
experience *was*. 

The problem was that it wasn't enough, you needed a *backend*. Before, when there was one
application, now there were *two*, and they usually were completely different from each other. The
backend--frontend split was fuzzy to begin with, this introduced an uncertainty and a possibly
pointless abstraction. Put the "slow" and "heavy" things to the backend, let the frontend handle
rendering and the user interface, all the backend had to do was supply serialized data. Even back then, people started asking
questions about the SEO effects of rendering a page entirely in JavaScript. No solution was given,
although one solution [existed, but was weird](https://www.meteor.com/).

So while the backend folks built eleventy versions of [Sinatra](http://www.sinatrarb.com/), the
frontend folks got busy. In a short time we had Backbone, Angular, and Knockout, then we got
frameworks like Durandal and Meteor.js. Finally, Facebook looked at the performance of desktop applications, then looked
at the performance of web applications, thought, "holy shit", and
[did something about it](https://facebook.github.io/react/). 

People got scared. It was mixing business and presentation logic, they said. It was mixing JavaScript
with something eerily like XML, and everyone said XML sucked. Then people got over their
usual trepidations towards $newTechnologyOfTheYear and got on with their lives. Now React is being
used [left](http://www.facebook.com) and [right](https://www.reddit.com/r/reactjs/comments/4iei7s/twitters_new_mobile_site_is_using_react_redux_and/).

The only problem was, React was a templating engine at heart. Facebook did not build a bridge for
existing frontend frameworks, so that people could have just dropped in React instead of say,
Handlebars or even ERB. Facebook did not do this because they already had their
[own way of rendering content](http://hacklang.org/). They didn't need one. Build your own, they
said.

Faced with just a templating engine, developers got confused. "How do I do routes with this?" they
asked. So we built [routing engines](https://github.com/ReactTraining/react-router) and
[state containers](https://github.com/reactjs/redux), and got on with our lives. Soon after that,
someone understood
[React ran quite fine on a Node.js server](http://jamesknelson.com/universal-react-youre-doing-it-wrong/),
and people started
[rendering pages in two places: the backend *and* the frontend](https://scotch.io/tutorials/react-on-the-server-for-beginners-build-a-universal-react-and-node-app).

Now, people are using React -- a JavaScript library to be run inside a browser -- to create
[native mobile applications](https://facebook.github.io/react-native/). Meanwhile, other folks think
all of this, this excession, is simply too much, and want [pages to load fast](https://www.ampproject.org/).

Couple this with the at least
[bizarre](https://medium.com/@kitze/how-it-actually-feels-to-write-javascript-in-2016-46b5dda17bb5#.jnsf71d1l)
experience of JavaScript development in 2016, things are looking weird. The tooling iterates at an
impossible speed, a new build system emerges every year, and developers must stay on top of things.

Having to stay on top of things is, generally, a good thing. Software progresses, it progresses so
fast that we *must* constantly learn for us to stay employable and the profession to stay
enjoyable. But at this speed, when it seems we're not really learning from the past, it's not doing
anyone any good. React took a good idea from desktop applications, event-driven user interface
rendering, and executed it brilliantly as they ported it to the web. 

The thing is, it's still *nothing* new. Ten years ago we were building crappy and weird-looking
software in C#, now we're building crappy and broken software in a mix of JavaScript and other
languages, and they run in the browser, or on smartphones, and they're responsive, so that when you
tilt your tablet sideways, that big fat menu disappears. Huh.

That's what they call the churn.

New technologies come and they kill the old technologies, but in the midst of it all, stand you and
I, wondering what the hell to do with this mess. From the other side of it all, from the ivory tower
of the real world, the business analysts cast their shadow and remind us these technologies are
tools, they're meant to be replaced, they're *disposable*. So are you, if you can't learn new ones.

It's not as bad as it sounds. We're learning, we're doing some
[cool things](https://clojurescript.org/) and [unifying](http://udash.io/) two halves of the same
thing. The backend guys are [innovating](http://mbrace.io/) and tooling progress is
[insane](http://mesos.apache.org/) and [exciting](http://kubernetes.io/). So I cannot state that we
haven't gotten anywhere, we *have* innovated, learned, and improved the Web. But by how much? Are
our end users happier?

Given the task of implementing a web application, what would I do, given the state of the art in
2016? Probably not much. Build a business logic API that can be used via REST or some other
RPC protocol. Use a [batteries-included](http://rubyonrails.org/) web framework to render the
frontend, but keep the frontend away from dealing with the database content. Build many frontends,
not just for the web, but for mobile and perhaps even desktop, and keep them thin. The web frontend
can be spiced up (but not replaced) using JavaScript. Come to think of it, I would have done the
same thing in 2006. 

In the end, I bet, with the exception of a few informed users, our end users still don't give a
shit. Oh well.
