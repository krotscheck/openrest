---
title: Do not use cookies
linkTitle: Cookies and Sessions
description: Cookies are a bad idea. Don't use them.
weight: 2
tags:
  - required
  - headers
  - security
  - sessions
---

### But what about

No.

### But there's this library

No.

### Well everyone else

No.

### Why?

- They destroy privacy, requiring additional engineering work and support for GDPR and other privacy regulations.
- They are domain bound. To use them on multiple domains requires attaching them to the TLD, which starts to leak.
- They leak. Everywhere.
- Every last marketing tracker adds their own cookies to try to figure out who you are, and you have no control
  over what the browser does with those. A single visit to your company's marketing site can add 20 cookies to your
  browser, and those will be attached to every single request to your API. Even if each of them only consumes 4KB of
  data, that's 80KB of data that you're sending on every request that you don't need. It adds up quick.
- There's always a new XSS attack.
- It makes you susceptible to CSRF attacks.
- There are size limits for how much data you can store in a cookie.
- There are limits to the number of cookies a browser will store per domain, which will conflict with the above leaking.
- You don't need them.

In summary, even if you follow all of the [OWASP
recommendations](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) for cookies, they
are still a bad idea. Cookies create privacy concerns, security risks, performance impacts, technical debt, user
experience overhead, and legal compliance concerns. There are better options available.

### What should I use instead?

Please see our section on [Authorization]({{< ref "authorization" >}}).
