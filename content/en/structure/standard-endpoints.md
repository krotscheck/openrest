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

The following endpoints are required for every running component of your infrastructure. What this means for your
project may vary, but a general rule-of-thumb is that every component that could fail should implement these endpoints
to provide a consistent interface for monitoring and management. Note that not all of these endpoints are public.

- **Well-Known Resources:** `/.well-known`
- **Public API Descriptor:**  `/openapi.(json|yaml)`
- **Startup Probe:**   `/status`
- **Liveness Probe:**  `/status`
- **Readiness Probe:** `/health`
- **Health Probe:**    `/health`
- **Service Metrics:** `/metrics`

## /.well-known

At the root of every resource server, a `.well-known` directory must exist as
per [RFC-5785](https://www.rfc-editor.org/rfc/rfc5785.txt). This directory is there to contain
URL's that will never change, and therefore 'well-known' for any client that wishes to perform some
method of autodiscovery. Similar to [DNS-SD](https://www.rfc-editor.org/rfc/rfc6763.txt), it's purpose is
a way to discover a resource server's configuration without having to reference external documentation.

Creating a `.well-known` directory within a subdirectory is expressly forbidden. While technically permitted
under certain readings of some RFC's, it obfuscates the location of such documents and thus makes
autodiscovery difficult at best, and impossible at worst.


### OpenID V3

Every microservice must provide its own yaml document at a consistent path. These will be collected and collated, using
the gateway’s own openapiv3 knowledge of internal API mappings, into a single document that does not expose our internal
infrastructure.

Note that the public route of your API may not be the same as the private route, or even go to the same microservice, as
we often rewrite paths at the gateway. The API descriptor must be accurate enough, and well documented enough, to
generate SDKs and clients directly from the document.

## /openapi.json

Every

This endpoint must expose an OpenAPI v3.0.3 document that describes the public API of this version of the microservice.

This endpoint exposes an OpenAPI v3.0.3 document that describes the public API of this version of the microservice. This
endpoint must return appropriately formatted content for both `application/json` and `application/yaml`, the latter
being the canonical openapiv3 format. Each new version of the API should expose its own OpenAPI document.

For details on the document structure, please refer to the specification itself:

[OpenAPI Specification - Version 3.0.3](https://swagger.io/specification/)

## /status

This is a public, unauthorized, no-op liveness endpoint for every microservice, used for k8s liveness checks as well as
public uptime checks. It informs our SLA’s.

### State

| Status Code | Content                   |
|-------------|---------------------------|
| Starting    | 200 OK                    | None |
| Up          | 200 OK                    | None |
| Stopping    | 200 OK                    | None |
| Down        | 503 Unavailable           | None |
| Errored     | 500 Internal Server Error | None |

**GET /status**

```
HTTP 1.1/200 No Content
```

## /health

This private, unauthorized endpoint serves as both the readiness and health probe within k8s. Unlike RFC’s such as the
Draft RFC for API Health Checks, it is not intended to provide detailed metrics, though it should use those to inform
its decision on the health status of the service.

### State

| Status Code | Content                   |
|-------------|---------------------------|
| Starting    | 503 Unavailable           | None |
| Up          | 200 OK                    | See Below |
| Stopping    | 503 Unavailable           | None |
| Degraded    | 200 OK                    | See Below |
| Down        | 503 Unavailable           | None |
| Errored     | 500 Internal Server Error | See Below |

The HTTP response of the health check must return a snapshot view into the current status of the service, as well as any
resources that it depends on. This will allow quick examination of where a failure may lie. The below document structure
is a recommendation derived from Draft RFC for API Health Checks, version 05.

[Draft RFC for API Health Checks, version 05](https://tools.ietf.org/html/draft-inadarei-api-health-check-05)

```json
{
  // Value may be "pass", "warn", "down", or "error"
  "status": "pass",
  // The release ID, for example the shasum or docker tag
  "releaseId": "1.2.2",
  // The service ID.
  "serviceId": "vss-policy-service",
  // The identifier for the running instance in a distributed system. e.g. pod ID.
  "instanceId": "vss-pod-number",
  // An optional list of checks in the system
  "checks": {
    "redis": [
      {
        "componentType": "cache",
        "componentId": "reader",
        "action": "ping",
        "observedValue": 250,
        "observedUnit": "ms",
        "status": "pass"
      },
      {
        "componentType": "cache",
        "componentId": "writer",
        "action": "ping",
        "observedValue": 250,
        "observedUnit": "ms",
        "status": "pass"
      }
    ],
    "cpu:utilization": [
      {
        "componentId": "6fd416e0-8920-410f-9c7b-c479000f7227",
        "node": 1,
        "componentType": "system",
        "observedValue": 85,
        "observedUnit": "percent",
        "status": "warn",
        "time": "2018-01-17T03:36:48Z",
        "output": ""
      },
      {
        "componentId": "6fd416e0-8920-410f-9c7b-c479000f7227",
        "node": 2,
        "componentType": "system",
        "observedValue": 85,
        "observedUnit": "percent",
        "status": "warn",
        "time": "2018-01-17T03:36:48Z",
        "output": ""
      }
    ]
  }
}
```

## /metrics

This private, unauthorized endpoint exposes prometheus metrics that can be scraped and sent to your metrics collector.
The data available here 
The data exposed here must be used to provide real-time notifications and alerts on the health of the service, including
memory usage, cpu usage, and excessive component latency.
