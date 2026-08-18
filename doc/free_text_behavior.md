# Free-text Tom Select behavior options

Rails Fields Kit 1.0.1 exposes three field-level Tom Select behavior pass-throughs for host applications that need more explicit free-text entry behavior:

- `add_precedence:` forwards Tom Select `addPrecedence`.
- `create_on_blur:` forwards Tom Select `createOnBlur`.
- `clear_after_select:` forwards Tom Select `clearAfterSelect`.

These options are explicit opt-ins. `free_text: true` continues to enable free-text creation without automatically changing these Tom Select settings, preserving existing behavior for applications upgrading from 1.0.0.

```erb
<%= f.rfk_combobox :repository_full_name,
  url: repositories_path(format: :json),
  free_text: true,
  add_precedence: true,
  create_on_blur: true %>
```

For a multiple-value field that should clear the typed query after an item is accepted, opt in separately:

```erb
<%= f.rfk_tags :labels,
  free_text: true,
  clear_after_select: true %>
```

Rails Fields Kit only forwards these values to Tom Select. Host applications remain responsible for deciding whether create-on-blur, create-option precedence, or post-selection query clearing is appropriate for a specific field.

## Related existing APIs

Before replacing the Rails Fields Kit controller in a host application, check the existing public options:

- Use `dropdown_parent: "body"` when a dropdown must render outside an overflow container. Overlay positioning policy, nested-scroll close behavior, z-index, and framework-specific modal behavior remain host-app responsibilities.
- Use `depends_on:` with `clear_on_dependency_change:` for dependent remote-search query params and selection clearing.
- Use `html: { data: { action: "rails-fields-kit--tom-select:change->example#changed" } }` to subscribe an app-owned Stimulus controller to Rails Fields Kit events.
- Use `error_surface: true` and `rails-fields-kit--tom-select:selected-load-error` for selected-preload failure feedback.

These existing routes should be preferred over subclassing or replacing the Rails Fields Kit Tom Select controller when they cover the required behavior.
