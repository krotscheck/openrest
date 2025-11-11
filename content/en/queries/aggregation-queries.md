---
title: Aggregation Queries
description: Aggregating data in a single query.
weight: 5
tags:
  - queries
  - aggregation
---

Aggregation queries are a powerful way by which aggregate data can be collected in a single query without a client
having to iterate over the entire result set. For those of you familiar with ElasticSearch, this is a simplified
version of the Bucket, Metrics, and Pipeline aggregation request format, which expresses the options of each while
keeping the contract concise for the user (note that only Buckets and Metrics are supported).

Supporting these kinds of queries can be quite complex, and your API may not even need them, so it's up to you to
decide if they are necessary. Use cases which this might satisfy include:
inspecting trends discovered via [`List Queries`]({{< ref "./list-queries" >}}) or pruning payloads with
[`Projection`]({{< ref "./projection" >}}).

- Autocompleting tags already used in other documents.
- Showing how many documents exist in a particular result set.
- Gather averages, sums, and other metrics from a set of resources.

## Path

Much like [List Queries]({{< ref "list-queries" >}}), aggregation queries follow the "Build a result set based on a
query" pattern, but this time using the `/aggregate` sub-path of the resource's endpoint. Unlike the list queries
however, there is no need to page the response.

```text
POST /v1/resources/aggregate
GET  /v1/resources/aggregate/<result_set_id>
```

## Request and Response Schema

Aggregation queries do not support the same filtering, searching, pagination, or sorting semantics as
[List Queries]({{< ref "list-queries" >}}). [Filtering]({{< ref "searching-and-filtering" >}}) is
applied at the top level of the request and affects all aggregations and sub-aggregations. This ensures consistency and
simplifies the query structure. Filters cannot be applied to individual aggregations within the query. [Sorting]({{<
ref "pagination-and-sorting" >}}) can be applied directly to each aggregation bucket (if appropriate).

### Common Fields

Every aggregation request contains the same two fields: `filters`, which is optional and follows our filtering rules,
and `aggregations`, which is a map of the different aggregations requested by the server. The aggregations each
have a `type` property to inform the server what form of aggregation is requested.

```http
POST /v1/resources/aggregate

{
    "aggregations": {
        "<bucket_name>": {
            "type": "terms",
            ....
        },
        "<another_bucket_name>": {
            "type": "avg",
            ....
        }
    }
}
```

A response to an aggregation request returns the same map, replacing the query constraints with the results of the
requested aggregation. For specific examples of requests and responses, please see the detailed examples below.

```http
HTTP/1.1 200 OK

{
    "aggregations": {
        "<bucket_name>": {
            .... results
        },
        "<another_bucket_name>": {
            .... results
        }
    }
}
```

### Aggregation Query: `terms`

A 'terms' aggregation query sorts all documents into buckets defined by the provided fields' value, and returns the
count of those buckets. The number of terms to return should be provided.

```http
POST /v1/resources/aggregate

{
    "aggregations": {
        "tags": {
            "sort": [],            // Optional sorting rules, as per the sort standard.
            "type": "terms",       // Always `terms`
            "field": "tags.name",  // The field name to aggregate.
            "count": 20,           // The total number of terms to return.
        }
    }
}
```

The server then must respond with the buckets into which the documents were sorted, along with the count of documents
in each bucket. Terms should be sorted according to the sorting rules.

```http
HTTP/1.1 200 OK

{
    "aggregations": {
        "tags": {
            "tags.name": {
                "Anchovy": {        // The term name
                    "count": 3      // The number of documents which contain this term
                },
                "Sardine": {        // The term name
                    "count": 60     // The number of documents which contain this term
                }
            }
        }
    }
}
```

### Aggregation Query: `sum`

A `sum` aggregation calculates sum of a numeric field. While itself perhaps not the most useful, it
becomes quite powerful when used as a nested aggregation (see examples at the end).

```http
POST /v1/resources/aggregate

{
    "filter": [...],
    "aggregations": {
        "award_points": {
            "type": "sum",        // Always `sum`
            "field": "points",    // The field name to calculate the sum of.
        }
    }
}
```

The server then must respond with the buckets into which the documents were sorted, along with the count of documents
in each bucket. Terms should be sorted according to the sorting rules.

```http
HTTP/1.1 200 OK

{
    "aggregations": {
        "award_points": {
            "count": 10332,
            "points": 234000
        }
    }
}
```

### Aggregation Query: `avg`

A `avg` aggregation calculates the average of a numeric field.

```http
POST /v1/resources/aggregate

{
    "filter": [...],
    "aggregations": {
        "rating": {
            "type": "avg",       // Always `avg`
            "field": "stars",    // The field name to calculate the average of.
        }
    }
}
```

The server then must respond with the buckets into which the documents were sorted, along with the count of documents
in each bucket. Terms should be sorted according to the sorting rules.

```http
HTTP/1.1 200 OK

{
    "aggregations": {
        "rating": {
            "count": 10332,
            "stars": 4.23322555
        }
    }
}
```

### Aggregation Query: `range`

A `range` aggregation collects documents into numeric ranges for a specific field. The ranges are defined by the
`from` and `to` properties. If either is omitted, the range is open-ended.

```http
POST /v1/resources/aggregate

{
    "filter": [...],
    "aggregations": {
        "runners": {
            "type": "range",    // Always `range`
            "field": "pace",    // The field name to divide into buckets
            "ranges": {         // An object of pre-named bucket ranges
                "slow":   { "from": 0, "to": 7 },
                "normal": { "from": 7, "to": 9 },
                "fast":   { "from": 9 }
            }
        }
    }
}
```

The server then must respond with the buckets that were requested by the user.

```http
HTTP/1.1 200 OK

{
    "aggregations": {
        "runners": {
            "count": 8700,
            "pace": {
                "slow": {
                    "count": 100
                },
                "normal": {
                    "count": 8000
                },
                "fast": {
                    "count": 600
                }
            }
        }
    }
}
```

### Other Aggregation Queries

The above are not an exhaustive list of aggregations which your system may support; your use cases may vary, and you
can expand on what we've provided here at your leisure. We just ask that you let us know of specific use cases, so
we can evaluate them for inclusion here.

If you're looking for inspiration, the
[ElasticSearch Aggregations documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket.html)
can provide some.

## Examples

I've included some examples below to help you understand how to structure your requests and what to expect in the
response.

### Items by price

```http
POST /v1/resources/aggregate HTTP/1.1

{
    "aggregations": {
        "price_range": {
            "type": "range",
            "field": "price",
            "ranges": [
                { "from": 0, "to": 50 },
                { "from": 50, "to": 100 },
                { "from": 100 }
            ]
        }
    }
}
```

```http
HTTP/1.1 200 OK
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"

{
    "aggregations": {
        "price_range": {
            "0-50": {
                "doc_count": 100
            },
            "50-100": {
                "count": 80
            },
            "100+": {
                "count": 60
            }
        }
    }
}
```

### Autocompleting Tag Names

```http

POST /v1/resources/aggregate HTTP/1.1

{
    "aggregations": {
        "tags": {
            "type": "terms",
            "field": "tags.name",
            "count": 5,
            "sort": [
              {
                "on": "tags.name",
                "order": "ASC" 
              }
            ]
        }
    }
}
```

```http
HTTP/1.1 200 OK
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"

{
    "aggregations": {
        "tags": {
            "Anchovy": {
                "doc_count": 3
            },
            "Branzini": {
                "count": 80
            },
            "Cod": {
                "count": 60
            }
        }
    }
}
```

### Total Sales by Month

```http
POST /v1/resources/aggregate HTTP/1.1

{
    "aggregations": {
        "monthly_sales": {
            "type": "range",
            "field": "closed_date"
            "ranges": {
                "2019-01": { "from": "2019-01-01", "to": "2019-02-01" },
                "2019-02": { "from": "2019-02-01", "to": "2019-03-01" },
            },
            "aggregations": {
                "sales": {
                    "type": "sum",
                    "field: "price"
                }
            }
        }
    }
}
```

```http
HTTP/1.1 200 OK
ETag: "dd2796ae-1a46-4be5-b446-7f8c7a0e8342"

{
    "aggregations": {
        "monthly_sales": {
            "count": 100,
            "closed_date": {
                "2019-01": {
                    "count": 100,
                    "sales": 10000
                },
                "2019-02": {
                    "count": 80,
                    "sales": 8000
                }
            }
        }
    }
}
```
