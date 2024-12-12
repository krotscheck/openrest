---
title: Content-Type Negotiation
description: How to handle requests for different content types in your API.
weight: 3
---

Table stakes for this contract is that all APIs must support JSON as a request and response format. Additional formats
are left to the discretion of the service. For example, a report service may want to return `application/pdf`, while
some other services may prefer `application/yaml`.

```http
Content-Type: application/json
```

When creating a request, there are two components to consider:

1. What format the request is sending.
2. What format the request wants to receive.

In all cases, the API must support requesting and receiving `application/json`, assuming a body is sent/expected. There
are a variety of error cases that need to be outlined.

### Requests for HTML

In all cases where the requested response type is `Accepts: text/html`, the resource server has two choices. Either,
is to simply return a `415 Unsupported Media Type`. This is the easiest response, but also the least helpful. The better
choice is to ensure that your service also offers an API explorer style user interface, such as a Swagger-UI. In this
case, the server should return a `303 See Other` to this API explorer.

```http
POST /namespace/v1/entity
Accepts: text/html


HTTP/1.1 303 See Other
Location: https://api.example.com
```

### Request with unsupported body formats

If a request sends a body that is not supported, the server must respond with `415 Unsupported Media Type`.

```http
POST /v1/entity
Content-Type: text/unsupported


HTTP/1.1 415 Unsupported Media Type
```

### Requests for unsupported media types

If a client asks for a response in a media type that is not supported, we return a `400`.

```http
Accepts: text/unsupported


HTTP/1.1 400 Bad Request
```

### Requests for multiple media types

```http
Accepts: text/html, application/xhtml+xml, application/xml;q=0.9, image/webp, */*;q=0.8
```

It is common for browsers to ask for several HTML-like MIME types in standard HTTP requests, though it’s less common for
API requests. If a request such as this is received, the first most relevant media type that is supported by the API
must be observed.

#### Example 1
This resolves to a `Location` header, as outlined above.

```http
Accepts: text/html, application/json
```

#### Example 2

This resolves to `application/json`.

```http
Accepts: text/plain, application/yaml, application/json;q=0.4
```

### Requests for Files

In cases where a request is asking for a file response (such as a report), two approaches may be taken.

#### Approach 1: Build the file in JS

A UI can read JSON data and compose the format in memory. This is useful for small, ad-hoc reports and files, scripts
that need to be prepopulated with customer data (such as onboarding scripts), and other things that require decoration
with the current user context.

#### Approach 2: Redirect to a permanent storage location

For larger files, or for files that are generated and stored for later download, the file must be saved to an object
store, and the response should be a `302 Found` with a `Location` header pointing to the file with, most preferably,
a very short-lived signed URL.

**Request**

```http
GET /v1/report/my-report-id
Accepts: application/pdf


HTTP/1.1 302 Found
Location: <short-lived-download-url>
```

We are specifically using `302 Found`, because it instructs the browser to convert all requests to GET methods. Thus if
an HTTP request asks for a report generation, the POST operation to create that report will - upon completion - be
converted into a GET to download this report.
