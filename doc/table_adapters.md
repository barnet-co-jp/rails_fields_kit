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
```

Common field types also have factory helpers:

```ruby
filter = RailsFieldsKit::TableFilterInput.combobox(
  :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  value_field: "id",
  label_field: "name"
)
```

When the field type is chosen dynamically, use `from_type`:

```ruby
filter = RailsFieldsKit::TableFilterInput.from_type(
  field_type,
  :customer_id,
  url: customers_path(format: :json)
)
```

Use `known_type?` when table integrations want to validate a configured field type before rendering:

```ruby
RailsFieldsKit::TableFilterInput.known_type?(field_type)
RailsFieldsKit::TableFilterInput.known_types
```

```ruby
filter.to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "combobox",
#      method: "customer_id",
#      options: { ... }
#    }
```

`to_h` and `to_hash` return the same metadata hash as `to_table_filter` for integrations that prefer a generic hash protocol.

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

This is the current public entrypoint for Ransack-oriented table filter metadata. It declares the intended adapter and allowed fields, but it does not parse token text, build `params[:q]`, or execute Ransack. The host application or table integration remains responsible for those steps.

The helper-level DSL shown in `ROADMAP.md`, such as `rfk_table_filters @table_preferences, adapter: :ransack`, is still a future proposal. Current integrations should keep preparing metadata first and then render it through `rfk_table_filters(columns)`.

## Cell editor metadata

Use `RailsFieldsKit::TableCellInput` when a table column wants to describe an editable cell control.

```ruby
editor = RailsFieldsKit::TableCellInput.new(
  :enum_select,
  :status
)
```

Common field types also have factory helpers:

```ruby
editor = RailsFieldsKit::TableCellInput.enum_select(:status)
```

When the field type is chosen dynamically, use `from_type`:

```ruby
editor = RailsFieldsKit::TableCellInput.from_type(
  field_type,
  :status
)
```

Use `known_type?` when table integrations want to validate a configured editor type before rendering:

```ruby
RailsFieldsKit::TableCellInput.known_type?(field_type)
RailsFieldsKit::TableCellInput.known_types
```

```ruby
editor.to_table_cell_editor
# => {
#      type: "rails_fields_kit",
#      field_type: "enum_select",
#      method: "status",
#      options: {}
#    }
```

`to_h` and `to_hash` return the same metadata hash as `to_table_cell_editor` for integrations that prefer a generic hash protocol.

This keeps table definitions and Active Record introspection flows independent from a concrete form renderer while still allowing Rails Fields Kit to provide richer inputs when installed.

## Collecting metadata from columns

`RailsFieldsKit::TableMetadata` can collect Rails Fields Kit filter/editor metadata from hash-like or object-like column definitions. It also accepts a table-like object that responds to `columns`.

```ruby
columns = [
  {
    key: :customer_id,
    filter: RailsFieldsKit::TableFilterInput.combobox(
      :customer_id,
      url: customers_path(format: :json)
    )
  },
  {
    key: :status,
    editor: RailsFieldsKit::TableCellInput.enum_select(:status)
  }
]

filters = RailsFieldsKit::TableMetadata.filters(columns)
editors = RailsFieldsKit::TableMetadata.cell_editors(columns)
```

```ruby
table = OpenStruct.new(columns: columns)

filter_calls = RailsFieldsKit::TableMetadata.filter_calls(table)
editor_calls = RailsFieldsKit::TableMetadata.cell_editor_calls(table)
```

Column lists can be arrays or enumerable objects such as enumerators. A single hash is treated as one column definition, not as a list of key-value pairs. Table-like objects can also return a single hash column or a single object column directly from `columns`.

```ruby
RailsFieldsKit::TableMetadata.filters(columns.each)
RailsFieldsKit::TableMetadata.filters(filter: RailsFieldsKit::TableFilterInput.search_field(:keyword))
```

```ruby
single_hash_table = OpenStruct.new(
  columns: {
    filter: RailsFieldsKit::TableFilterInput.search_field(:keyword)
  }
)

single_object_table = OpenStruct.new(
  columns: Struct.new(:filter).new(
    RailsFieldsKit::TableFilterInput.search_field(:keyword)
  )
)
```

Filter aliases are also recognized: `filter`, `filter_input`, and `search_filter`. Cell editor aliases are `editor`, `cell_editor`, and `cell_input`. These names work as hash keys or public object methods. For struct-like objects, only declared members are considered metadata readers so inherited `Enumerable` methods such as `filter` are ignored.

It also exposes convenience methods that collect metadata and immediately convert it to FormBuilder call specs:

```ruby
filter_calls = RailsFieldsKit::TableMetadata.filter_calls(columns)
editor_calls = RailsFieldsKit::TableMetadata.cell_editor_calls(columns)
```

When a table integration already has a FormBuilder, it can render directly from the column definitions:

```ruby
RailsFieldsKit::TableMetadata.render_filters(form_builder, columns)
RailsFieldsKit::TableMetadata.render_cell_editors(form_builder, columns)
```

`nil` and `false` filters/editors are skipped. Raw metadata hashes are preserved. Objects responding to `to_table_filter` or `to_table_cell_editor` are normalized through those protocols, and hash-like metadata objects responding to `to_hash` are normalized through `to_hash`. A `to_hash` implementation must return a Hash-like object.

Collected metadata hashes are duplicated before being returned. Nested `options` hashes are also duplicated so downstream mutation does not alter the original column definition, hash-like metadata object, or hash-like column object.

## Rendering metadata

`RailsFieldsKit::TableRenderer` turns metadata into FormBuilder call specs or directly dispatches to a form builder.

```ruby
call = RailsFieldsKit::TableRenderer.filter_call(filter)
# => {
#      helper: :rfk_combobox,
#      method: :customer_id,
#      options: { url: "/customers.json" }
#    }
```

A table integration can use the call spec with its own rendering pipeline:

```ruby
form_builder.public_send(call.fetch(:helper), call.fetch(:method), **call.fetch(:options))
```

Or it can call the renderer directly:

```ruby
RailsFieldsKit::TableRenderer.render_filter(form_builder, filter)
RailsFieldsKit::TableRenderer.render_cell_editor(form_builder, editor)
```

`TableRenderer` also accepts hash-like metadata objects directly when they implement `to_hash` and return a Hash-like metadata object.

```ruby
metadata = Struct.new(:field_type, :method, :options) do
  def to_hash
    {
      field_type: field_type,
      method: method,
      options: options
    }
  end
end

RailsFieldsKit::TableRenderer.filter_call(
  metadata.new("combobox", :customer_id, url: "/customers.json")
)
```

For table definitions with many columns, use the batch APIs. Batch normalization treats `nil` as an empty list, a single hash as one metadata object, arrays as-is, enumerables through `to_a`, and other single objects as one metadata entry.

```ruby
filter_calls = RailsFieldsKit::TableRenderer.filter_calls(filters)
editor_calls = RailsFieldsKit::TableRenderer.cell_editor_calls(editors)
```

```ruby
RailsFieldsKit::TableRenderer.render_filters(form_builder, filters)
RailsFieldsKit::TableRenderer.render_cell_editors(form_builder, editors)
```

Use `helper_for` and `registered_field_type?` when an integration needs to inspect renderer mappings, including custom registrations.

```ruby
RailsFieldsKit::TableRenderer.helper_for(:combobox)
RailsFieldsKit::TableRenderer.registered_field_type?(:combobox)
```

The renderer is intentionally thin. It maps documented Rails Fields Kit `field_type` values to FormBuilder helper names and does not own table preference persistence, query parsing, authorization, or result rendering.

## Custom table field helpers

Table integrations can register additional field type mappings without monkey-patching Rails Fields Kit.

```ruby
RailsFieldsKit::TableRenderer.register_field_helper(
  :custom_field,
  :custom_table_field
)

filter = {
  field_type: "custom_field",
  method: "code",
  options: { prefix: "#" }
}

RailsFieldsKit::TableRenderer.filter_call(filter)
# => {
#      helper: :custom_table_field,
#      method: :code,
#      options: { prefix: "#" }
#    }
```

Use `RailsFieldsKit::TableRenderer.field_helpers`, `RailsFieldsKit::TableRenderer.helper_for`, and `RailsFieldsKit::TableRenderer.registered_field_type?` to inspect the current mapping. Use `RailsFieldsKit::TableRenderer.reset_field_helpers!` to restore the defaults.

## Intended integration with Rails Table Preferences

A host app or table helper can pass the metadata objects into column-like definitions:

```ruby
{
  key: :customer_id,
  filter: RailsFieldsKit::TableFilterInput.combobox(
    :customer_id,
    url: customers_path(format: :json),
    selected_url: selected_customers_path(format: :json)
  )
}
```

```ruby
{
  key: :query,
  filter_input: RailsFieldsKit::TableFilterInput.ransack_filter(
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
  cell_editor: RailsFieldsKit::TableCellInput.enum_select(:status)
}
```

A table preferences implementation can normalize these values by calling `RailsFieldsKit::TableMetadata.filters` or `RailsFieldsKit::TableMetadata.cell_editors` on either its column list or the table object itself. It can then call `RailsFieldsKit::TableRenderer.filter_call`, `RailsFieldsKit::TableRenderer.cell_editor_call`, or the `RailsFieldsKit::TableMetadata` render shortcuts to map metadata to Rails Fields Kit FormBuilder helpers.