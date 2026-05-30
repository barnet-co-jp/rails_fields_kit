# Search Field Contract

This note documents how Rails Fields Kit turns the `search_field:` helper option into the Tom Select `searchField` configuration for remote option helpers.

## Current normalization

`search_field:` accepts a comma-separated string of JSON option field names. The Tom Select controller splits the string on commas, trims surrounding whitespace from each entry, and ignores blank entries before passing the list to Tom Select.

These helper options therefore produce the same final search field list:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  search_field: "name,email" %>
```

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  search_field: "name, email," %>
```

Both normalize to:

```js
["name", "email"]
```

## Responsibility boundary

The `search_field:` values are field names inside each option object returned by the remote endpoint, such as `name` and `email` in this payload:

```json
[
  { "id": 1, "name": "Example Customer", "email": "hello@example.com" }
]
```

Rails Fields Kit forwards those normalized field names to Tom Select so the client-side option matcher knows which option fields to inspect. It does not define the server-side search semantics, authorization, scoping, ranking, or payload field naming for the endpoint. The host app remains responsible for building the endpoint and returning option objects whose keys match the documented `value_field:`, `label_field:`, and `search_field:` choices.

## Applies to

This contract applies to Tom Select-backed helpers that use remote option loading, including `rfk_combobox`, `rfk_autocomplete`, `rfk_tags`, and `rfk_token_search`. Collection-backed helpers that do not use a remote option URL stay in their rendered-collection lane.