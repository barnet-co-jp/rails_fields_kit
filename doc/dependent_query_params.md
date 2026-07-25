# Dependent query params for remote Tom Select fields

Tom Select-backed remote helpers can derive search request query params from other inputs on the page with `depends_on:`.

```erb
<%= f.rfk_combobox :product_id,
  url: search_options_path("products"),
  query_params: { scope: "active" },
  depends_on: {
    category: "#detail-category",
    account_item_id: "#detail-account-item"
  },
  clear_on_dependency_change: true %>
```

`depends_on:` accepts a hash where each key is the query param name and each value is a selector for an input or select element. When Rails Fields Kit sends the remote search request, it reads the current value of each dependency and merges those values into the remote search params.

Dependency values are request-scoped, not selected-preload scoped. `selected_url:` continues to use only `selected_query_params:` plus the selected id or ids, so label hydration for saved values is not filtered by the current dependency inputs.

## Param merging

Remote search params are built in this order:

1. fixed `query_params:` values
2. current `depends_on:` values
3. typed search query under `query_param:`

A dependency value with the same key as `query_params:` wins for that request. Blank dependency values are omitted. Multiple-select dependency values are sent as repeated query entries by the existing array query-param behavior.

Endpoint meaning, authorization, account scoping, and valid combinations remain host-app responsibility. Rails Fields Kit only forwards the current dependency values into the existing remote-search request lane.

## Dependency changes

When a dependency field changes, Rails Fields Kit aborts any in-flight remote search, clears cached remote options, and dispatches:

```text
rails-fields-kit--tom-select:dependency-change
```

Event detail includes:

```js
{
  params,
  previousParams,
  changed
}
```

`params` is the current dependency-param object, `previousParams` is the prior dependency-param object, and `changed` maps changed keys to `{ previous, current }` values.

If the dropdown is open, the controller reloads the current Tom Select query after clearing cached options so the open list does not reuse stale results. Turbo reconnect and disconnect remove dependency listeners before rebinding, so replacing a form does not duplicate listeners.

## Selection clearing

By default, changing a dependency keeps the existing selection:

```erb
<%= f.rfk_autocomplete :product_name,
  url: search_options_path("products"),
  depends_on: { category: "#detail-category" } %>
```

Use `clear_on_dependency_change: true` when the selected value should be cleared as soon as any dependency value changes:

```erb
<%= f.rfk_combobox :product_id,
  url: search_options_path("products"),
  depends_on: { category: "#detail-category" },
  clear_on_dependency_change: true %>
```

This option only changes the client-side selection behavior for that field. It does not validate whether the old value is still allowed, change server-side completion rules, or introduce hidden-id lookup behavior.
