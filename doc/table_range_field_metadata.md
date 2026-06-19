# Table range field metadata

`rfk_range_field` is part of the native wrapper helper family, and table integrations can describe that helper through the same metadata-first path as other native inputs.

Use `RailsFieldsKit::TableFilterInput.range_field(...)` when a table filter should render a native range input:

```ruby
filter = RailsFieldsKit::TableFilterInput.range_field(
  :priority,
  min: 1,
  max: 10,
  step: 1
)
```

Use `RailsFieldsKit::TableCellInput.range_field(...)` when an editable cell should render the same native wrapper:

```ruby
editor = RailsFieldsKit::TableCellInput.range_field(
  :completion,
  min: 0,
  max: 100,
  step: 5
)
```

Both objects normalize to the existing table metadata protocol:

```ruby
filter.to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "range_field",
#      method: "priority",
#      options: { min: 1, max: 10, step: 1 }
#    }
```

`TableRenderer` maps `range_field` to `rfk_range_field` and passes the options hash through unchanged. Treat `min`, `max`, and `step` as ordinary native input options. Rails Fields Kit does not add range-pair query semantics, multi-thumb sliders, custom slider UI, table preference persistence, Ransack execution, or production styling for this metadata type.
