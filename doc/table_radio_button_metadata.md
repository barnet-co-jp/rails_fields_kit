# Radio button table metadata

`TableCellInput.radio_button` describes one Rails radio button as cell-editor metadata. It is a small bridge from a table column definition to the existing `rfk_radio_button` FormBuilder helper.

```ruby
editor = RailsFieldsKit::TableCellInput.radio_button(
  :status,
  tag_value: "published",
  label: "Published",
  checked: true
)

editor.to_table_cell_editor
# => {
#      type: "rails_fields_kit",
#      field_type: "radio_button",
#      method: "status",
#      options: {
#        tag_value: "published",
#        label: "Published",
#        checked: true
#      }
#    }
```

`TableRenderer` maps `radio_button` metadata to `rfk_radio_button`. The renderer keeps `tag_value` in metadata options for call-spec inspection, then passes it as the helper's positional radio value when rendering.

```ruby
call = RailsFieldsKit::TableRenderer.cell_editor_call(editor)
# => {
#      helper: :rfk_radio_button,
#      method: :status,
#      options: {
#        tag_value: "published",
#        label: "Published",
#        checked: true
#      }
#    }
```

`tag_value:` is required for `TableCellInput.radio_button` because Rails' native `radio_button` helper needs a concrete submitted value. Other options stay ordinary Rails Fields Kit wrapper or native radio options and are forwarded to `rfk_radio_button` during rendering.

This first slice is cell-editor-only. `TableFilterInput.radio_button` is intentionally not a built-in factory type, because radio filters quickly imply query semantics, enum or boolean interpretation, same-name grouping policy, and group-level validation UI. Host apps or table integrations that need those semantics should keep them in application code, ordinary Rails markup, or an explicit custom renderer mapping.

Non-goals:

- collection radio group helpers
- `fieldset` / `legend` builders
- group-level hint or error UI
- table query execution or persistence
- boolean or enum filter semantics
- production CSS or visual reference changes
