---
title: Path Patterns
tags:
  - required
  - paths
---

This section covers rules around paths used in your API's. It ensures that all paths are consistent, easy to understand,
and easy to implement. It's divided into four sections: Resources, Queries, Rules, and Examples.

## Resource Paths

All paths to resources must adhere to this pattern. Components of this pattern are described below.

- `/<version>/<resourcename>/<id>`

#### \<version\>

The version section is there to allow for multiple versions of the same resource to exist simultaneously as your
software goes through various lifecycles. This is a common pattern in API design, and it is important to get right, so
use a simple, incrementing integer for versioned paths in your api: v1, v3, v333. If it is necessary to introduce a
major breaking change, all paths in that API must increment at the same time, even though they may not have any changed
code. This is to assist your lifecycle; by gathering breaking changes all together and implementing them all at once,
you can deprecate them on the same schedule.

- `/v1/resourcename`
- `/v2/renamed_resource`

#### \<resource_name\>

A resource name should always be plural and use snake_case.

#### \<id\>

If an obvious identifier is not available, such as the ID of an upstream cloud resource or an identifier derived from
dependent sources, IDs should be a V4 UUID seeded from a strong random source. This field is only relevant if you are
directly addressing an individual resource.

### Example: A Widget API

Let's assume you have an API that modifies Widgets. These would be your endpoints:

- `POST /v1/widget/`         # Create a new instance
- `GET /v1/widget/{id}`      # Read a specific resource
- `PUT /v1/widget/{id}`      # Update an entire resource instance
- `DELETE /v1/widget/{id}`   # Delete a part of a resource

## Query paths

It is difficult to express a complex set of query parameters in a URL’s query string. Therefore,
all actions that ask for the creation of a result set - List, Aggregation, Graph, or otherwise - must be
POST operations with the query expressed in the request body. A side-effect of this is that a commonly used
list endpoint is not used in our API contract, as the POST action on that route is already used for resource creation.

Specific payloads and semantics are described in more detail in their respective pages:

- [API List Queries]({{< ref "../queries/list-queries" >}})
- [API Aggregation Queries]({{< ref "../queries/aggregation-queries" >}})
- [API Graph Queries]({{< ref "../queries/graph-queries" >}})

### Example: A Widget API

For the above example, these would be the paths for list and aggregation queries.

- `POST /v1/widgets/query`      # List query (From [List Queries]({{< ref "../queries/list-queries" >}}) )
- `POST /v1/widgets/aggregate`  # Aggregation Query (From [Aggregation Queries]({{< ref "../queries/aggregation-queries" >}}) )

## API Rules

These are concrete rules to which all of paths must adhere.

### Sub-resources are undesirable

Sub-resources are a common usability improvement for an API, allowing easy scoping of a result set based on a parent
entity. They are permitted if any of the following is true:

- There is an explicit 1-to-N relationship between the parent and the child resource.
    - Example: There are many book reviews for one book.
    - Example: There are many reviews submitted by a single author.

- A child resource cannot be uniquely identified without its parent.
    - Example: Street numbers are meaningless without the street they are on.

It is important to consider what a sub-resource URL communicates to an API consumer.

- Does this subresource incorrectly imply a hierarchical relationship?
- Is the 1-to-N relationship between the parent and child likely to change in the long run?

If the answer to either of the above questions is yes, do not create a sub-resource. Instead, create a top-level
resource with its own query endpoints so a user can constrain their result set based on a relationship.

In the majority of cases, a sub-resource is not desirable. Consider the points above carefully before creating one.

#### Sub-resource path patterns

Note that a resource can have both a child access path and a top-level access path. In this case, the resource name in
the path MUST be identical for both the child route and the root resource route, and creation of a child resource
via the parent resource's path _MUST_ use the location header of the root path.

- `/v1/widget/<id>/sprocket/<id>`
- `/v1/sprocket/<id>`

### No Business Logic Actions

A REST API is, by design, an expression of the state of a system. Business logic actions can be roughly described as
permutation requests against this state, some of which can happen concurrently, while others happen asynchronously. Most
importantly, some of these actions cannot be done in parallel.

In order to prevent accidental parallel actions, or the conflation of ‘business logic actions' and our above
sub-resource requirements, it is required that all business logic must be expressed as entity permutations.

A common counterargument from the engineer’s perspective is that it is far easier to build a single-purpose endpoint
than a single all-purpose endpoint. This is true, but it forces the API user to build their own complex entity
validation and action routing. From their perspective, it is far easier to call a single endpoint for all business
operations than implement - and keep track of - multiple ones. Customer usability is more important than engineer
convenience.

#### Example: Running a report

- Do not call execute on a report...
    - `POST /v1/reports/0000000000000000/execute`

- Instead, ask to create a new snapshot
    - `POST /v1/report/00000000000/snapshot`

In this example, we are separating the concept of a report configuration, and the data generated by the report at a
specific point in time.

- Example API routes for the generated reports
    - `POST /v1/report/0000000000000000/snapshot/`
    - `POST /v1/report/0000000000000000/snapshot/query`
    - `GET /v1/report/0000000000000000/snapshot/{id}`

In this example, we are creating a new, explicit sub-resource that acts as a generated report snapshot for a specific
point in time. This allows the user to query the report, and retrieve the data at a specific point in time.
The response entity could include such useful status information as the state of the current report (if it is taking
some time), the current progress, and when it was started. Furthermore, the creation of a report can be
explicitly blocked if another one is already being run.

### No Resource Expansion

An individual resource must not expand any resources to which it is linked. Doing so can lead to memory pointer bugs in
clients, where multiple instances of a resource are created in memory, and the client has to manage the state of the
API.
