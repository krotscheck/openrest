---
title: Domain Names
description: A clear and organized domain name strategy, explicitly separating functional areas via using subdomains.
weight: 3
tags:
  - structure
  - routing
---

In designing a robust and scalable API, having a clear and organized domain name strategy is imperative.

## Requirements

1. **Dedicated Domain for each Project/Product**
    - Every distinct project or product must have its own domain or subdomain.
    - Example:
        - A company with a single product would host it at `example.com`
        - A company with multiple products would host them at `product1.example.com`, `product2.example.com`, etc.

2. **Subdomains for each Functional Area**
    - Each significant functional area within a project should have its own subdomain.
    - Examples:
        - A product's data warehouse would be hosted at `data.product1.example.com`
        - A product's reporting api would be hosted at `reports.product1.example.com`

3. **Cross-functional functional areas to be hosted at closest shared parent domain**
    - If there is an area that applies to multiple products in a domain, it should be hosted within the closest
      namespace that makes sense.
    - Example:
        - A company-wide authentication service would be hosted at `auth.example.com`.

## Rationale

> "Do one thing, and do it well." -- Doug McIlroy

The Unix philosophy of creating small, focused tools that work together to solve complex problems is a guiding principle
for API design. By dedicating domains and subdomains to specific functional areas, we can create a clear, modular,
and scalable structure that aligns with this philosophy.

By following this approach, you get the following benefits:

- **Composability**: Not all products need to re-implement something that's already been built. You can reuse existing
  services across different products.
- **Clarity**: Developers can quickly locate the API they need.
- **Independence**: Each domain can have its own development, CI, and lifecycle.
- **Security**: Limiting the scope of potential security breaches, and discouraging use of private back-door endpoints
  for internal use.
- **Modularity**: Teams can work on different domains simultaneously without interference, increasing iteration cycles
  and agility. Updates, patches, and new features can be rolled out to specific parts of the API without risking the
  stability of the entire system.
- **Scalability**: The structure allows for the seamless addition of new features and services, as the foundational
  elements remain consistent.
