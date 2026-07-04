# Radio button table metadata

`TableFilterInput.radio_button` describes one Rails radio button as filter metadata. `TableCellInput.radio_button` describes one Rails radio button as cell-editor metadata. Both are small bridges from a table column definition to the existing `rfk_radio_button` FormBuilder helper.

```ruby
filter = RailsFieldsKit::TableFilterInput.radio_button(
  :status,
  tag_value: "published",
  label: "Published"
)

filter.to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "radio_button",
#      method: "status",
#      options: {
#        tag_value: "published",
#        label: "Published"
#      }
#    }
```

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
call = RailsFieldsKit::TableRenderer.filter_call(filter)
# => {
#      helper: :rfk_radio_button,
#      method: :status,
#      options: {
#        tag_value: "published",
#        label: "Published"
#      }
#    }
```

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

`tag_value:` is required because Rails' native `radio_button` helper needs a concrete submitted value. `TableFilterInput.radio_button` stores that value in metadata options, and `TableRenderer.render_filter` raises `ArgumentError` if `tag_value:` is missing before dispatching to `rfk_radio_button`. Other options stay ordinary Rails Fields Kit wrapper or native radio options and are forwarded to `rfk_radio_button` during rendering.

The filter factory is renderable control metadata only. It does not make Rails Fields Kit own same-name radio grouping, boolean or enum query semantics, params construction, `fieldset` / `legend` generation, collection radio groups, table persistence, or production styling. Host apps and table integrations remain responsible for deciding whether a radio button belongs in a filter UI, how a checked value maps to a query, and how multiple radio choices are grouped.

`TableCellInput.radio_button` remains the cell-editor lane. The filter factory does not change cell-editor behavior, and the visual reference lane for cell editors stays separate from filter semantics.

Non-goals:

- collection radio group helpers
- `fieldset` / `legend` builders
- group-level hint or error UI
- table query execution or persistence
- boolean or enum filter semantics
- params construction or Ransack integration
- production CSS or visual reference changes
