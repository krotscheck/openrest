---
title: Frequently Asked Questions
linkTitle: FAQ
toc_hide: true
menu:
  main:
    weight: 10
---

### Why does this exist?

Because arguing about API design is a waste of your organization's time.

### Is there a certification process?

Not yet. If you're interested in helping to build one, please reach out.

### Are there verification tools?

Not yet. If you're interested in helping to build one, please reach out. In particular I'd like to
see an OpenAPI linter of some sort.

### Is this document final?

Mostly. I'm still playing with the taxonomy and categories, and I'm open to pull requests on adjacent topics,
but the core of the contract is unlikely to change.

### It's not possible to describe \<thing\> in a RESTful way, therefore your contract is invalid.

You're probably not describing a resource then, so a bit of thought on what you're trying to accomplish
should help you. Key rotation, for example, can be re-framed as creating a new key.

### I notice that you don't care much about side effects.

That's because I'm a pragmatist and not a purist. If you're going to rotate an encryption key by creating a new one,
the old key needs to be deactivated. If you're good about documentation, these kinds of side-effects will be clearly
outlined so users of your endpoints can understand what's about to happen.

Speaking of which, how's your documentation?

### What about private API's?

No. "Oh, that's a Private API" is short for "I don't want to document this, I don't want to support it, and I
don't want to apply the same level of technical rigor to it as I do my public API's."

Once you expose and endpoint, it's public.

### Schema first or code first?

OpenREST itself has no opinion on this.

Speaking Personally, I'm a Schema-first kind of person. Document and design your API first, then use a generator
to stub it out and fill in the business logic later. My reasons are process, not technical:

- As a single document, changes to the public schema are immediately visible to all stakeholders.
- A single source of truth can be used to generate stubbing code for both the server and multi-language client
  libraries.
- Your Technical Writers can start writing documentation before the code is even written, and won't have to learn
  the entire codebase to do so.

I've come across the argument - especially in agile teams - that the documentation should live with the code and it's
the engineer's responsibility to keep it up to date. I've yet to find an engineer that is good at writing documentation,
and can do so even when under time pressure to ship a particular feature.

### What about OAuth2?

Special purpose documents such as RFC-6749 are out of scope for this contract. I'm not trying to rewrite
how you authorize, I'm trying to declare how to access resources once you are.

### What about JSON schema?

It's a great tool for defining the structure of a JSON document, but it's not a great tool for defining the
structure of an API.

### Why not use OpenAPI?

OpenAPI, as a successor to swagger, is a way to describe the calls, but not define the structure of those
API's themselves. It's still possible to build a completely unusable or obtuse set of API's, and describe
them perfectly in OpenAPI.

Having said that, yes, please, use OpenAPI. Just make sure you're describing something that's sane.

### What about gRPC?

gRPC is a great tool for building high-performance, low-latency services. It's not a great tool for building
public contracts unless you also want to take on the burden of building a client library for every language.

### Why don't you just use GraphQL?

GraphQL is not REST-ful. It's a great tool to provide server side aggregation and cross-referencing of resources when
a client doesn't want to load and run the subqueries themselves to support a particular business operation. However,
it was designed with Querying in mind, and has had CRUD operations bolted on after the fact.

To be frank: I see these approaches as complementary - a GraphQL query scheduler can very easily act as a point of
aggregation for a collection of RESTful resources. In fact, if provided a consistent contract such as this one,
it can do this largely automatically.

### What about HATEOAS?

Nobody uses it. It's a great idea, however it focuses on making resources in a system machine-discoverable,
not human-discoverable. It's humans that write the clients. For all practical use cases, Web Linking
via [RFC-8288](https://datatracker.ietf.org/doc/html/rfc8288) is perfectly fine.

### Why not SOAP?

Listen, if business-action style RPC calls were the correct solution to this problem, we'd all still be using SOAP.
But we're not, so let's not have this argument again.

### What about WSDL's?

If you're using WSDL's, you're probably using SOAP. See above.

### What about CORBA?

Now you're just trolling.