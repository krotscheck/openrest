---
title: Searching and Filtering
description: How to search, and construct complex filters for any query.
weight: 2
---

Searching is an inherently inclusive operation, whereby the system will add all records whose values closely - but not
exactly - match the search string. Filtering, by contrast, constrains the set of records to those that exactly match the
provided values, though they may support wildcards. They can operate in tandem, with a filter constraining the field in
which a search is applied, but care must be taken that the system can handle the complexity of the combined operation.

## Searching

A search string is provided by a user when they are not entirely certain where the result they are seeking is expressed.
For example, a word expressed in a search string may exist in a title, a description, or any other property of the
resource.

```http
POST /v1/resources/query HTTP/1.1

{
  "search": "...."
}
```

| Property | Relevance | Type   | Description                                          |
|----------|-----------|--------|------------------------------------------------------|
| search   | request   | string | A string by which to search in the set of resources. |

It is left to each resource type to define which fields are included in the search index, and what tokenization method
is used to decompose the resource instance and the incoming search expression. In all cases, the result should be a '
best fit' match, should be case-insensitive, and should be returned in the order of most relevant first.

## Filter

A query may include a filter object, which expresses a tree-like structure of logical filters and their relevant
operands. There are two basic types of filter objects: single and multiple. If a search string is also provided, it must
only be applied to resources that also match the filters.

If a search string is provided, and the query also accepts sorting criteria, the service must return a `400 Bad Request`
stating that search and sort are not compatible. Searching already includes an implicit sort based on the relevance of
each record, which a sort expression would conflict with. These two expressions are not compatible.

#### Single Value Operation

Filtering for a single value on a single field looks as follows:

```http
POST /v1/resources/query HTTP/1.1

{
  "filters": {
        "op": "....",           // the logical operation that applies to a single value (see below)
        "key": "dot.notation",  // The key where the value should be found, using dot-notation for deep nesting.
        "value": "some-value"   // The input value of for the logical operation, if appropriate.
    }
}
```

#### Multi-Value Operation

Filtering on multiple criteria would expand on the above.

```http
POST /v1/resources/query HTTP/1.1

{
  "filters": {
        "op": "....",           // the logical operation that applies to multiple values.
        "values": [
            {
                // A list of single or multi-value operations.
            }
        ]
    }
}
```

### Data Schema

| Key    | Type         | Relevance    | Description                                                                                                                                                                                          | Notes                                                                                                                                                                                                                                                                                                                                                                                   |
|--------|--------------|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| op     | string       | All          | The operation to perform. Case insensitive, see below for a full list of required operations. If not provided, the default value is assumed to be `EQ` for single values, and `OR` for multi values. |
| key    | string       | Single Value | The property on which to perform the operation.                                                                                                                                                      | Dot notation may be used for root-level expansion of nested properties. This is optional by context.                                                                                                                                                                                                                                                                                    |
| value  | string       | Single Value | A value to use for single-value operations.                                                                                                                                                          | The type is always a string, though its format may be type specific: <ul><li>Dates must be formatted as RFC-3339.</li><li>String values may include the wildcard `*`, which represents zero or more of any character.</li><li>Large numbers (big.Int) must be expressed as base64 encoded strings.</li><li>Regular Expressions must not include leading and trailing slashes.</li></ul> |
| values | Filter Array | Multi Value  | A list of operations                                                                                                                                                                                 | If no values are provided, no records should match.                                                                                                                                                                                                                                                                                                                                     |

### Valid Operations

| Operation | Key Name              | Relevance    | Notes                                               |
|-----------|-----------------------|--------------|-----------------------------------------------------|
| EQ        | Strictly Equals       | Single Value |                                                     |
| NEQ       | Not Equals            | Single Value |                                                     |
| GT        | Greater Than          | Single Value |                                                     |
| LT        | Less Than             | Single Value |                                                     |
| GE        | Greater or Equal To   | Single Value |                                                     |
| LE        | Less than or Equal To | Single Value |                                                     |
| REGEX     | Regular Expression    | Single Value |                                                     |
| AND       | And                   | Multi Value  | All of the provided filters must be true.           |
| OR        | Or                    | Multi Value  | Any of the provided filters must be true.           |
| XOR       | Exclusive or          | Multi Value  | Only one of the provided filters may be true.       |
| XNOR      | All or nothing        | Multi Value  | All of the provided filters must be true, or false. |

### Wildcards

The use of wildcards may be used in string values, using simple Glob matching. For more complex queries, use the `REGEX`
operation.

| Wildcard Character | Operation                     |
|--------------------|-------------------------------|
| `*`                | One or more of any character. |
| `?`                | Any single character.         |

### Examples

#### String Equality

```json
{
  "filters": {
    "op": "OR",
    "values": [
      // EQ is the default
      {
        "key": "name",
        "value": "some_value"
      },
      {
        "key": "name",
        "value": "some_other_value"
      }
    ]
  }
}
```

#### Date Range

```json
{
  "filters": {
    "op": "AND",
    "values": [
      {
        "op": "GT",
        "key": "createdDate",
        "value": "1985-04-12T00:00:00Z"
      },
      {
        "op": "LE",
        "key": "createdDate",
        "value": "1985-04-12T23:59:59Z"
      }
    ]
  }
}
```

