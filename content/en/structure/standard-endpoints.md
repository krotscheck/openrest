---
title: Standard Endpoints
tags:
  - required
  - paths
  - openapi
  - liveness
  - readiness
  - health
---

The following endpoints are required for every resource server:

- **Well-Known Resources:** `/.well-known`
- **Public API Descriptor:**  `/openapi.(json|yaml)`

## `/.well-known/`

At the root of every resource server, a `.well-known` directory must exist as
per [RFC-5785](https://www.rfc-editor.org/rfc/rfc5785.txt). This directory is there to contain
URL's that will never change, and therefore 'well-known' for any client that wishes to perform some
method of autodiscovery. Similar to [DNS-SD](https://www.rfc-editor.org/rfc/rfc6763.txt), it's purpose is
a way to discover a resource server's configuration without having to reference external documentation.

Creating a `.well-known` directory within a subdirectory is expressly forbidden. While technically permitted
under certain readings of some RFC's, it obfuscates the location of such documents and thus makes
autodiscovery difficult at best, and impossible at worst.

## `/openapi.(json|yaml)`

Every resource server must provide its own OpenAPI specification document at a consistent path. This API descriptor must
be accurate enough, and well documented enough, to generate SDKs and clients directly from the document.

This endpoint exposes an OpenAPI v3.0.3 document that describes the public API of this version of the microservice. This
endpoint must return appropriately formatted content for both `application/json` and `application/yaml`. Each new
version of the API should be added to this same document; for details on the document structure, please refer to
the [OpenAPI Specification - Version 3.0.3](https://swagger.io/specification/).
