# Rails Fields Kit 1.0.1

## Host application integration

- Added `doc/host_app_integration.md` as the gem-owned contract for host applications and AI/agent workflows.
- Generated setup notes now direct consumers to `bundle show rails_fields_kit` and the documentation packaged with the resolved gem instead of linking to repository `main`.
- Gem metadata now points documentation, changelog, and source links at the matching `v1.0.1` release tag.

## Field semantics

- Documented `rfk_lookup` as the preferred helper when a field needs both free text and an optional selected master ID.
- Clarified that `value_field:` is the submitted identity/value and `label_field:` is display text; formatted labels should not be reused as selected identity merely to support LIKE-search behavior.
- `TableFilterInput.lookup` and its `TableRenderer` mapping are included in the 1.0.1 release surface.

## Enum labels

- Added `config.enum_i18n_key`, a callable public extension point for `rfk_enum_select` label lookup keys.
- The default remains `"#{method}.#{value}"`, preserving existing behavior.
- Host applications that use another convention, such as `"#{method}/#{value}"`, can configure it without overriding Rails Fields Kit private FormBuilder methods.
