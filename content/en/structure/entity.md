---
title: Resource Entities
description: The required fields and naming conventions for all resources in the API.
weight: 1
tags:
  - structure
  - resources
---

## Requirements

Resource API's should only be expressed in JSON or YAML format. For more details on type negotiation, please refer to
our section on [`Content-Type`]({{< ref "../api-fundamentals/content_type" >}}). ID fields must follow the guidance in
[`Unique Identifiers`]({{< ref "../api-fundamentals/unique-identifiers" >}}) so downstream services can rely on
consistent formats.

### Fields

For all resources, as expressed in request and response payloads, the following fields are required:

| Key           | Format                                                 | Description                                                                                                  |
|---------------|--------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| id            | string                                                 | A unique identifier for this resource, using either a [KSUID](https://github.com/segmentio/ksuid) or a UUID. |
| created_time  | [RFC-3339](https://www.rfc-editor.org/rfc/rfc3339.txt) | The date that this resource was created, in UTC.                                                             |
| modified_time | [RFC-3339](https://www.rfc-editor.org/rfc/rfc3339.txt) | The date this resource was last modified. It must be used for Last-Modified style cache requests.            |
| etag          | string                                                 | A base-64 style string as the document's version identifier.                                                 |

### Naming Conventions

All request and response fields must follow the same naming conventions:

- All fields to be snake_case. No golang-style exceptions for acronyms like URL, ID, or similar.
- All complex types which are expressed using a basic type, must be suffixed with the name of the complex type. For
  example:
  - External ID's should be suffixed with `_id` (whether they're UUID's or not).
  - UUID's that are not used as external ID references must be suffixed with `_uuid`.
  - Timestamps must be suffixed with `_time`.
  - Email addresses must be suffixed with `_email`.
  - URLs must be suffixed with `_url`.
- Do not stutter. Instead of `resource.resourceName`, use `resource.name`.
- When using generic terms that may apply to multiple resources, use the most specific version. For
  example, `project_group` and `user_group` instead of `group`.
- When referencing a resource in a third-party system, where that third party system is the source of truth for that
  resource, prefix the field with the name of that system. Examples
  include: `okta_user_id`, `ms_client_id`, `aws_credentials_id`.
- All APIs must consistently use the same fields to mean the same thing, without exceptions.

### Forbidden Fields

The following fields and field groups are forbidden for all resource.

- `links` or `selfLink`, and any other fields prescribed by HATEOAS. We explicitly do not support it.
- Sensitive data of any form.
- Internal use fields and or debugging information.
- Binary data is explicitly not permitted as part of a resource.

### Validations

- Email addresses must be validated to ensure they follow a standard format.
- All URL's must be represented as absolute.
- Phone numbers must be standardized to a single format, preferably using E.164.
- All time notation must adhere to [RFC-3339](https://www.rfc-editor.org/rfc/rfc3339.txt) and be expressed in UTC.

## Reasoning

> "There are 2 hard problems in computer science: cache invalidation, naming things, and off-by-1 errors." ― Leon
> Bambrick

I can't count how often I've asked for a consistent name to be used, just to receive pushback because the owner of the
PR has their own views on the topic. In the end we all have the same goal: An easy-to-use system that is legible
during our engineering day-to-day. Unfortunately, without a consistent naming pattern, every engineer applies their
own personal view on things, and we end up with a patchwork of conflicting standards across our codebase.

This is a usability nightmare. Not only for our engineers, who now have to read most of the code to decipher what
a particular field might mean. It's an even bigger problem for API consumers, who now have to read the documentation to
understand what a field might mean. Assuming your documentation is good - if it's not, then expect your support channels
to be overwhelmed with clarifications.

All of this boils down to time, and therefore money. Time your engineers have to spend, time your support team has to
waste, time your customers have to invest in understanding your system. All of this can be avoided by simply adhering to
this convention.
