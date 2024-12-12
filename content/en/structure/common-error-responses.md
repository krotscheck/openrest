---
title: Error Format
description: The response format and structure for all error messages.
weight: 2
---


Error messages are a critical part of the API contract and should be consistent
across all resources.
They provide the necessary feedback to the client to understand what went wrong,
and most importantly how to fix it.
In all cases, the message should be actionable, providing the user with the
necessary information to resolve the issue.
This will reduce the number of support tickets and increase the overall user
experience.

An error message needs to solve three problems, all without leaking
implementation details to the outside world:

1. For both engineers and users, it needs to explain what happened.
2. For users, it needs to provide actionable feedback to self-resolve their
   issues.
3. For engineers, it needs to provide detailed information needed for triage.

The error format adopted by this contract adheres to the OAuth2 error response
structure, as
per [RFC 6749](https://tools.ietf.org/html/rfc6749#section-5.2). This structure
is as follows:

```http
HTTP/1.1 4xx/5xx Message

{
    "error": "an_error_key",
    "error_description": "Text providing additional information, used to assist the client developer in understanding the error.",
    "error_uri": "An optional link to documentation that may assist in resolving this error"
}
```

| Property          | Required | Type   | Description                                                                                                                                                                                                                                                                                                               |
|-------------------|----------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| error             | yes      | string | A short, unique string which can be used to switch automatic remediation steps in the callee. For example, a user may be prompted to add missing information so that the request can be retried quickly. This code should be in snake_case.                                                                               |
| error_description | yes      | string | An actionable, human-readable message of the error that occurred. Actionable, in this context, means that a non-engineer can read it and know how to remediate their error; even if it’s something like “Please wait and try again later.“ In the case where an error is not actionable, this should be the communicated. |
| error_uri         | no       | uri    | If documentation exists to describe the details of a request and/or feature, you may optionally add a fully qualified URI which a user can read for more information. Please ensure that the existence of this URI is automatically and continuously verified.                                                            |

If your site makes use of internationalization, the error description must be
appropriately localized as per our
[Internationalization]({{< ref "../advanced/i18n" >}})

### Guidelines for writing a good error message

- Proper grammar is important. Use proper capitalization and punctuation. Use a
  spell checker.
- Always end your message with a period.
- Never include the product name in the error.
- Never use explicit service or technology names, preferring the role they
  serve. For
  example, `Error reading from redis` should instead be
  `Error reading from cache`.
- Always speak in the active voice, not the passive voice.
- Do not address the actor using the word "You"; simply describe the error.
- Do not reveal details about the underlying implementation or internal
  constructs.

### Example error strings

- The field ‘field’ is required.
- The field ‘field’ may not be longer than 256 characters.
- The server is busy, please try again later.
- This request is not authorized.
