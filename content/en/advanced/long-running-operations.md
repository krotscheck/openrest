---
title: Long Running Operations
weight: 2
description: What to do when an action takes a bit longer.
tags:
  - advanced
  - async
---

All systems have SLO's and SLA's, and it's not often possible to satisfy a request within the given constraints. There
are also security concerns about timing attacks, and you may need to ensure that any given request is not being used
to probe the details of your system. For this purpose, we offer the following behavior to standardize handling these
kinds of events.

## Deferred Responses

The first response to a long-running operation should be to accept the request. The following status codes may be used.

- `201 Created` - When a creation of a resource has been requested, but is not yet complete.
- `202 Accepted` - When a modification to a resource is requested, but is not yet complete.

In both cases, the server should return a `Location` header to inform the client where it may poll the results.

```http
HTTP/1.1 202 Accepted
Location: https://api.example.com/v1/resources/deferred/<status-identifier>
```

## Polling

Most clients will redirect to the `Location` header automatically, though not all of them will continue to poll the
results. The initial result should be a `202 Accepted` response with a `Retry-After` header to inform the client how
long it should wait before polling again. The body of the result should be an indicator on the status of the request.

```http
HTTP/1.1 202 Accepted
Retry-After: 2
Cache-Control: no-store

{
    "error": "not_ready",
    "error_description": "A text description about how much longer it might take."
}
```

## Successful Result

Once a request is complete, the server should return a `204 Found` response with no body, and a `Location` header to
once again redirect the client to the final result.

```http
HTTP/1.1 204 Found
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"
Last-Modified: "Wed, 21 Oct 2015 07:28:00 GMT"
Cache-Control: max-age=3600

{
   ... response body
}
```
