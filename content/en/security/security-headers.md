---
title: Security Headers
description: A variety of headers that can be added to every response to help protect your API from common web security vulnerabilities.
weight: 5
tags:
  - required
  - headers
  - security
---

The following headers prevent common web security vulnerabilities. In most cases they do not themselves
require any additional logic, and can be attached to every single response coming from a resource server.
Functionally, they let the server inform the browser client how to protect itself from common attacks.

### Strict-Transport-Security: `max-age=31536000; preload`

This header tells the browser that your API must be accessed via TLS/HTTPS.

### X-Content-Type-Options: `nosniff`

This header prevents a client from attempting to sniff - and override - the content-type sent by the server.

### X-Frame-Options: `DENY`

This header prevents an API request from being loaded in an IFrame, which is a common XSS attack vector.

### X-XSS-Protection: `1; mode=block`

This is a legacy header for older browsers, which you may not support. Even so, it doesn’t hurt us to add it, and it
provides similar protections to Content-Security-Policy.

### Referrer-Policy: `no-referrer`

This header controls whether a browser, while on-site, sends the Referer header when linking to another site. This kind
of data is often used for user tracking, and resource servers rarely have any use for such. As such, the header returned
by any Resource Server should be `no-referrer`.
