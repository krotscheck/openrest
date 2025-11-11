---
title: Batch Operations
weight: 1
description: How to bundle multiple API requests into a single HTTP Request.
tags:
  - advanced
  - batching
---

Batch operations are a way to bundle multiple API requests into a single HTTP request, reducing the number of round
trips between the client and the server.

To accomplish this, we're writing multiple fully self-contained MIME messages, and bundling them into a single HTTP
MIME message using the `multipart/mixed` MIME type. Much like REST, batch requests do not guarantee a specific order of
execution, and do not provide a method for referencing between child requests. They should be route, version, and server
agnostic, and should not create a 'spotty' batch implementation which works for some resources, but not others.

As such, the path requirement is that all batch requests be submitted to a dedicated path at the server root,
notably `/batch`. It is this endpoint's responsibility to receive, dispatch, collect, and return batch operations.

### Building a Batch Request

```http
POST /batch HTTP/1.1
Authorization: Bearer <JWT Access Token>
Content-Type: multipart/mixed; boundary=batch_boundary
Content-Length: total_content_length
```

The header which differentiates a batch request from a regular request is the `Content-Type`. By
using `multipart/mixed`, we are able to use one HTTP request to bundle multiple HTTP requests, very
similar to attaching files to an email. These are separated by the boundary string.

### Adding a Request to the Batch

```http
--batch_boundary
Content-Type: application/http
Content-ID: <opaque_random_string>

# The raw http request is here. For example, this is a GET request.
GET /v1/resource_name/{id}

--batch_boundary-- # The trailing dashes indicates end of document
```

To add an HTTP request to a batch request, we surround it with the boundary string and include the following two
headers:

- `Content-Type: application/http` - which indicates that the content is an HTTP request.
- `Content-ID: <opaque_random_string>` - a unique identifier that allows a client to correlate a request with the
  eventual response.

### Parsing a Batch Response

```http
HTTP/1.1 200 OK
Content-Type: multipart/mixed; boundary=batch_boundary
Content-Length: total_content_length
```

A batch response, assuming it was properly authorized, should always return `200`. This indicates that the batch request
was properly received and processed, however, it makes no assumptions about the individual requests within the batch.

### Extracting the Responses from a Batch

```http
--batch_boundary
Content-Type: application/http
Content-ID: <opaque_random_string_1>

# The raw response MIME type is here.
HTTP/1.1 200 OK
Content-Type: application/json

{ payload... }

--batch_boundary
Content-Type: application/http
Content-ID: <opaque_random_string_2>

# The raw response MIME type is here. For example, this is an error.
HTTP/1.1 404 Not Found

--batch_boundary
Content-Type: application/http
Content-ID: <opaque_random_string_2>

# The raw response MIME type is here. For example, this is an error.
HTTP/1.1 404 Not Found

--batch_boundary--
```

The response can be split using the `--boundary` value, and individual content blocks can be extracted and parsed. In
the case where a `Content-ID` was provided in the original request, the response body for this request will carry the
same `Content-ID`.

### Resource Timeouts

Any service that implements this needs to - by necessity - implement a request timeout for sub-requests. In the case
where a child request does not return within the timeout, the HTTP response should include a `504 Gateway Timeout`
boundary for the affected request, however, the overall batch request should return with a `200`.

In alignment with existing research, the timeout for any sub-resource will be 1 second. If a request is canceled for
this reason, the batch handler needs to inform the microservice that a request is canceled.

### Request and Response Size Limits

While the HTTP Specification does not restrict requests and responses to specific sizes, your toolchain may impose
restrictions. For example, use of the AWS API Gateway has a limit of 10MB. Rather than exhaust this payload, we
apply the following limits on our batch requests:

- No more than 50 requests may be batched at a time.
- The total collated batch request cannot exceed 5MB in size.
- The total collated batch response cannot exceed 5MB in size.
- A single batched request cannot exceed 100KB in size.
- A response for a single batched request cannot exceed 100KB in size.

### Error Cases

If the aggregate request exceeds the 5MB limit, or if more than 50 requests are made in a single batch, the batch
endpoint should handle no requests, and immediately return with `413 Entity Too Large`.

```http
HTTP/1.1 413 Entity Too Large
```

All batched requests that do not exceed 100KB should be honored, while any batched requests that are too large should -
in their own response - return a `413 Entity Too Large`.

```http
HTTP/1.1 200 OK
Content-Type: multipart/mixed; boundary=batch_boundary
Content-Length: total_content_length

--batch_boundary
Content-Type: application/http
Content-ID: <opaque_random_string>

HTTP/1.1 200 OK
--batch_boundary
Content-Type: application/http
Content-ID: <opaque_random_string>

HTTP/1.1 413 Entity Too Large
--batch_boundary--
```

### Authorization

Authorization for a batch request is handled at the batch level. The batch handler is required to validate the
authorization, and then pass that authorization on to every child request that is made. It will not make assumptions
about roles or permissions.
