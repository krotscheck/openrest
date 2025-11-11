---
title: API Versioning and Deprecation
weight: 1
description: API versioning is essential for managing changes to your API. This document outlines how this is done.
tags:
  - fundamentals
  - versioning
---

## Versioning

We use URI Path versioning, prefixing all endpoints with a simple, incrementing version string (`v1`).
All routes in a resource should have their versions increased at the same time, though this will usually only involve
adding additional routes in your gateway.

```http
/v1/myresources/*
/v2/myresources/*
```

## Deprecation

Breaking API changes are inevitable. Should a deprecation become necessary, it is most convenient to use a common
pattern for communication and documentation. For this purpose, we will
use [RFC-8594](https://tools.ietf.org/html/rfc8594) and [RFC-8288](https://tools.ietf.org/html/rfc8288#section-4.2) to
communicate the expected deprecation date, as well as any remediation documentation. This is there to
help your consumers, as they can update their code at their own pace, and to help you, as it simplifies management
and communication around that API.

```http
HTTP/1.1 200 OK
Sunset: Sat, 31 Dec 2018 23:59:59 GMT
Link: </docs/deprecation>; rel="sunset"; title="Deprecation Notice"
```

### Breaking Changes

The following is a table of changes and whether they are considered ‘breaking’. A simple rule of thumb is that the
“addition” of something is not considered breaking, while “changing” something is.

| Change type                                                 | Breaking or not? |
|-------------------------------------------------------------|------------------|
| Request/Response body field addition                        | Not breaking     |
| Request/Response body field removal                         | Breaking         |
| Request/Response body field change (example: casing)        | Breaking         |
| HTTP Method Addition                                        | Not Breaking     |
| HTTP Method Removal                                         | Breaking         |
| HTTP Response Code Change                                   | Breaking         |
| Error Message Change                                        | Not Breaking     |
| Removing a Route                                            | Breaking         |
| Adding a Route                                              | Not Breaking     |
| Growing the set of enforced values for an enumerated field  | Not Breaking     |
| Reducing the set of enforced values for an enumerated field | Breaking         |

Any time a breaking change is introduced, we must follow the appropriate expand/contract change management process.

### The `Sunset` Header

```http
Sunset: Sat, 31 Dec 2018 23:59:59 GMT
```

As per [RFC-8594](https://tools.ietf.org/html/rfc8594), every endpoint that is flagged for deprecation must include this
header, which specifies the date after which the endpoint will no longer be available. This allows clients to plan for
the change and update their code accordingly.

### The `Link` Header

If documentation is available describing the deprecation and the steps to take to update, you should
use [RFC-8288](https://tools.ietf.org/html/rfc8288#section-4.2)
to include include a `Link` header in your API response. This will allow our API clients to notify their authors
and/or users that an out-of-date API is still in use, and that they should update their code and/or SDK.

```http
Link: </target/url>; rel="sunset"; title="Human Readable Title"
```
