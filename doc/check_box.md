# Checkbox Wrapper Helper

`rfk_check_box` is the Rails Fields Kit native wrapper lane for a single Rails checkbox control.

Use it when a host app wants the ordinary Rails `check_box` parameter contract while reusing Rails Fields Kit wrapper, label, hint, validation error, and accessibility wiring.

For release or sample-app evidence, use [`check_box_release_evidence.md`](check_box_release_evidence.md) to choose a representative checkbox lane without expanding this helper into radio buttons, collection groups, validation UI policy, label placement redesign, or production CSS ownership.

```erb
<%= f.rfk_check_box :active,
  wrapper: true,
  label: "Active?",
  hint: "Enable only after review",
  checked_value: "yes",
  unchecked_value: "no" %>
```

## Rails Helper Contract

`rfk_check_box` delegates to Rails' standard `check_box` helper. Rails Fields Kit does not replace the checkbox submission contract:

- the hidden unchecked field stays enabled by default
- `checked_value:` and `unchecked_value:` are passed to Rails' helper
- model-backed checked state follows Rails' normal `check_box` behavior
- ordinary checkbox options such as `checked:`, `disabled:`, `required:`, and `data:` remain field options

Use `html:` when you want to group input attributes next to wrapper customization. If the same attribute appears both at the top level and in `html:`, the `html:` value wins because Rails Fields Kit merges it into the field options last.

## Wrapper And Accessibility Boundary

With `wrapper: true`, the helper uses the same generated pieces as the native text-oriented helpers:

- `label:` / `label_html:` for the generated label
- `hint:` / `hint_html:` for helper text
- `error_html:` for validation error output
- `wrapper_html:` for the outer wrapper
- `accessibility: false` to opt out of automatic `aria-describedby`, `aria-invalid`, and `aria-required` wiring

Generated hint and error ids use the form object name and method, for example `user_active_hint` and `user_active_error`. Passing a custom checkbox `id:` does not rename those generated ids, so repeated fields should use distinct object names or host-owned ids with `accessibility: false`.

## Release Evidence Boundary

Sample app and release evidence should stay representative:

- check one model-backed checkbox lane instead of mirroring every native helper option
- record hidden unchecked input, checked/unchecked values, wrapper pieces, validation rerender, and accessibility boundary only when that release or PR depends on them
- keep radio buttons, collection groups, visual references, validation UI, final copy, and production CSS as separate host-app or follow-up decisions

## Non-goals

This helper intentionally stays small:

- no `rfk_radio_button` helper in this slice
- no collection checkbox or radio group DSL
- no replacement for Rails hidden-field behavior
- no label-placement redesign beyond the existing wrapper convention
- no visual reference expansion or production CSS redesign
- no built-in validation policy or business-specific checked-state copy

If radio buttons or collection-style groups need Rails Fields Kit wrappers later, handle them as separate feature issues so their grouping, legend, and accessibility contracts can be reviewed independently.
