# Allow clear boundary

`allow_clear: true` is a field-level option for Tom Select-backed helpers. Rails Fields Kit adds Tom Select's `clear_button` plugin to that field's effective plugin list, but it does not change the helper lane, submitted value shape, request lifecycle, or host-app ownership boundaries.

Use this guide when reviewing whether `allow_clear` belongs to the current field option surface or whether a follow-up should be split into visual, event, or helper-specific work.

## Supported helper boundary

Tom Select-backed helpers can opt into `allow_clear: true`:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- `rfk_token_search`

`rfk_select` remains the representative single-value example in `field_helpers.md`. That example does not mean `allow_clear` is implemented only for `rfk_select`; it is the simplest lane for showing blank-option and placeholder ownership.

## Clear button versus remove button

`clear_button` and `remove_button` are separate Tom Select affordances:

- `clear_button` clears the whole field value.
- `remove_button` removes one selected item or token from a multi-value UI.
- `rfk_tags` and `rfk_token_search` use `remove_button` by default when `plugins:` is omitted.
- `allow_clear: true` adds `clear_button` to the effective plugin list for that field.
- Explicit `plugins:` still replaces initializer defaults and helper defaults; include any plugin names that should remain enabled.

For `rfk_tags`, `rfk_token_search`, and multi-value helpers, supporting `allow_clear` only means the rendered field may expose a whole-field clear affordance in addition to per-item removal. It does not make Rails Fields Kit own the UX copy, styling, confirmation behavior, or event contract for clearing versus removing.

## Host-app responsibility boundary

`allow_clear` does not move these responsibilities into Rails Fields Kit:

- Tom Select installation or plugin asset loading
- clear button styling or icon policy
- blank-option or placeholder wording
- remote search request lifecycle
- selected preload request lifecycle
- create-on-the-fly request lifecycle
- tag creation policy
- token parsing or search execution
- clear event payload contract beyond the existing event surface

Remote helpers such as `rfk_combobox`, `rfk_tags`, and `rfk_token_search` keep their existing endpoint boundaries. The host app still owns authorization, scoping, query handling, selected-option restoration, tag creation rules, and submitted token parsing.

## Follow-up split guidance

Keep `allow_clear` boundary work separate from these follow-ups:

- visual references for clear/remove affordances
- clear event payload contract changes
- Tom Select plugin asset or styling policy
- tag creation or token parsing behavior
- helper-specific UX redesign for multi-value fields

A docs or quality slice may clarify the current supported option boundary. Runtime changes should be justified separately and should preserve the existing default plugin behavior when `allow_clear` is not specified.
