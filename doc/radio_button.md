# Radio Button Wrapper Helper

`rfk_radio_button` is the Rails Fields Kit native wrapper lane for one Rails radio input.

Use it when a host app wants Rails' ordinary `radio_button` name, value, and checked-state behavior while reusing Rails Fields Kit wrapper, label, hint, validation error, and accessibility wiring for a single option.

```erb
<%= f.rfk_radio_button :status, "published",
  wrapper: true,
  label: "Published",
  hint: "Choose this when the record is visible" %>
```

## Rails Helper Contract

`rfk_radio_button` delegates to Rails' standard `radio_button` helper. Rails Fields Kit does not replace radio submission or grouping behavior:

- the `tag_value` argument is passed to Rails as the radio value
- model-backed checked state follows Rails' normal `radio_button` behavior
- multiple radio buttons for the same method keep the same input name and different ids
- ordinary radio options such as `checked:`, `disabled:`, `required:`, and `data:` remain field options

Use `html:` when you want to group input attributes next to wrapper customization. If the same attribute appears both at the top level and in `html:`, the `html:` value wins because Rails Fields Kit merges it into the field options last.

## Wrapper And Accessibility Boundary

With `wrapper: true`, the helper uses the shared native wrapper pieces:

- `label:` / `label_html:` for the generated label
- `hint:` / `hint_html:` for helper text
- `error_html:` for validation error output
- `wrapper_html:` for the outer wrapper
- `accessibility: false` to opt out of automatic `aria-describedby`, `aria-invalid`, and `aria-required` wiring

By default the generated label is tied to the radio id for the given `tag_value`, matching Rails' value-specific radio id. Passing `label_html: { value: ... }` remains available when a host app intentionally needs a different Rails label value.

Generated hint and error ids use the form object name and method, for example `user_status_hint` and `user_status_error`. For repeated controls that need custom ids or group-level accessible descriptions, keep that grouping markup in the host app and set `accessibility: false` on individual radio helpers as needed.

## Release Evidence

When a release or narrow PR needs sample-app evidence for this helper, use [`radio_button_release_evidence.md`](radio_button_release_evidence.md). Keep the evidence focused on one radio option's wrapper, label, hint, validation error, checked state, `tag_value`, and accessibility wiring. Do not record collection group, fieldset / legend, group validation UI, production CSS, or business state policy as Rails Fields Kit-owned behavior.

## Non-goals

This helper intentionally stays small:

- no collection radio group DSL
- no collection checkbox group DSL
- no `fieldset` or `legend` builder
- no replacement for Rails checked/value/name behavior
- no group-level validation UI or layout policy
- no visual reference expansion or production CSS redesign
- no authorization, persistence, query, or business-specific state policy

Use ordinary Rails collection helpers or host-app markup when the application needs group semantics, fieldsets, legends, collection iteration, or custom layout. Handle those as separate feature issues if Rails Fields Kit should ever own them.
