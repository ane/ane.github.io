--- 
layout: post 
date: 2018-01-01T00:00 
title: Staticity and dynamicity in remote APIs
---

Staticity versus dynamicity in remote APIs

The comparison between REST APIs and RPC APIs is interesting. They both serve the same purpose: to
interact with a remote system. The manner in which they are different is also interesting. 

What is really interesting is that their apparent difference is much more fundamental than plain
protocol or data level differences. It is a question of staticity vs dynamicity. This requires
proper framing, so I will explain why *that* is the question.

The fundamental principle of REST is it exposes data. To be precise, it exposes a data store and a
language, *verbs*, for interacting with it. This language is universal. A REST API that exposes blog
posts works, or should work, the same way as one that exposes a shop inventory. Similar verbs have
similar meaning. A POST operation creates a resource in both APIs. A GET operation that doesn't
single a resource returns a set.

RPCs expose interaction using commands. It is in the name: remote procedure calls. A REST API hides
a deletion behind a DELETE verb. A RPC API exposes a delete_post or delete_product command.  What is
the point of either? A REST API empowers the client with a stateless, resource-oriented
interface. It is very low level, but since it is only data, it gives a lot of freedom to the
user. The user can choose his or her way on how to interactive, the user isn't bound to any language
or framework.


This language adds a bit of overhead. What is more, the language is not precise. A PUT operation
should be idempotent, POST should create a new resource, and so on. 

Here's the issue: they don't always. Variations are common. These are the grey areas in which the
value proposition of REST tends to destabilize.  REST as an integration language isn't that much of
a guarantee it's made up to be.

The biggest problem is documentation. To interact with a system, having access to its data and a
limited vocabulary to change it, is not enough.

How do you hide a blog post? This in the documentation. It says use a PUT (or PATCH) operation to
set its visible status to false. To change the category of a product, update its category field to
the ID of the category you want it assigned to.

This isn't visible in the data! Plain data does not describe its use cases. You need meta-level
information, like documentation, to learn these.

In this context, with use case I mean any functionality the underlying system. Deleting a blog post,
adding a product to the catalog, starting a business process, or turning off a virtual machine.

RPCs gives explicit access to the use cases. Method names are visible and explicit, change_category,
toggle_post_visibility, do_credit_scoring. The meaning of those commands, the use cases, are visible
in either names or documentation.

As interactions come and go, RPCs are static. Worse, they aren't generic. The foundations of a
generic REST API client are usually more flexible. The verbs are the same, right? Repurposing the
client will be, in the general case, easier than a comparable RPC client.

Here be dragons, though. RPCs come in many flavours. There are protocol-based (XMLRPC, SOAP,
JSONRPC), which do contain reusable parts. They are inherently dynamic, converting any method call
into a RPC.

The other line of of RPCs are more static. Thrift, gRPC, WSDL ... they are documents describing the
interface. The language of the document is formal. The interface builds by translating these
documents into callable methods.

The usefulness of this approach is big. Since the structure of the document is formal, you can use
it for any purpose. Not only can you generate a client library, you can use it to generate
documentation. Of course, this requires writing the documentation in the description.

There is safety in staticity, but it isn't free. Writing the document is hard work. It
requires understanding the description language. Editing them might require tools, as was the case
with WSDL. When the specification changes, so does the document. When the document changes, so does
the code.

What about hybrid approaches? Here we have techniques like the *command pattern*. This is a REST API
design pattern. In the command pattern a REST API might use its language to describe its use
cases. Besides getting the data of a resource, you could retrieve a list of the operations you can
do with it.

The system might even audit your access to the command list, and control it. Depending on who you
are, you might get a different list of commands.

So this makes it dynamic.

