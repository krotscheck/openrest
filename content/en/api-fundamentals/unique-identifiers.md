---
title: Unique Identifiers
description: How to generate and use unique identifiers in your API.
---

All unique identifiers in the system, that is to say resource ID's, must be UUID's or KSUID's. This is to ensure that
the identifiers are globally unique and can be generated without a central authority.

## UUID

A UUID is a universally unique identifier, and is defined in [RFC 4122](https://tools.ietf.org/html/rfc4122). It is a
128-bit number, usually represented as a 32-character hexadecimal string. The UUID is generated using a pseudo-random
number generator, and while it is not not guaranteed to be unique, but the probability of a collision is extremely low.

```http
GET /v1/entity/123e4567-e89b-12d3-a456-426614174000
```

## KSUID

A KSUID is a K-Sortable Unique Identifier, and was originally defined by the team
at [Segment.io](https://github.com/segmentio/ksuid). It is notably different from a UUID in that - in addition to being
globally unique - it is also sortable by date. This is achieved by encoding the timestamp when the KSUID was generated
in the first 4 bytes of the identifier.

These ID's are most useful when trying to store time-series data with a minimum number of storage indexes, as even
a filesystem will be able to sort these ID's by name.

```http
GET /v1/entity/0ujsszwN8NRY24YaXiTIE2VWDTS
```
