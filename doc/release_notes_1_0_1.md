# Rails Fields Kit 1.0.1

## Host application integration

- Added `doc/host_app_integration.md` as the gem-owned contract for host applications and AI/agent workflows.
- Generated setup notes now direct consumers to `bundle show rails_fields_kit` and the documentation packaged with the resolved gem instead of linking to repository `main`.
- Gem metadata now points documentation, changelog, and source links at the matching `v1.0.1` release tag.

## Field semantics

- Documented `rfk_lookup` as the preferred helper when a field needs both free text and an optional selected master ID.
- Clarified that `value_field:` is the submitted identity/value and `label_field:` is display text; formatted labels should not be reused as selected identity merely to support LIKE-search behavior.
- `TableFilterInput.lookup` and its `TableRenderer` mapping are included in the 1.0.1 release surface.

## Free-text Tom Select behavior

- Added explicit `add_precedence:`, `create_on_blur:`, and `clear_after_select:` field-level pass-through options for Tom Select-backed helpers.
- These options are opt-in. `free_text: true` keeps its 1.0.0 behavior and does not implicitly enable any of the three settings, avoiding a patch-release behavior change.
- Host applications that previously subclassed the Rails Fields Kit controller only to set Tom Select `addPrecedence`, `createOnBlur`, or `clearAfterSelect` can move those settings back into the field helper call.

## Enum labels

- Added `config.enum_i18n_key`, a callable public extension point for `rfk_enum_select` label lookup keys.
- The default remains `"#{method}.#{value}"`, preserving existing behavior.
- Host applications that use another convention, such as `"#{method}/#{value}"`, can configure it without overriding Rails Fields Kit private FormBuilder methods.
