---
title: CRUD Operations
weight: 5
description: The constraints for all Create, Read, Update, and Delete operations in the system.
tags:
  - structure
  - crud
---

The Create/Read/Update/Delete (CRUD) requirements are deliberately optimized for Cache usage and conflict control, so
that the client has a rich suite of tools at their disposal to manage their local state, and could even rely
on their client's own cache to manage the state of the API. Pair these rules with
[`Entity Versioning and Conflict Management`]({{< ref "../api-fundamentals/entity-versioning-and-conflict-management" >}}),
which explains how conditional requests prevent stale writes, and with
[`List Queries`]({{< ref "../queries/list-queries" >}}) for the read patterns that sit beside CRUD.

### Create

A create request is a POST request to the root resource path, with the entity to be created in the request body. The
entity should **not** be returned in the response; instead, the response must use a `201 Created` header, and
indicate in the `Location` header where the entity can be retrieved (or polled).

#### Create Request

```http
POST /v1/resourcename/  HTTP/1.1
Content-type: application/json

{ ... sufficient data ... }
```

#### Create Response

```http
HTTP 201 Created
Location: /v1/resourcename/{id}
```

### Read

A read operation is a GET request to the resource path, with the entity's ID in the path. The entity should be returned
in the response, including all entity version headers as described in [Entity Versioning and Conflict Management]({{<
ref "entity-versioning-and-conflict-management" >}}). Conditional cache headers may be included in the request, and must
be respected by the server.

#### Read Request

```http
GET /v1/resourcename/{id}  HTTP/1.1
Accept: application/json
```

#### Read Response

```http
HTTP 200 OK
Content-Type: application/json
ETag: "..."
Last-Modified: "..."
Cache-Control: max-age=3600
Vary: Accept, Origin

{
    "id": "...",
    "eTag": "...",
    ...
}
```

### Update

An update operation uses the PUT action to replace all fields in the entity, assuming they may be replaced. If the
client sends fields that may not be updated - such as `created_time` - they should be ignored. As with the GET
request, all headers indicating entity version and age must be returned.

#### Update Request

```http
PUT /v1/resourcename/{id}  HTTP/1.1
Accept: application/json
Content-Type: application/json

{
    "id": "...",
    ...
}
```

#### Update Response

```http
HTTP 200 OK
Content-Type: application/json
ETag: "..."
Last-Modified: "..."
Cache-Control: max-age=3600
Vary: Accept, Origin

{
    "id": "...",
    ...
}
```

### Delete

Delete operations are idempotent, and should return a `204 No Content` response. The entity should not be returned in
the response.

#### Delete Request

```http
DELETE /v1/resourcename/{id}  HTTP/1.1
```

#### Delete Response

```http
HTTP 204 No Content
```

No entity needs to be returned.

## Reasoning

The entire point of this section of the contract is to make development easy for the front-end/downstream engineers.
We do this by focusing on two areas: Controlling the client's cache using HTTP Semantics
from [RFC-9110](https://www.rfc-editor.org/rfc/rfc9110.txt), and outright rejecting PATCH operations as they almost
always carry with them complex diffing logic.

Details about how we accomplish cache control in resources is described in
[Entity Versioning and Conflict Management]({{< ref "entity-versioning-and-conflict-management" >}}). As for PATCH
operations, I've found from experience that they add quite a bit of engineering overhead to both the client and server
logic. Since the client will likely already have a copy of the existing entity in memory, creating a new entity
for a patch request is a waste of resources as well as a potential soure of diffing bugs - especially if the data schema
expands.

At the same time, this creates a attack vector for malicious actors, who can easily infer that any PATCH
operation must load the rest of the entity from the database before they can validate the resulting change. They
can both infer validation logic from measuring the time of their requests (hashing algorithms are particularly
vulnerable to timing attacks), and there is an entire class of State Injection attacks that can be performed if
we know that a entity will be loaded, and then have a change applied, before being validated.

In short, don't use PATCH requests. Accept the whole entity, validate it, and then try to apply the change. Benign
actors will just send back what they have, and malicious actors won't be able to get any data.
