---
layout: post
title: Half stack frameworks
date: 2016-10-30
tags:
  - web
  - ruby
  - react
  - javascript
---

In my previous post, I discussed [how web development had become weird]({% post_url
2016-10-26-web-development-has-become-weird %}). In this post, I will discuss what exactly is it
that makes it so weird. I will also present an alternative to JavaScript-based SPAs that look and
behave like them, yet at the base are built using standard full-stack frameworks. They can leverage
modern JavaScript libraries like React and compilers like Babel while simultaneously avoiding the
confusing tooling ecosystem and providing a rich and responsive user experience, all the
while retaining an pleasant developer experience.

## What exactly is wrong with the tooling ecosystem?

I think, largely, the reason why web development has become weird was that front-end development
cannot figure itself out. We are wasting effort and time by building more and more elaborate
abstractions that fundamentally exist only because of an unhappy accident: the web is the *only*
cross-platform application container. It is also a very accessible medium. To create a web
application, fundamentally, one needs to present the right kind of mark-up to a browser that renders
it.

Let's stop here. Just because the web became what it is by accident, doesn't make it a bad thing in
itself. Everybody *loves* platform independence. Everybody loves accessibility. The web is easy to
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

But I digress. That is more of a problem with software development in general. We can review a more
concrete example: the JavaScript tooling ecosystem. To develop front-end in JS, you need three
different tools;

* A package manager - npm, bower or yarn
* A module bundler - webpack, rollup or browserify
* A task runner - gulp, grunt, brunch

Each of these segments work completely differently. So to get started with, that's three different
tooling systems you have to learn. Better yet, each individual tool inside each system is unique in
its configuration syntax. So if you learn how to configure Grunt you will have to learn Gulp and
Brunch from scratch. Joy.

Yeah, yeah, I get it. Bower was cool because it built flattened trees when npm didn't. Gulp had a
nicer configuration syntax, and Brunch was easy to get started with. Yarn is more secure and more
reliable than npm. Webpack can inline your CSS and images and is more configurable than Browserify.

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
Joneses all the time and learning a new tool every year?

When it comes to the first question, remember Joyent and the io.js schism. *Oops*. As to the second,
I doubt it. Still, this is what we have to live with. A
[guide](https://github.com/verekia/js-stack-from-scratch) for building a modern JS front-end app
consists of *twelve* distinct steps, all of them quite elaborate. I applaud the author for the
gargantuan effort in that tutorial: it's the best I've seen so far. But seriously, take a look at
it! What the fuck?! I could have just rewritten my previous post with a link to that guide and
rested my case!

I remember a [book](http://www.charlespetzold.com/pw5/) about Windows programming using C, and parts
of this guide are arcane enough to evoke memories of *that*. I think one can enumerate the type
system of Scala using less. Or how to write a Scheme interpreter. 

The usability of the tooling ecosystem is absolutely disgraceful. No other developer segment has
this many hoops to jump through and nobody else has to learn so many different tools just to get a
simple web application running.

Why do we put up with this? Why isn't any effort being put into simplifying the tooling stack,
instead of making it more elaborate, powerful, and verbose? Consider webpack. It is a powerful
utility that is supposed to combine all your assets --- that is, code, CSS, images --- into a single
module that is used in your application. This is a powerful thing. The only problem is that its
configuration is *hell*. I work with SBT every day, and my goodness, even SBT is easier to
configure than Webpack. Ask any Scala developer what it means to say that. You will get funny looks.

## SPA development is more than just tools

The problems don't stop here. A SPA must effectively handle client state *entirely* in the browser,
though in ~~isomor~~universal SPA apps part of the rendering and client state is processed on the
server. This requires the use of architectural patterns
like [Redux](https://github.com/reactjs/react-redux)
and [React Router](https://github.com/ReactTraining/react-router). 

These libraries are nice and intelligent, but I feel they are a wasted abstraction. Using the trick
below I can create React apps that match closely the performance of a real SPA app, without having
to rely on these libraries.

**Caveat lector**. This is largely a matter of taste. If you really like Redux and React Router, by
all means use them, but I find their usability to be sub-par to the MVC architecture of any
full-stack framework. The architectural pattern --- Flux --- is a message-based event loop. The
views generate user actions (button clicks) that are dispatched to stores (state containers) which
update themselves (increment a number) then deliver state changes (an incremented number) to the
views which re-render themselves. If a request is sent to the server, it must be split into two
parts: first, a button click is registered, and its effect is rendered; second, a request is sent to
the backend and when it completes, an action describing a completed request is sent to the message
dispatcher. So any interaction with the backend requires two actions. Sounds complicated? Yeah, this
is why I prefer a dumb MVC architecture.

## In summary

So, to put this argument into a more cogent form, I'll summarize them below.

**Not enough emphasis is placed in making the tooling stack usable.** Why doesn't anyone integrate
dependency management, module bundling and task running under the same program? Why do we have to
use three different programs that are getting replaced every year? Tool "monoliths" like SBT may be
ugly in parts, but they can do package management, compilation, debugging, testing -- even if it's
DSL is garish and confusing, still, once you're familiar with it, you don't have to master six other
horrifying DSLs. Just one.

**People chase innovations in the stack with little care about their impact on maintainability.** Babel lets us
write JS in eleventy different dialects. While that is a cool thing in itself, it a horror show for
developers. You ask, who wouldn't want to use `await`, or ES6 classes? Well, how about the person
who doesn't want to *learn how to use Babel*?

With Babel, you can write in any version of JavaScript you want,
since it all gets compiled down to ES5 anyway. This is great for building your
flavor-of-the-month hack, but it's also a terrific way of building unmaintainable software. For
this zany *hack* to work, you need ~~tra~~compilers that translate your modern code to old code. The
requirement of that tool is too high a price to pay for some fancy language features.

**Monolithic full-stack frameworks may be dated in parts but they generally possessively exemplary
usability**. Clojure developers have found a way of eschewing frameworks over composable
libraries. For some reason, everybody else is really bad at this, so we build frameworks, i.e., sets
of libraries that govern the design of your program in a certain way. Monolithic frameworks like
Rails or Django are fundamentally dated --- though this is easily fixed --- but they are
usable. Setting up a functional application with these takes a few minutes, and it just works.

## A solution: renovation instead of rebuilding

In my opinion, front-end development can be done in an alternate, saner way. It doesn't mean going
back to the stone age of Apache or Rails with ActiveRecord. Rather, it means refurbishing these old,
battle-tested technologies with modern components without tossing the whole chassis into the
bin. 

In other words, there is an alternative to the current JavaScript SPA horror show. Using the
following technologies, as an example:

A REST API built in a scalable and performant language
:  *Examples: Scala, Go, Clojure, Java, Rust, OCaml, Elixir*
  
   This gives us a clear advantage when scaling and deploying our application. Data access is made
   opaque and is in no way tied to the front-end - which is ultimately just presentation and some
   client state. The language needs the following:
   
   * A stable library ecosystem, especially for data access, e.g., database drivers
   * A functioning web server and associated libraries
   * Speed, multi-threading, performance
   
   With these properties, you should be quite comfortable in your back-end development.
  
Client state, presentation and back-end communication handled using a monolithic framework
:  *Examples: Ruby on Rails, Django, Pyramid, MeteorJS, Udash*

   Rails may be dated in some parts --- coupling your front-end with data access is one thing --- but
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
  # maps to GET /foos (on the front-end)
  def index
    @foos = Foo.all.to_json
  end 
  
  # maps to POST /foos (on the front-end)
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

Now `Foo.find(1)` maps to `GET /foos/1` in the back-end.

The view is generated by `app/views/foos/index.html.erb`

```erb
<%= 
react_component(
  'Foos', 
  { foos: @foos, token: form_activity_token, action: url_for(action: 'create') }, 
  { prerender: true }
) 
%>
```

This maps to a React component `app/assets/javascripts/components/foos.es6.jsx`:

```javascript
class Foos extends React.Component {
  render() {
    <div>
      <ul>
        {this.props.foos.map((foo) => {
           return <li>{foo.bar}</li>
        })}
      </ul>
      // dataRemote is a Rails trick that makes the form make an XHR
      <form action={this.props.action} method="POST" dataRemote="true">
        <input type="hidden" name="authenticity_token" value={this.props.token} />
        <input type="text" name="bar" value="Blah blah" />
        <input type="submit" value="Add!" />
      </form>
    </div>
  }
}
```

Try doing that with less code in any JS app! The controller looks like any standard Rails
controller. In fact, it is exactly like one, yet the magic of React & Turbolinks lets us wrap this
into a SPA-like experience.

Combining these elements, we get **an application that can reach nine-tenths of the performance and
responsiveness of a 100% JavaScript SPA, while simultaneously avoiding the messy tooling ecosystem**.

* A total absence of extraneous tooling, the framework has these built-in. No need for Webpack or
  Babel, these are just another gems you add to your dependency list.

* A boring, but familiar, framework that handles routing, message dispatch and API integration for
  us. Routing and state management are the worst parts of SPA development. Now our state is just
  another Rails

* Responsiveness close enough to that of a real SPA. It will never match a real SPA in speed, since
  the requests map to Rails controllers, but it will be extremely pleasant to develop in.
  
* A scalable back-end without any data access logic in the front-end (the usual front-end back-end
  split), the framework handles only UI state and presentation logic. 
  
### A functioning example

I've created a functioning example and put it into two repositories:

* Front-end -- Rails 5 & react-rails & Her -- <https://github.com/ane/rails-react-frontend>

  A Rails 5 app combining react-rails and Her to talk to the back-end.
  
  To install, clone the repo, run `bundle install`, run `foreman start`. This will start the Rails
  server and the live reloader.

* Back-end -- <https://github.com/ane/rails-react-backend>

  It's a dead simple Sinatra REST API that uses Sqlite3. This is obviously not suitable for
  production.
  
  To install, clone the repo, run `bundle install`, run `rackup`.
  
This application will *never* match a real SPA. A part of the front-end is not in the browser, so we
will rely on a second web-server to run it. So it is an *illusion*, but as an illusion it is close
enough, and it is *easy to use*.
  
## Conclusion

JavaScript front-end development, as it currently stands, is painful to develop in. One has to
master many command line tools that instead of being unified as a single tool, each continue to
diverge and grow larger and more powerful. The result is a confusing developer experience.

In this post, I showed that we can scrape the good parts of modern JS developments and use them to
modernize an older application stack that mimics the user experience of a SPA, but is not one. The
application uses a clever library --- Turbolinks --- to convert page requests into XHRs, creating an
illusion of a single-page application. By combining this with React we get smooth and rapid page
reloads, since React can diff the DOM changes incoming in the XHRs and update the page quickly. 

The end result is a *half-stack framework*: we yank data access from a monolithic full-stack
framework (Rails) and make it use a REST API and we replace its presentation logic (ERB) with
React. The framework is left to handle client state, routing and asset pipelining, which are the
painful parts of SPA development, and the UI is rendered using React. So the Model--View--Controller
is distributed into three places: Rails for UI state, React for UI rendering, and the REST API is
the actual business logic. Effectively, this reduces Rails to a thin SPA-like front-end over a REST API!

Where to go from here? Here are some interesting things that could be explored:

* **GraphQL**. Although Her is nice, we could use [GraphQL](http://graphql.org/) when communicating
  with the backend. Not sure how compatible with Rails this is. 
* **TypeScript**. I like static typing, but currently react-rails doesn't really work that well with TypeScript.
* **React On Rails**. A
  different [kind of React & Rails integration](https://github.com/shakacode/react_on_rails), which
  lets you use Webpack. React On Rails is more flexible than react-rails: you get the full power of
  Webpack and NPM here, so this is both good and bad.

The future is going to be interesting!
