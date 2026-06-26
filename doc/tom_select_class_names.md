# Tom Select classNames Field Option

`tom_select_class_names:` is a field-level pass-through for Tom Select's internal `classNames` option.

Use it when one Tom Select-backed helper needs host-app-owned internal class hooks for Tom Select generated parts such as the control, dropdown, option, item, or loading states.

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  tom_select_class_names: {
    control: "ts-control app-select-control",
    dropdown: "ts-dropdown app-select-dropdown",
    option: "ts-option app-select-option"
  } %>
```

## Boundary

Rails Fields Kit passes the provided hash through as rendered JSON data and then into Tom Select's `classNames` option. The keys and values are Tom Select configuration, not Rails Fields Kit wrapper configuration.

Keep these lanes separate:

- `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` customize HTML that Rails Fields Kit renders around the field.
- `tom_select_class_names:` customizes Tom Select internal generated markup for that one initialized field.

## Non-goals

This option intentionally does not add:

- an initializer-level default
- production CSS or theme presets
- dark mode or density policy
- Tom Select internal DOM compatibility guarantees
- renderer markup changes
- remote search, selected preload, create flow, or request-failure changes

Host apps remain responsible for Tom Select asset setup, stylesheet ownership, class naming policy, and any compatibility checks against Tom Select internal markup.
