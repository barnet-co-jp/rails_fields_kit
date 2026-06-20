# Remote option label fallback

Remote search, selected preload, and create-on-the-fly options should include the configured `label_field:` whenever the endpoint knows a display label. By default, Rails Fields Kit keeps the forgiving display-only fallback: if the label field is missing, `null`, `undefined`, or an empty string in the browser, the Tom Select renderer shows the configured `value_field:` instead.

Use the default when endpoints may temporarily omit labels but the field should still remain readable:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  value_field: "id",
  label_field: "name" %>
```

Use `label_fallback: false` when the endpoint intentionally treats a missing or blank label as a host-app-owned strict state. In that mode, Rails Fields Kit keeps the submitted value and payload shape unchanged, but the rendered option label stays blank instead of falling back to the value.

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  value_field: "id",
  label_field: "name",
  label_fallback: false %>
```

This option only affects visible option rendering in the bundled Tom Select controller. It does not change submitted values, remote search payload shape, selected preload request encoding, create-on-the-fly request or response contracts, validation, authorization, endpoint policy, retry UI, or request lifecycle events.

Explicit labels such as `0` or `false` are still displayed as labels. Only missing, `null`, `undefined`, or empty-string labels are considered absent.
