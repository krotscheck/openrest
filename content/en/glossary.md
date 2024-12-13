---
title: Glossary
description: Common terms and definitions used in this Contract.
toc_hide: true
menu:
  main:
    weight: 20
---

Words matter - and technical vocabulary can vary widely even within the same company. Thus, to assist with clarity,
we've collected and defined terms here to ensure we're all talking about the same thing.

### Resource

A data structure that can be uniquely identified by a URL.

### Resource Server

A server that hosts groups of resources, and is capable of responding to requests for those resources.
The term is deliberately implementation-agnostic: It could be a set of Microservices, a monolithic application, or even
a set of static files.

```
https://resource.example.com/
```

### Resource Endpoint

A specific URL that can be used to access a resource or group of Resources on a Resource Server.

```
https://resource.example.com/auth/v1/user
https://resource.example.com/auth/v1/user/00000000-0000-0000-0000-000000000000
https://resource.example.com/auth/v1/device
```
