---
title: List Queries
weight: 4
description: Listing and searching collections of resources.
---

In addition to basic CRUD operations, clients frequently list or search within resource sets. This breaks down
into two different use cases: that of a UI, where a list with filters and a search box are offered to a user, and that
of a machine client, which is usually only interested in a full list of resources.

There are also two RESTful philosophies around resource lists. The first is "Read all resources in a collection", which
is usually implemented as a `GET` request. The second is "Build a result set based on a query", which is usually
implemented as a `POST` request. Since we are prescribing a very rich and featured query language, it becomes
impractical to express all these options in the URL of a `GET` request, forcing us to adopt the second philosophy.

## The Query Path

Since performing a `POST` request on the root resource is already assigned to creating a resource of that type,
we require a dedicated endpoint for querying resources. For generated result sets, we also require a subresource
hierarchy to allow for pagination and sorting.

```text
POST /v1/resources/query
GET /v1/resources/query/<result_set_id>
GET /v1/resources/query/<result_set_id>/<page_id>
```

## Requests

Our query endpoints construct their requests using the following three components:

- [Filtering and Searching]({{< ref "searching-and-filtering" >}}) - Which are both optional, yet exclusive.
- [Pagination and Sorting]({{< ref "pagination-and-sorting" >}}) - Which are both optional.
- [Projection]({{< ref "pagination-and-sorting" >}}) - Which is optional.

```http
POST /v1/resources/query HTTP/1.1

{
    // Pagination and Sorting as per that spec.
    "start": "....",
    "limit": ....,
    "sort": ....,

    // As per our Searching and Filtering spec
    "search": "...",
    "filters": ....
}
```

## Responses

List responses are a complex topic, as they can be quite large, require sophisticated pagination, and can be
time-consuming to generate. As such, we require that all list responses - regardless of implementation - at least
pretend to perform background processing to build the result set.

The response to a query request may be one of two types: a direct response, or a deferred response. The direct response
is the simplest, and is returned when the result set is already available. It contains the result set as described
below, but must also contain the `Content-Location` header to indicate the actual URL of the provided result set.

```http
HTTP/1.1 200 OK
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"
Last-Modified: "Wed, 21 Oct 2015 07:28:00 GMT"
Content-Location: https://api.example.com/v1/resources/query/<result-set-identifier>/1

{
    "results": [
        ....
    ]
}
```

A deferred response is returned when the result set is not yet available, or if you simply want to pretend like it's not
available yet. In this case, the server should return a `201 Created` response with a `Location` header pointing to the
first page of the result set.

```http
HTTP/1.1 201 Created
Location: https://api.example.com/v1/resources/query/<result-set-identifier>/1
```

Once redirected, if the page of the request is not yet ready, the server must return `202 Accepted` response with an
appropriate `Retry-After` header, and an [error response]({{< ref "../structure/common-error-responses" >}}) body
that can assist in remediation.

```http
HTTP/1.1 202 Accepted
Retry-After: 30
Cache-Control: no-store

{
    "error": "not_ready",
    "error_description": "A text description about how much longer it might take."
}
```

Once the result set is ready, the server should return a `200 OK` response with the result set, as well as the
following headers:

- `ETag` - A hash of the result set, used for caching, as described in
  [Entity Versioning]({{<ref "../api-fundamentals/entity-versioning-and-conflict-management" >}}).
- `Last-Modified` - The last-modified date of the most recently modified resource in the result set.
- `Cache-Control` with the `max-age` field, to communicate to the client when a result set will be considered stale.

```http
HTTP/1.1 200 OK
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"
Last-Modified: "Wed, 21 Oct 2015 07:28:00 GMT"
Cache-Control: max-age=3600
Link: <https://api.example.com/v1/resources/query/<result-set-identifier>/2; rel="next"

{
    "results": [
        ....
    ]
}
```

### Empty results

An empty result set should - for the first page - include a `200 OK` response with an empty result set, and no `Link`
locations.

```http
HTTP/1.1 200 OK
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"
Last-Modified: "Wed, 21 Oct 2015 07:28:00 GMT"
Cache-Control: max-age=3600

{
    "results": []
}
```

### Access Rights Violations

Access rights violations come in three types:

1. A request has an invalid authorization token.
2. A request has not been granted permission to read this resource type.
3. A request is constrained to only a limited set of the available resources.

In the first case, the service should respond with a `401` response according to our common errors specification.
The second, similarly, should return `403`. For all other requests, the result set should be constrained only to the
resources which the user is authorized to see. Even if explicitly named in a filter, if a user cannot see that
resource, the result set should be empty.
