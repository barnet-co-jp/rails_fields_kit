# Date, time, and color table metadata

`rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field` are part of the native wrapper helper family. Table integrations can describe those helpers through the same metadata-first path as other native inputs.

Use the `TableFilterInput` factories when a table filter should render one of the browser-native controls:

```ruby
starts_on_filter = RailsFieldsKit::TableFilterInput.date_field(
  :starts_on,
  min: Date.current,
  required: true
)

starts_at_filter = RailsFieldsKit::TableFilterInput.time_field(
  :starts_at,
  step: 900
)

accent_color_filter = RailsFieldsKit::TableFilterInput.color_field(:accent_color)
```

Use the matching `TableCellInput` factories when an editable cell should render the same native wrapper helpers:

```ruby
published_at_editor = RailsFieldsKit::TableCellInput.datetime_local_field(
  :published_at,
  step: 60
)

accent_color_editor = RailsFieldsKit::TableCellInput.color_field(
  :accent_color,
  disabled: false
)
```

The objects normalize to the existing table metadata protocol:

```ruby
starts_on_filter.to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "date_field",
#      method: "starts_on",
#      options: { min: Date.current, required: true }
#    }
```

```ruby
published_at_editor.to_table_cell_editor
# => {
#      type: "rails_fields_kit",
#      field_type: "datetime_local_field",
#      method: "published_at",
#      options: { step: 60 }
#    }
```

`TableRenderer` maps these metadata field types to the matching FormBuilder helpers:

| Metadata field type | Rendered helper |
| --- | --- |
| `date_field` | `rfk_date_field` |
| `time_field` | `rfk_time_field` |
| `datetime_local_field` | `rfk_datetime_local_field` |
| `color_field` | `rfk_color_field` |

Options such as `min:`, `max:`, `step:`, `required:`, `disabled:`, `readonly:`, `label:`, `hint:`, `wrapper_html:`, and `html:` stay ordinary Rails Fields Kit wrapper or native input options. They travel through metadata `options` and are passed to the corresponding helper when rendered.

Rails Fields Kit owns the metadata object, renderer mapping, wrapper, hint, error, affix, and accessibility wiring for the rendered native input. The host application or table integration owns browser-native picker behavior, timezone conversion, locale formatting, masking, custom picker UI, custom color palette UI, browser validation-message policy, query execution, table preference persistence, authorization, and production CSS.

Use this table metadata lane when the browser-native date, time, datetime-local, or color control is already the right UI for a column. Choose a host-app component or custom table renderer mapping instead when the product needs timezone-specific scheduling UI, non-native calendars, masked date entry, custom color palettes, or table-query semantics beyond rendering the input.

For the helper-level boundary shared by these controls, see [`native_date_time_color_fields.md`](native_date_time_color_fields.md). For the broader metadata protocol, column collection, renderer registry, and table responsibility boundary, see [`table_adapters.md`](table_adapters.md).
