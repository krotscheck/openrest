---
title: Projection
description: How to selectively reduce the size of the data returned in a result set.
weight: 3
tags:
  - queries
  - projection

---

Projection allows a client to specify which fields it is interested in. This permits further optimization
on client queries, however this feature should only be implemented if it is business critical. It is - in the
strictest sense of the term - a premature optimization.

With that in mind, a client may add either an `include` or an `exclude` list to the query. If both are present,
the server should respond with a `400 Bad Request` error.

| Property | Relevance | Type         | Description                                                  |
|----------|-----------|--------------|--------------------------------------------------------------|
| include  | request   | string array | An optional list of fields to include in response objects.   |
| exclude  | request   | string array | An optional list of fields to exclude from response objects. |

```http
POST /v1/resources/query HTTP/1.1

{
    // Optional list of fields to include or exclude from the result objects.
    "projection": {
        // Either "include" or "exclude" must be specified!
        "include": ["fieldName1", "fieldName2"],
        "exclude": ["fieldName3"]
    }
}
```
