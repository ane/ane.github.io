---
layout: post
title: Half stack web frameworks
disqus: true
date: 2016-11-02
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
<!--break-->

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

To put this into context, we must understand that currently, most software is disposable. Because
software is disposable, we eagerly toss a half-functioning solution into the bin and rewrite it,
rather than taking it apart and rebuilding a better version. This leads to programs getting
rewritten and rewritten, sometimes doing things differently but most of the time it's just the same
thing under a different layer of paint.

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
configuration is *hell*. I work with SBT every day, and my goodness, even SBT is easier to configure
than Webpack. Ask any Scala developer what it means to say that. You will get funny looks. Even Java
folks will consider this crazy, although, in fairness, they've
[moved into the post-framework age](http://microprofile.io/), and consider us mortals rather quaint.

## SPA development is more than just tools

The problems don't stop here. A SPA must effectively handle client state *entirely* in the browser,
though in ~~isomor~~universal SPA apps part of the rendering and client state is processed on the
server. This requires the use of architectural patterns
like [Redux](https://github.com/reactjs/react-redux)
and [React Router](https://github.com/ReactTraining/react-router). 

These libraries are nice and intelligent, but I feel they are a wasted abstraction. Using the trick
below I can create React apps that can approximate the performance of a real SPA app, without having
to rely on these complicated architectural patterns.

**Caveat lector**. This is largely a matter of taste. If you really like Redux and React Router, by
all means use them, but I find their usability to be sub-par to the MVC architecture of any
full-stack framework. The architectural pattern --- Flux --- is a message-based event loop. The
views generate user actions (button clicks) that are dispatched to stores (state containers) which
update themselves (increment a number) then deliver state changes (an incremented number) to the
views which re-render themselves. If a request is sent to the server, it must be split into two
parts: first, a button click is registered, and its effect is rendered; second, a request is sent to
the back-end and when it completes, an action describing a completed request is sent to the message
dispatcher. So any interaction with the back-end requires two actions. Sounds complicated? Yeah, this
is why I prefer a dumb MVC architecture (or Relay).

## In summary

So, to put this argument into a more cogent form, I'll summarize them below.

### 1. Lack of emphasis on usability, a myopic focus on adding features. 
Why doesn't anyone integrate dependency management, module bundling and task running under the
same program? Why do we have to use three different programs that are getting replaced every year?
Tool "monoliths" like SBT may be ugly in parts, but they can do package management, compilation,
debugging, testing -- even if it's DSL is garish and confusing, still, once you're familiar with it,
you don't have to master six other horrifying DSLs. Just one.

### 2. Chasing novelty with little care about its impact on maintainability.
Babel lets us write JS in eleventy different dialects. While that is a cool thing in itself, it a
horror show for developers. You ask, who wouldn't want to use `await`, or ES6 classes? Well, how
about the person who doesn't want to *learn how to use Babel*?

With Babel, you can write in any version of JavaScript you want,
since it all gets compiled down to ES5 anyway. This is great for building your
flavor-of-the-month hack, but it's also a terrific way of building unmaintainable software. For
this zany *hack* to work, you need ~~tra~~compilers that translate your modern code to old code. The
requirement of that tool is too high a price to pay for some fancy language features.

### 3. Snubbing full-stack frameworks for their want novelty, although they generally feature exemplary usability

Clojure developers have found a way of eschewing frameworks over composable
libraries. For some reason, everybody else is really bad at this, so we build frameworks, i.e., sets
of libraries that govern the design of your program in a certain way. Monolithic frameworks like
Rails or Django are fundamentally dated --- though this is easily fixed --- but they are
usable. Setting up a functional application with these takes a few minutes, and it just works.

## A new direction: renovate, not rewrite

In my opinion, front-end development can be done in an alternate, saner way. It doesn't mean going
back to the stone age of Apache or Rails with ActiveRecord. Rather, it means refurbishing these old,
battle-tested technologies with modern components without tossing the whole chassis into the
bin. 

In other words, there is an alternative to the current JavaScript SPA horror show. Using the
following technologies, as an example:

1. **A REST API built in a scalable and performant language**

   *Examples: Scala, Haskell, Go, Clojure, Java, Rust, OCaml, Elixir*
  
   This gives us a clear advantage when scaling and deploying our application. Data access is made
   opaque and is in no way tied to the front-end - which is ultimately just presentation and some
   client state. The language needs the following:
   
   * A stable library ecosystem, especially for data access, e.g., database drivers
   * A functioning web server and associated libraries
   * Speed, multi-threading, performance
   
   With these properties, you should be quite comfortable in your back-end development.
  
2. **Client state, presentation and back-end communication handled using a monolithic framework**

   *Examples: Ruby on Rails, Django, Pyramid, MeteorJS, Udash, Play*

   Rails may be dated in some parts --- coupling your front-end with data access is one thing --- but
   as an infrastructure it is functional, mature, easy to understand and *stable*. The Ruby ecosystem
   is large and is well documented, even the secondary documentation (StackOverflow etc.) is abundant.

3. **A wrapper that turns ordinary HTTP page requests into XHRs**

   *Examples: Turbolinks (for Ruby on Rails and Django)*
  
   Turbolinks is perhaps a hack but it is clever: any HTTP request that would normally cause a page
   reload, like a link or a form submission, is converted into an XHR. Then, the page redraws itself
   by swapping out the `<body>` element from the returned response.

Turbolinks is a "pseudo-SPA" application in that it simply reroutes ordinary page requests (links,
form submissions) as XHRs and then from the new page, it __merges__ the `<head>` element and __swaps__
the `<body>` element. By using a gem like `react-rails` you can combine this with react, however, it
does **not** use React's virtual DOM when redrawing the `body` content. It only mounts and unmounts the
components when the page swaps, retaining the actual DOM bindings. 

## What?! Your answer is *Rails*? *In 2016*?

Just because these frameworks aren't making headlines doesn't mean they are stuck in the stone
age. These monolithic frameworks still, after years of maturation, possess novelty value in one,
unparalleled aspect: usability. These frameworks may not lend themselves to universal applications,
but they're still capable of absorbing new technologies like
[websockets](http://edgeguides.rubyonrails.org/action_cable_overview.html) and
[GraphQL](https://github.com/rmosolgo/graphql-ruby).

Some parts of them are stuck in the past, of which the most striking one is combining data access
with data control and presentation in the same program. This is easily fixed: make your Rails
controllers call an external, opaque service to render is data. The job of the full-stack framework
is reduced to managing client state and data presentation, which go together.

So, what can be done? Here's an example.
   
## A REST-backed Rails app with React as the templating engine

[react-rails](https://github.com/reactjs/react-rails) is a Rails gem that gives us React components
in the asset pipeline, supporting server-side rendering and Turbolinks (caveat: see above)

Under the hood, when rendering on the server, react-rails uses
[Babel](https://github.com/babel/ruby-babel-transpiler) and
[ExecJS](https://github.com/sstephenson/execjs) to prerender the content. Better yet, your content
is still rendered by a simple Rails controller like the following.

The controller lives in `app/controllers/foos_controller.rb`:

```ruby
class FoosController < ApplicationController
  # maps to GET /foos (on the front-end)
  def index
    # incurs a GET /foos on the back-end
    @foos = Foo.all.to_json
  end 
  
  # maps to POST /foos (on the front-end)
  def create
    # this is a POST /foos on the back-end
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

Now `Foo.find(1)` maps to `GET /foos/1` in the back-end, and so forth.

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
  
There are some obvious compromises in such a solution, which are both good and bad.

#### Compromises made

The biggest compromise is in performance, which is due to the following:

* **Does not use React's DOM to its full power**. Turbolinks just swaps the `body` element. This
  could be improved by making it use the React virtual DOM. This is the bad part. The good part is
  that we don't have to create XHRs ourselves in React components.
  
* **Forces the user to use JSX, throws ERB/HAML in the bin**. It is true that the example
  application could be indeed built without JSX --- just don't use react-rails --- but I find JSX to
  be a nicer templating syntax than ERB. advantage of React
  
  But it would be naïve to assume this brings us the whole of *React*. It brings us the *templating
  syntax* and binding mechanisms, but since Turbolinks effectively causes a re-rendering of the
  *whole* HTML page, this doesn't fully leverage the server-side rendering aspect of React. 
  
  So, overall, the good part of this compromise is that we get to use JSX, which has a nicer,
  functional approach compared to ERB, but the bad part is that we don't harness the full power of
  React.
  
* **Turbolinks effectively reverses React server-side rendering**. Whereas in a normal SPA app the
  server-side rendering is the "base" template, in this case a *new* server-side rendering is
  produced on every interaction. In a normal SPA app, one just updates the DOM with new *state* ---
  i.e., props --- not with a new **DOM**.
  
  There is a solution: skip Turbolinks and use XHRs in React components. A simple solution in a
  controller:
  
  ```ruby
  def create
      @f = Foo.create(:bar => params[:bar])
      if request.xhr?
        # send a JSON of all the Foos
        render :json => Foo.all.to_json
      else
        # send HTML with a React component
        redirect_to action: 'index'
      end
  end
  ```
  
  If the request is made from a component, it's can now use `setState` (or a store) to update its
  new state. In this paradigm, Rails is acting as the state store.
  
  A better example would be to make the Rails app support GraphQL and use Relay to communicate with
  the Rails part, see below.
  
I think, given the simplicity of the above application, I think it's fair to say that these
compromises are warranted. If the actual set-up were any more complicated I wouldn't be so
certain. But, for the simplicity, we must trade performance.
  
### A functioning example

I've created a functioning example and put it into two repositories:

* Front-end -- Rails 5 & react-rails & Her -- <https://github.com/ane/rails-react-frontend>

  A Rails 5 app combining react-rails and Her to talk to the back-end.
  
  To install, clone the repo, run `bundle install`, run `foreman start`. This will start the Rails
  server and the live re-loader.

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
illusion of a single-page application. 

The end result is a *half stack web framework*: we yank data access from a monolithic full-stack
framework (Rails) and make it use a REST API and we replace its presentation logic (ERB) with
React. The framework is left to handle client state, routing and asset pipelining, which are the
painful parts of SPA development, and the UI is rendered using React. So the Model--View--Controller
is distributed into three places: Rails for UI state, React for UI rendering, and the REST API is
the actual business logic. Effectively, this reduces Rails to a thin SPA-like front-end over a REST API!

Where to go from here? Here are some interesting things that could be explored:

* **Turbolinks with React**. Use React to parse the HTML returned by Turbolinks (if rendered on the
  server) and use the React virtual DOM to update the DOM, instead of blindly swapping the `body` element.
* **GraphQL**. Although Her is nice, we could use [GraphQL](http://graphql.org/) when communicating
  with the backend **and** also use it as a communication method between Rails and React.
* **TypeScript**. I like static typing, but currently react-rails doesn't really work that well with TypeScript.
* **React On Rails**. A
  different [kind of React & Rails integration](https://github.com/shakacode/react_on_rails), which
  lets you use Webpack. React On Rails is more flexible than react-rails: you get the full power of
  Webpack and NPM here, so this is both good and bad.
  
All in all, this solution is a compromise. 

Compared to a full-stack Rails app, we have to do extra work in creating a REST API backend, but the
result is an app that's easier to manage due to the separation of concerns. With a separate data
access layer --- the REST API --- complex business logic is contained in a single place. It is easy
to couple several clients to such a front-end, and our Rails app is just one of these.

But, compared to a full-fledged SPA, this app will never be as quick, it will never be as fluid, and
it may not be what cutting-edge front-end development this day represents, but it is is *simple*,
there is *one* build tool (bundler), and it is *fun* to develop in. 

I might miss fancy things like state hydration and Redux, but the insanity of Webpack, Gulp, Babel
and NPM, I will **not** miss.
