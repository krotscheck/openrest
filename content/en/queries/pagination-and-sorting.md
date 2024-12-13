---
title: Pagination and Sorting
description: Requirements around paging, sorting, and handling stale result sets.
weight: 1
---

## Pagination

There are two ways to paginate a result set: Next/Previous, and Offset/Limit. We understand that most User Interfaces
strongly prefer an offset/limit style, as it is more intuitive to human users. For the resource server, this provides a
technical challenge with scale, as many data stores (most notably document-based stores) will not know how many
documents match any given set of criteria until they have traversed the entire result set.

That's not to say they can't be used. For our purposes, however, we cannot create requirements in this contract which
themselves will not grow with the scale of the data. Falling back to use cases, it is (from experience) quite rare for
a human to page deeply into a result set, while a script loading all results is quite common. As such, we will only
support the Next/Previous style of pagination, optimizing for the most frequent use case.

Please note that a proper implementation of Aggregation queries can easily provide the necessary metadata to simulate
offset/limit style pagination, if that is a requirement for your use case. It is the responsibility of the client to
decide which method is most appropriate for their audience.

#### Example request

Here, we are submitting a query that will return the first 100 results of a resource.

```http
POST /v1/resource/query HTTP/1.1

{
    "start": "....",  // Optional ID of the first record to return.
    "limit": 100,     // The number of results to return, default 100

    // ... Sort and filter parameters, as appropriate for the query.
}
```

As there are more than 100 results, the response will include a `Links` header with a `next` link to the next page of
results, as per [RFC-5988](https://tools.ietf.org/html/rfc5988). It also includes an `ETag` - calculated from the
content, and a `Last-Modified` header, indicating the last-modified record in this set.

```http
HTTP/1.1 200 OK
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"
Last-Modified: "Wed, 21 Oct 2015 07:28:00 GMT"
Links: <https://api.example.com/v1/resource/query?start=....&limit=100>; rel="next"

{
    ... results as per the query type
}
```

| Property | Relevance | Type   | Description                                                                                                              |
|----------|-----------|--------|--------------------------------------------------------------------------------------------------------------------------|
| start    | request   | string | An optional start index from which the result should be read. This must be the ID of the first record of the result set. |
| limit    | request   | int    | An optional number of results to return in the page, with a default of 100.                                              |

## Sorting

Every resource must choose a human-relevant, intuitive dimension to use as a default sort. For example, a Report
service might choose to sort by name, while a Security Violations service may sort by severity or age. An API consumer
may then choose to use their own dimensions. They are expressed in order, as below.

#### Example request

```json
{
  "sort": [ // Note that the 'sort' field is optional.
    {
      "on": "age",         // The resource property to sort on.
      "order": "ASC|DESC"  // "ASC" or "DESC", representing ascending or descending sorts. Default is "ASC".
    },
    {                      // A second sort dimension, after the first is applied.
      "on": "name",
      "order": "ASC|DESC"
    }
  ]
}
```

Sorting inherently conflicts with searching; Searching provides its own implicit ordering by relevance, which would be
overridden by sort. Therefore, any request that includes both a search and a sort must return a `400` response
indicating that they are not compatible. For "Search and sort" style operations, please use wildcards in a filter.
