---
title: "OpenREST"
description: "Landing page for the OpenREST contract and how to apply it."
type: "docs"
weight: 1
tags:
  - overview

cascade:
  - _target:
      path: "/**"
      kind: "page"
    type: "docs"
  - _target:
      path: "/**"
      kind: "section"
    type: "docs"
  - _target:
      path: "/**"
      kind: "section"
    type: "home"
---

Welcome to the OpenREST API Contract. This site is a highly opinionated set of requirements that will ensure you
and your team implement a clear, consistent, easy-to-use, and secure API. The contract is broken down into several
sections, each of which covers a different aspect of API design.

## Why is this necessary?

A solid and consistent API design is the foundation of any successful SaaS service, and is the
fundamental component of your products' Developer UX. It's also a point of frequent disagreement and
contention, as everyone has their own ideas about what makes a good API. So rather than have API design be the latest in
a long line of bike-shedding exercises, I've created this contract so you can focus on building your product.

## How do I use this?

The contract is broken down into several sections, each of which covers a different aspect of API design. The
implementation method and overhead of each may vary, so we recommend you read through each section and decide which ones
you can tackle first.

Unfortunately at this time there are no open source libraries to do the heavy lifting yet, though I hope that those
will evolve naturally. In the meantime, you will need to implement these requirements manually, though I hope you
will contribute them back to this project.

## How do I get my team to adopt this?

To put it bluntly, send an email to your team and draw a line in the sand. Say, "From this point forward, all of our
APIs will follow this contract." Then, start implementing it for all new features, and start flagging the older ones for
deprecation as the new ones come online.

This hard-line approach is necessary because API's tend to be fairly long lived, and deprecation cycles can take years
and are very painful. From many years of professional usage, I can tell you that using a Bezos-Mandate style approach
is the only thing that will work.

Can you pick and choose pieces to adopt while disagreeing on others? Sure, I'm not standing behind you with a proverbial
stick. If you take this approach, I will guarantee that you will descend into the same bike-shedding that this contract
is trying to avoid. This is because choosing only one portion forces you to justify it, which opens you to disagreement.
Do yourself a favor, and adopt it all.

## History of this Contract

The original v0 of this contract was written by myself with broad team consensus as a part of the now defunct
SecureState product. Management permission to publicise it was received in 2023, and the entire site was rewritten
in the summer of 2024 as independent work by myself, without access to the original source.
