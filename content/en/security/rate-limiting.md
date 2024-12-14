---
title: Rate Limiting
description: Return a consistent response when a client exceeds their quota.
tags:
  - optional
  - security
---

If your site requires some form of rate limiting, you must return a consistent
response when a client exceeds their quota. This response must use the `429` status code defined
in [RFC 6585 Section 4](https://www.rfc-editor.org/rfc/rfc6585.html#section-4), as well
as the `Retry-After` header defined
in [RFC 7231 Section 7.1.3](https://www.rfc-editor.org/rfc/rfc7231.html#section-7.1.3).
The `Retry-After` header should be set to the time at which the client can retry the request, using
the http-date type instead of the delta-seconds type.

For purpose of browser-level caching, the server may also include the `Vary` header.

```http
HTTP/1.1 429 Too Many Requests
Retry-After: Mon, 01 Jan 2018 00:00:00 GMT
Vary: Origin, Authorization
```
