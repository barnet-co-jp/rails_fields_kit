# Table adapter metadata

Rails Fields Kit can be used by table-oriented gems without forcing those gems to depend on Rails Fields Kit.

The adapter objects in this document expose small metadata protocols that other gems can read when Rails Fields Kit is present.

## Filter input metadata

Use `RailsFieldsKit::TableFilterInput` when a table column wants to describe a filter UI that should be rendered with Rails Fields Kit.

```ruby
filter = RailsFieldsKit::TableFilterInput.new(
  :combobox,
  :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  value_field: "id",
  label_field: "name"
)

filter.to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "combobox",
#      method: "customer_id",
#      options: { ... }
#    }
```

A table gem can accept any object that responds to `to_table_filter`, store the resulting hash in column metadata, and leave rendering to the host application or a renderer registry.

## Cell editor metadata

Use `RailsFieldsKit::TableCellInput` when a table column wants to describe an editable cell control.

```ruby
editor = RailsFieldsKit::TableCellInput.new(
  :enum_select,
  :status
)

editor.to_table_cell_editor
# => {
#      type: "rails_fields_kit",
#      field_type: "enum_select",
#      method: "status",
#      options: {}
#    }
```

This keeps table definitions and Active Record introspection flows independent from a concrete form renderer while still allowing Rails Fields Kit to provide richer inputs when installed.

## Intended integration with Rails Table Preferences

A host app or table helper can pass the metadata object into a column-like object:

```ruby
{
  key: :customer_id,
  filter: RailsFieldsKit::TableFilterInput.new(:combobox, :customer_id, url: customers_path(format: :json))
}
```

A table preferences implementation can normalize this by calling `to_table_filter` if the filter object responds to it.
