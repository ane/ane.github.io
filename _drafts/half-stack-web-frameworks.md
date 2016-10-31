---
layout: post
title: Half stack web frameworks
date: 2016-10-30
tags:
  - web
  - ruby
  - react
  - javascript
---

In my previous post, I discussed [how web development had become weird]({% post_url
2016-10-26-web-development-has-become-weird %}). In this post, I will discuss what exactly is it
that makes it so weird, and I will also a present an alternative to JavaScript SPAs that completely
avoids the JavaScript tooling ecosystem. Such an application is much nicer to develop in, and is
still able to leverage modern technologies like React. This is achieved by using a combination of an
old but stable framework combined with some modern plugins.

## What's wrong with the tooling ecosystem?

I think, largely, the reason why web development has become weird was that frontend development
cannot figure itself out. We are wasting effort and time by building more and more elaborate
abstractions that fundamentally exist only because of an unhappy accident: the web is the *only*
cross-platform application container. It is also a very accessible medium. To create a web
application, fundamentally, one needs to present the right kind of markup to a browser that renders
it.

Let's stop here. Just because the web became what it is by accident, doesn't make it a bad thing in
itself. Everybody *loves* platform independency. Everybody loves accessiblity. The web is easy to
develop for and it can reach almost everybody. This is a reality we have to deal with, a reality in
which web development is (a) popular, (b) ubiquitous and (c) easy.

The combination of those properties creates an interesting melting pot of rapidly evolving
technologies. Rapid progress is a nice thing in itself, but a bad thing to the ecosystem when it
evolves blindly. Web development doesn't evolve blindly, rather, it is myopic. 

## Progress, progress, progress!

To put this into context, we must understand that currently, most software is disposable. This does
not have to be the case but it is. Because software is disposable, we eagerly toss a
half-functioning solution into the bin and rewrite it, rather than taking it apart and rebuilding a
better version. This leads to programs getting rewritten and rewritten, sometimes doing things
differently but most of the time it's just the same thing under a different layer of paint.

This isn't an ethical argument: competition is absolutely necessary, to supplant you sometimes need
to kill, to compete you sometimes need to copy.

Case in point? JavaScript tooling ecosysetm. Fundamentally, Gulp, Grunt, and Brunch all do the same
thing. Just a bit differently, and which technology eventually wins is *still* unclear. Browserify
and Webpack. Bower, npm and now yarn.

Seriously, what the fuck?

I get it. Bower built flattened trees when npm didn't. Gulp had a nicer configuration syntax. Brunch
was fast to get started with. Yarn is more secure and more reliable. Webpack can inline your CSS and
is more configurable.

## Not about killing innovation

At this point, you may be wondering that I desire a world in which there is but one alternative to
every task. This is not the case. I only ask for reservation: if there are no fundamental
ideological differences, if there are no personal incompatibilities between the developing
organizations, is there any valid argument for building your own version of a tool, instead of
contributing to an existing system?

I don't think this is the case **at this scale** --- obviously, a world with just one kind of tool
or library for one thing is stupid, but the sweet spot does definitely not lie at *seven*. 

So if the answer is no, does that mean JavaScript developers are so strange that they cannot get
their heads together and agree on something? Do they really think people enjoy keeping up with the
joneses all the time and learning a new tool every year?

When it comes to the first question, remember Joyent and the io.js schism. *Oops*. As to the second,
I doubt it. Still, this is what we have to live with. A
[guide](https://github.com/verekia/js-stack-from-scratch) for building a modern JS frontend app
consits of *twelve* distinct steps, all of them quite elaborate. I applaud the author for the
gargantuan effor in that tutorial: it's the best I've seen so far. But seriously, take a look at
it! What the fuck?! I could have just rewritten my previous post with a link to that guide and
rested my case!

I remember a [book](http://www.charlespetzold.com/pw5/) about Windows programming using C, and parts
of this guide are arcane enough to evoke memories of *that*. I think one can enumerate the type
system of Scala using less. Or how to write a Scheme interpreter. 

Why do we put up with this? Why isn't any effort being put into simplifying the tooling stack,
instead of making it more elaborate, powerful, and verbose?

## In summary

My misgivings with the current state of JavaScript development can be summarized as
follows.

#### An aversion towards monolithic tooling is good for the tools but bad for the programmers
 
Why doesn't anyone integrate dependency management, module bundling and task running under the
same program? Why do we have to use three different programs that are getting replaced every year?
SBT may be ugly in parts, but it does do package management, compilation, debugging, testing --
even if it's DSL is garish and confusing, still, once you're familiar with it, you don't have to
master six other horrifying DSLs. Just one.

#### A carefree attitude towards standardization

Babel lets us write JS in eleventy different dialects. While that is a cool thing in itself, it a
horror show for developers. You ask, who wouldn't want to use `await`, or ES6 classes? Well, how
about the person who doesn't want to *learn how to use Babel*?

With Babel, you can write in any version of JavaScript you want,
since it all gets compiled down to ES5 anyway. This is great for building your
flavour-of-the-month hack, but it's also a terrific way of building unmaintainable software. For
this zany *hack* to work, you need ~~tra~~compilers that translate your modern code to old code. The
requirement of that tool is too high a price to pay for some fancy language features.

#### Monoliths are boring but they are usable

Clojure developers have found a way of eschewing frameworks over composable libraries. For some
reason, everybody else is really bad at this, so we build frameworks, i.e., sets of libraries that
govern the design of your program in a certain way. Monolithic frameworks like Rails or Django are
fundamentally dated --- though this is easily fixed --- but they are usable. Setting up a
functional application takes a few minutes, and it just works. But it's not as cool since you
can't use fancy things like React or JSX. And your application doesn't do seamless page
transitions!

## A solution: renovation instead of rebuilding

In my opinion, frontend development can be done in an alternate, saner way. It doesn't mean going
back to the stone age of Apache or Rails with ActiveRecord. Rather, it means refurbishing these old,
battle-tested technologies with modern components without tossing the whole chassis into the
bin. 

In other words, there is an alternative to the current JavaScript SPA horror show. Using the
following technologies, as an example:

A REST API built in a scalable and performant language
:  *Examples: Scala, Go, Clojure, Java, Rust, OCaml, Elixir*
  
   This gives us a clear advantage when scaling and deploying our application. Data access is made
   opaque and is in no way tied to the frontend - which is ultimately just presentation and some
   client state. The language needs the following:
   
   * A stable library ecosystem, especially for data access, e.g., database drivers
   * A functioning web server and associated libraries
   * Speed, multithreading, performance
   
   With these properties, you should be quite comfortable in your backend development.
  
Client state, presentation and back-end communication handled using a monolithic framework
:  *Examples: Ruby on Rails, Django, Pyramid, MeteorJS, Udash*

   Rails may be dated in some parts --- coupling your frontend with data access is one thing --- but
   as an infrastructure it is functional, mature, easy to understand and *stable*. The Ruby ecosystem
   is large and is well documented, even the secondary documentation (StackOverflow etc.) is abundant.

A wrapper that turns ordinary HTTP page requests into XHRs

:  *Examples: Turbolinks (for Ruby on Rails and Django)*
  
   Turbolinks is perhaps a hack but it is clever: any HTTP request that would normally cause a page
   reload, like a link or a form submission, is converted into an XHR. Then, the page redraws itself
   using a...
  
A templating engine that can redraw the DOM quickly

:  *Examples: React, Clearwater*

   Since the page is effectively re-requested, we need a rendering engine that can redisplay this
   updated DOM content quickly. Using Turbolinks, a `201 Created` response --- a server-side React
   rendering --- is fetched automatically using a XHR, and is finally re-rendered lightning
   fast on top of the old DOM using React, which will not redraw the whole page.
   
## An example: react-rails

With Rails, by using [react-rails](https://github.com/reactjs/react-rails), every page request is transformed
into a XHR. When the request completes, React redraws the prerendered content **quickly** on top of the old by
using its internal virtual DOM. Under the hood, react-rails uses
[Babel](https://github.com/babel/ruby-babel-transpiler) and
[ExecJS](https://github.com/sstephenson/execjs) to prerender the content. Better yet, your content
is still rendered by a simple Rails controller like the following.

The controller lives in `app/controllers/foos_controller.rb`:

```ruby
class FoosController < ApplicationController
  # maps to GET /foos
  def index
    @foos = Foo.all.to_json
  end 
  
  # maps to POST /foos
  def create
    Foo.create(:bar => params['bar'])

    # turbolinks turns this into a XHR
    redirect_to '/foos'
  end
end
```

The model is just a [Her](https://github.com/remiprev/her) model, an ORM that uses a REST API, which
you can customize. In `apps/models/foo.rb`:

```ruby
class Foo < Her::Model
  attributes :bar, :id
end
```

Now `Foo.find(1)` maps to `GET /foos/1` in the backend.

The view is generated by `app/views/foos/index.html`

<pre class="highlight"><code><span class="cp">&lt;%=</span> <span class="n">react_component</span><span class="p">(</span><span class="s1">'Foos'</span><span class="p">,</span> <span class="p">{</span> <span class="ss">foos: </span><span class="vi">@foos</span> <span class="p">},</span> <span class="p">{</span> <span class="ss">prerender: </span><span class="kp">true</span> <span class="p">})</span> <span class="cp">%&gt;</span></code></pre>

Which is actually a React component `app/assets/javascripts/components/foos.es6.jsx`:

<pre class="highlight"><code><span class="kr">class</span> <span class="nx">Foos</span> <span class="kr">extends</span> <span class="nx">React</span><span class="p">.</span><span class="nx">Component</span> <span class="p">{</span>
  <span class="nx">render</span><span class="p">()</span> <span class="p">{</span>
    <span class="p">&lt;</span><span class="nt">div</span><span class="p">&gt;</span>
      <span class="p">&lt;</span><span class="nt">ul</span><span class="p">&gt;</span>
        <span class="si">{</span><span class="k">this</span><span class="p">.</span><span class="nx">props</span><span class="p">.</span><span class="nx">foos</span><span class="p">.</span><span class="nx">map</span><span class="p">((</span><span class="nx">foo</span><span class="p">)</span> <span class="o">=&gt;</span> <span class="p">{</span>
          <span class="k">return</span> <span class="p">&lt;</span><span class="nt">li</span><span class="p">&gt;</span><span class="si">{</span><span class="nx">foo</span><span class="p">.</span><span class="nx">bar</span><span class="si">}</span><span class="p">&lt;/</span><span class="nt">li</span><span class="p">&gt;;</span>
        <span class="p">})</span><span class="si">}</span>
      <span class="p">&lt;/</span><span class="nt">ul</span><span class="p">&gt;</span>                              // makes the request asynchronous
      <span class="p">&lt;</span><span class="nt">form</span> <span class="na">action=</span><span class="s2">"/foos"</span> <span class="na">method=</span><span class="s2">"POST"</span> <span class="na">dataRemote=</span><span class="s2">"true"</span><span class="p">&gt;</span>
        <span class="p">&lt;</span><span class="nt">input</span> <span class="na">type=</span><span class="s2">"text"</span> <span class="na">name=</span><span class="s2">"bar"</span> <span class="na">value=</span><span class="s2">"Blah blah"</span> <span class="p">/&gt;</span>
        <span class="p">&lt;</span><span class="nt">input</span> <span class="na">type=</span><span class="s2">"submit"</span> <span class="na">value=</span><span class="s2">"Add!"</span> <span class="p">/&gt;</span>
      <span class="p">&lt;/</span><span class="nt">form</span><span class="p">&gt;</span>
    <span class="p">&lt;/</span><span class="nt">div</span><span class="p">&gt;</span>
  <span class="p">}</span>
<span class="p">}</span>
</code></pre>

This looks like any standard Rails controller. In fact, it is exactly like one, yet the magic of
React & Turbolinks lets us wrap this into a SPA-like experience.

Combining these elements, we get **an application that can reach nine-tenths of the performance and
responsiveness of a 100% JavaScript SPA, while simultaneously avoiding the messy tooling ecosystem**.

* A total absence of extraneous tooling, the framework has these built-in. No need for Webpack or
  Babel, these are just another gems you add to your dependency list.

* A boring, but familiar, framework that handles routing, message dispatch and API integration for
  us. Routing and state management are the worst parts of SPA development. Now our state is just
  another Rails

* Responsiveness close enough to that of a real SPA. It will never match a real SPA in speed, since
  the requests map to Rails controllers, but it will be extremely pleastant to develop in.
  
* A scalable backend without any data access logic in the front-end (the usual front-end back-end
  split), the framework handles only UI state and presentation logic. 
  
### A functioning example

I've created a functioning example and put it into two repositories:

* `rails-backend` - https://github.com/ane/rails-backend

  It's a dead simple Sinatra REST API that uses Sqlite3. This is obviously not suitable for
  production.
  
  To install, clone the repo, run `bundle install`, run `rackup`.
  
* `rails-frontend` - https://github.com/ane/rails-frontend

  A Rails 5 app combining react-rails and Her to create the above app.
  
  To install, clone the repo, run `bundle install`, run `foreman start`. This will start the Rails
  server and the live reloader.
  
## Conclusion
  

  
