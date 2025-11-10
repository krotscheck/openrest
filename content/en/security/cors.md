---
title: Cross-Origin Resource Sharing
linkTitle: CORS
description: A full implementation of the W3C's Cross-Origin Resource Sharing (CORS) specification is required.
weight: 3
tags:
  - required
  - headers
  - security
---

A proper implementation of the W3C's Cross-Origin Resource Sharing [CORS](https://www.w3.org/TR/cors) specification can
greatly improve the utility of your API, and permits deployment decoupling between your clients and your UI. It can also
cause quite a bit of hand-wringing by your security team, if not used correctly. The trick to know is that all CORS
vulnerabilities stem from the use of Cookies for session management.

For the purposes of this contract, CORS support is required. While you can figure out the details of your implementation
from the W3C specification, the following is a narrative overview of how the protocol works.

### Preflight Request

For any Fetch or XMLHttpRequest that modifies a resource, the browser will first send a preflight request to the server
to ask if it is allowed to make this request. This will contain the `Origin` header containing the domain name of the
requesting site, the http Method of the request in the `Access-Control-Request-Method` header, and any non-simple
headers in the `Access-Control-Request-Headers` header.

The server then responds by indicating which methods, headers, and domain is permitted. Note that if you do not
use Cookies, you can safely use the wildcard `*` value for the `Access-Control-Allow-Origin` header, which greatly
simplifies your implementation.

```http request
OPTIONS /namespace/v1/resources/{id} HTTP/1.1
Origin: https://api.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: X-Requested-With, Content-Type

HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://api.example.com
Access-Control-Allow-Methods: PUT, GET, OPTIONS, DELETE
Access-Control-Allow-Headers: X-Requested-With, Content-Type
Access-Control-Max-Age: 86400
```

### Main Request

For simple GET requests, or for other requests which have passed the preflight check, the client will only send
the `Origin` header, which will contain the protocol, host, and port of the requesting site. The server will
successfully execute the request, however it will inform the browser whether it's allowed to see that data by
setting the `Access-Control-Allow-Origin` header.

```http request
POST /namespace/v1/resources/{id} HTTP/1.1
Origin: https://api.example.com
Content-Type: application/json
X-Requested-With: XMLHttpRequest

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://api.example.com
Vary: Accept-Encoding, Origin
Content-Type: application/json
```
