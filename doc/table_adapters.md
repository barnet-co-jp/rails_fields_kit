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

## Token search filter metadata

Use `TableFilterInput.token_search` when a table has a single search box backed by `rfk_token_search`.

```ruby
filter = RailsFieldsKit::TableFilterInput.token_search(
  :query,
  url: search_tokens_path(format: :json),
  placeholder: "status:open keyword"
)

filter.to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "token_search",
#      method: "query",
#      options: {
#        url: "/search_tokens.json",
#        placeholder: "status:open keyword"
#      }
#    }
```

Use `TableFilterInput.ransack_filter` when the token search should carry Ransack-oriented metadata for a table renderer or host application parser.

```ruby
filter = RailsFieldsKit::TableFilterInput.ransack_filter(
  :query,
  fields: {
    name: :name_cont,
    status: :status_eq
  },
  url: search_tokens_path(format: :json),
  param_name: :q
)
```

This metadata declares the intended adapter and allowed fields. It does not parse token text, build `params[:q]`, or execute Ransack. The host application or table integration remains responsible for those steps.

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

A host app or table helper can pass the metadata objects into column-like definitions:

```ruby
{
  key: :customer_id,
  filter: RailsFieldsKit::TableFilterInput.new(
    :combobox,
    :customer_id,
    url: customers_path(format: :json),
    selected_url: selected_customers_path(format: :json)
  )
}
```

```ruby
{
  key: :query,
  filter: RailsFieldsKit::TableFilterInput.ransack_filter(
    :query,
    fields: {
      name: :name_cont,
      status: :status_eq
    },
    url: search_tokens_path(format: :json)
  )
}
```

```ruby
{
  key: :status,
  editor: RailsFieldsKit::TableCellInput.new(:enum_select, :status)
}
```

A table preferences implementation can normalize these values by calling `to_table_filter` if the filter object responds to it, or `to_table_cell_editor` if the editor object responds to it.