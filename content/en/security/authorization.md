---
title: Authorization
description: |
  How to determine whether a user, system, or other principal has the necessary permissions to perform an action or
  access a resource.
tags:
  - required
  - headers
  - security
---

For resources and actions that require authorization, the only permitted method is via Bearer Tokens as per
[RFC 7519](https://www.rfc-editor.org/info/rfc7519). While the process of obtaining these tokens is outside the
scope of this contract, they are likely issued by a security token service (STS) such as may exist in a federated OIDC
or OAuth2 environment.

The structure and evaluation of this token is not up to us, though we strongly encourage you follow best
practices such as [OAuth2 Security Topics](https://datatracker.ietf.org/doc/draft-ietf-oauth-security-topics/)

```http request
POST /namespace/v1/resource HTTP/1.1
Authorization: Bearer <JWT Access Token>
```

### JWT Token Payload

Assuming a token is properly decoded and validated, the following payload can be extracted and inspected for
scopes and other non-normative permission markers.

```json
{
  "sub": "00000000-0000-0000-0000-000000000000",
  "azp": "authorized_client_id",
  "domain": "example.com",
  "context": "00000000-0000-0000-0000-000000000000",
  "iss": "https://issuer.example.com",
  "exp": 1603075483,
  "iat": 1603073683,
  "jti": "00000000-0000-0000-0000-000000000000",
  "scope": "openid profile email"
}
```

## Considered Alternatives

### Cookies

Cookies are problematic at best, and downright dangerous at worst. OWASP best practices recommend
that cookies are explicitly domain bound, meaning that you are forced to a specific public api design, that of
a single gateway to access all of your services. This is a contract, not a design document, and we want to
avoid dictating your infrastructure.

### Basic Auth

Basic Auth requires the use of explicit credentials for every api request, meaning that the resource owner's
username and password need to be known by every system that wishes to make a request.

### API Key

API Keys are not a bad idea, however we strongly prefer that these are exchanged for bearer tokens with a limited
TTL. This makes sure that API Keys can be quickly revoked, as they are only redeemed at a single service.

### ID Tokens / Access Tokens

We do not explicitly define which access tokens may or may not be used, because I don't know your use case.
For modifying or reading a user's own data, an ID token may be sufficient. For modifying or reading a different
kind of resource, an access token may be more appropriate.
