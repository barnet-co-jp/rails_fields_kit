# Table adapter metadata

Rails Fields Kit can be used by table-oriented gems without forcing those gems to depend on Rails Fields Kit.

The adapter objects in this document expose small metadata protocols that other gems can read when Rails Fields Kit is present.

For a product-neutral visual comparison of representative `rfk_table_filters(columns)` and `rfk_table_cell_editors(columns)` lanes, including the token-search editor lane, see [`table_metadata_visual_reference.html`](table_metadata_visual_reference.html).

For the focused boundary between the direct FormBuilder helpers and lower-level render/call-spec lanes, see [`table_direct_helper_boundary.md`](table_direct_helper_boundary.md).

For range-specific table metadata examples, use [`table_range_field_metadata.md`](table_range_field_metadata.md). It keeps `TableFilterInput.range_field` and `TableCellInput.range_field` in the native metadata lane without adding range-pair query semantics, custom sliders, table persistence, or production styling.

For checkbox table metadata, use [`table_check_box_metadata.md`](table_check_box_metadata.md). It keeps `TableFilterInput.check_box` and `TableCellInput.check_box` in the metadata and renderer lane without adding boolean query semantics, tri-state filtering, bulk edit, table persistence, or production styling.

For date, time, datetime-local, and color table metadata examples, use [`table_date_time_color_metadata.md`](table_date_time_color_metadata.md). It keeps `TableFilterInput.date_field`, `TableFilterInput.time_field`, `TableFilterInput.datetime_local_field`, `TableFilterInput.color_field`, and the matching `TableCellInput` factories in the native metadata lane without adding custom pickers, timezone conversion, masking, query persistence, or table-specific validation policy.

For file input cell-editor metadata, use [`table_file_field_metadata.md`](table_file_field_metadata.md). It keeps `TableCellInput.file_field` cell-editor-only and does not add `TableFilterInput.file_field`, upload execution, query semantics, table persistence, or production styling.

## Table responsibility boundary

Rails Fields Kit table metadata describes which Rails Fields Kit control can be rendered for a table column. It does not own the table's result set or navigation policy.

`rfk_table_filters`, `rfk_table_cell_editors`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer` can collect metadata, keep field type / helper mapping / rendered contract details together, and produce FormBuilder call specs or rendered controls. The host application or table integration still owns result pagination, sorting, page-size selector choices, cursor or offset policy, query params construction, authorization, persistence, and user-visible feedback.

Use table metadata as the UI bridge for the filter or editor controls attached to a column. Keep pagination controls, sort links, saved sort state, page-size persistence, and search execution in the table integration or host app layer, even when the filter UI is rendered with Rails Fields Kit helpers.

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

Use `known_type?` when table integrations want to validate that a configured filter type is one of the built-in Rails Fields Kit factory types before rendering:

```ruby
RailsFieldsKit::TableFilterInput.known_type?(field_type)
RailsFieldsKit::TableFilterInput.known_types
```

`known_types` is intentionally limited to the built-in factory family. It does not include custom mappings added with `TableRenderer.register_field_helper`; use `TableRenderer.registered_field_type?` when validation needs to include those custom renderable types.

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

When this metadata is rendered through `rfk_table_filters(columns)`, `RailsFieldsKit::TableMetadata.render_filters`, or `RailsFieldsKit::TableRenderer.render_filter`, Rails Fields Kit keeps the Ransack adapter metadata on the rendered token-search field. Host-app scripts can read that rendered contract without reaching into the Stimulus controller:

```js
import { readRenderedTableFilterMetadata } from "rails_fields_kit"

const metadata = readRenderedTableFilterMetadata(queryField)
// => { adapter: "ransack", paramName: "q", fields: { name: "name_cont" } }
```

Use the rendered metadata as a bridge back to the same host-app parser allowlist, not as a Rails Fields Kit query engine. The helper returns `null` when the element is not a rendered table-filter metadata lane, and it does not parse token text, build `params[:q]`, authorize fields, or call Ransack.

For a copyable host-app example that turns submitted token text into `params[:q]`, see [`ransack_suggestions.md`](ransack_suggestions.md#copyable-host-app-parser-example).

The helper-level DSL shown in `ROADMAP.md`, such as `rfk_table_filters @table_preferences, adapter: :ransack`, is still a future proposal. Current integrations should keep preparing metadata first and then render it through `rfk_table_filters(columns)`.

## Shared metadata source pattern

When token suggestions, Ransack suggestions, and table filters should advertise the same allowed fields, keep that metadata in the host app and pass derived maps into each current Rails Fields Kit surface. This is a docs pattern, not a public registry object.

```ruby
ORDER_SEARCH_FIELDS = {
  status: {
    label: "Status",
    values: %w[open closed],
    ransack_predicate: :status_eq
  },
  assignee: {
    label: "Assignee",
    ransack_predicate: :assignee_name_cont
  }
}.freeze

ransack_fields = ORDER_SEARCH_FIELDS.transform_values do |config|
  {
    label: config.fetch(:label),
    predicate: config.fetch(:ransack_predicate),
    values: config[:values]
  }.compact
end

filter = RailsFieldsKit::TableFilterInput.ransack_filter(
  :query,
  fields: ransack_fields,
  url: search_tokens_path(format: :json),
  param_name: :q
)
```

Use the same derived `ransack_fields` map with `RailsFieldsKit::RansackSuggestions.build` when the token suggestion endpoint should expose the same predicates. Use a smaller view of `ORDER_SEARCH_FIELDS` with `RailsFieldsKit::TokenSuggestions.build` when the endpoint only needs general field and value suggestions.

Rails Fields Kit still only receives ordinary builder arguments and table metadata. The host app owns the allowed-field source, current-user filtering, submitted token parsing, `params[:q]` construction, authorization, and Ransack execution.

For the suggestion-builder views of the same source, see [`token_suggestions.md`](token_suggestions.md#shared-metadata-source-pattern) and [`ransack_suggestions.md`](ransack_suggestions.md#shared-metadata-source-pattern).

## Native field metadata

`TableFilterInput` and `TableCellInput` also cover the native helper family listed in [`public_api.md`](public_api.md), so a table integration can stay metadata-first even when it does not need Tom Select.

```ruby
columns = [
  {
    key: :keyword,
    filter_input: RailsFieldsKit::TableFilterInput.search_field(
      :keyword,
      placeholder: "Search orders"
    )
  },
  {
    key: :minimum_total,
    filter_input: RailsFieldsKit::TableFilterInput.money_field(
      :minimum_total,
      step: 0.01,
      placeholder: "Minimum total"
    )
  },
  {
    key: :priority,
    filter_input: RailsFieldsKit::TableFilterInput.range_field(
      :priority,
      min: 1,
      max: 10,
      step: 1
    )
  },
  {
    key: :starts_on,
    filter_input: RailsFieldsKit::TableFilterInput.date_field(
      :starts_on,
      min: Date.current
    )
  },
  {
    key: :published_at,
    cell_editor: RailsFieldsKit::TableCellInput.datetime_local_field(
      :published_at,
      step: 60
    )
  },
  {
    key: :accent_color,
    cell_editor: RailsFieldsKit::TableCellInput.color_field(:accent_color)
  },
  {
    key: :notes,
    cell_editor: RailsFieldsKit::TableCellInput.text_area(
      :notes,
      rows: 3
    )
  }
]
```

Range metadata travels through this same native metadata path. Use [`table_range_field_metadata.md`](table_range_field_metadata.md) when the table column needs `TableFilterInput.range_field` or `TableCellInput.range_field` examples, `min` / `max` / `step` pass-through notes, or the boundary that keeps range-pair queries, Ransack execution, custom sliders, multi-thumb controls, table persistence, and production CSS outside Rails Fields Kit.

Date, time, datetime-local, and color metadata also travel through this native metadata path. Use [`table_date_time_color_metadata.md`](table_date_time_color_metadata.md) when the table column needs `TableFilterInput.date_field`, `TableFilterInput.time_field`, `TableFilterInput.datetime_local_field`, `TableFilterInput.color_field`, or the matching `TableCellInput` examples, option pass-through notes, and the boundary that keeps browser-native picker behavior, timezone or locale formatting, masking, custom color palettes, validation policy, query execution, and persistence outside Rails Fields Kit.

Contact and search wrappers travel through the same native metadata path. Use them when the table column wants ordinary browser-native contact or search inputs with Rails Fields Kit wrapper wiring, not remote suggestions or token parsing:

```ruby
contact_columns = [
  {
    key: :contact_email,
    filter_input: RailsFieldsKit::TableFilterInput.email_field(
      :contact_email,
      autocomplete: "email"
    )
  },
  {
    key: :website_url,
    cell_editor: RailsFieldsKit::TableCellInput.url_field(:website_url)
  },
  {
    key: :phone,
    cell_editor: RailsFieldsKit::TableCellInput.phone_field(
      :phone,
      autocomplete: "tel"
    )
  }
]
```

`search_field` in this metadata family maps to the browser-native `rfk_search_field` wrapper. It does not call remote suggestion endpoints, parse token text, execute table queries, or own search result behavior. Use Tom Select-backed `autocomplete` / `combobox` metadata for remote suggestions, and `token_search` / `ransack_filter` metadata when structured token text or Ransack-oriented metadata is in scope. For the detailed contact/search ownership boundary, see [`native_contact_fields.md`](native_contact_fields.md).

Those metadata objects normalize to the same hash protocol:

```ruby
RailsFieldsKit::TableFilterInput.date_field(:starts_on, min: Date.current).to_table_filter
# => {
#      type: "rails_fields_kit",
#      field_type: "date_field",
#      method: "starts_on",
#      options: { min: Date.current }
#    }
```

Use this native field path when the table integration wants Rails Fields Kit naming, redisplay, and renderer mapping, but the host app does not need remote search or tag-style behavior for that column.

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

Use `known_type?` when table integrations want to validate that a configured editor type is one of the built-in Rails Fields Kit factory types before rendering:

```ruby
RailsFieldsKit::TableCellInput.known_type?(field_type)
RailsFieldsKit::TableCellInput.known_types
```

`known_types` is intentionally limited to the built-in factory family. It does not include custom mappings added with `TableRenderer.register_field_helper`; use `TableRenderer.registered_field_type?` when validation needs to include those custom renderable types.

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

## Token-search and native cell editor examples

`TableCellInput` includes the same common field factory family plus `token_search`, so table-oriented UIs can describe richer editors without leaving metadata mode.

```ruby
columns = [
  {
    key: :status_tokens,
    cell_editor: RailsFieldsKit::TableCellInput.token_search(
      :status_tokens,
      url: search_status_tokens_path(format: :json),
      placeholder: "status:open assignee:matsuo"
    )
  },
  {
    key: :contact_email,
    cell_editor: RailsFieldsKit::TableCellInput.email_field(:contact_email)
  }
]
```

`TableCellInput.token_search` is still only editor metadata. The host app or table integration remains responsible for parsing submitted token text, deciding whether that editor belongs in a modal or inline cell flow, and persisting the resulting value.

## Collecting metadata from columns

`RailsFieldsKit::TableMetadata` can collect Rails Fields Kit filter/editor metadata from hash-like or object-like column definitions. It also accepts a table-like object that responds to `columns`.

Use this collector when the source is still a table or column definition. Use `RailsFieldsKit::TableRenderer` directly only after you already have filter/editor metadata objects or metadata hashes.

| Source shape | Example | Collector behavior |
| --- | --- | --- |
| `nil` source | `TableMetadata.filters(nil)` | Returns an empty list. |
| Array of column hashes or objects | `[{ filter: ... }, column]` | Reads each column in order. |
| Enumerable column source | `columns.each` | Converts the enumerable to an ordered list. |
| Single hash column | `{ filter_input: ... }` | Treats the hash as one column definition, not as key-value pairs. |
| Table-like object | `OpenStruct.new(columns: columns)` | Reads `columns` first, then applies the same source rules to the returned value. |
| Hash-like source with metadata keys | `source.to_hash #=> { filter: ... }` | Treats the hash-like object as one column when it has filter/editor metadata keys. |
| Object column with metadata reader | `Struct.new(:filter).new(...)` | Reads declared metadata readers such as `filter` or `cell_editor`. |
| Already-normalized metadata list | `[TableFilterInput.search_field(:q)]` | Pass this to `TableRenderer.filter_calls` / `cell_editor_calls`, not to the column collector. |

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

A column with no recognized metadata key is ignored. A recognized metadata value of `nil` or explicit `false` is skipped, so host integrations can hide a filter/editor without removing the rest of the column definition. Hash-like metadata values are normalized through `to_hash`, and `to_hash` must return a Hash-like object.

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

These batch render helpers return ordered arrays of rendered pieces. `rfk_table_filters` and `rfk_table_cell_editors` are the helper-level direct rendering path that safe-joins those pieces into ordinary FormBuilder output.

```erb
<% filter_controls = RailsFieldsKit::TableMetadata.render_filters(f, columns) %>
<%= safe_join(filter_controls) %>

<% editor_controls = RailsFieldsKit::TableRenderer.render_cell_editors(f, editors) %>
<%= safe_join(editor_controls) %>
```

Use the batch render helpers when the integration wants rendering convenience but still needs to inspect, reorder, wrap, or selectively join the rendered controls before they become view output.

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

Use `rfk_table_filters` / `rfk_table_cell_editors` when you already want direct FormBuilder output from a Rails view. Use `TableMetadata.filter_calls` / `cell_editor_calls` or `TableRenderer.filter_call` / `cell_editor_call` when a table integration needs to inspect, reorder, wrap, or selectively render helper, method, and options in its own pipeline. Use `TableMetadata.render_filters` / `render_cell_editors` or `TableRenderer.render_filters` / `render_cell_editors` when the integration wants rendering convenience but still expects an ordered array that it will join or otherwise consume itself.

Use `helper_for` and `registered_field_type?` when an integration needs to inspect renderer mappings, including custom registrations.

```ruby
RailsFieldsKit::TableRenderer.helper_for(:combobox)
RailsFieldsKit::TableRenderer.registered_field_type?(:combobox)
```

For validation, keep the two surfaces separate: `TableFilterInput.known_type?` and `TableCellInput.known_type?` answer whether a field type belongs to the built-in metadata factory family; `TableRenderer.registered_field_type?` answers whether the current renderer registry can render it, including custom registrations.

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

Custom field types can still travel through the metadata objects. They are not added to `TableFilterInput.known_types` or `TableCellInput.known_types`; their renderability is checked by the renderer registry.

```ruby
filter = RailsFieldsKit::TableFilterInput.from_type(
  :custom_field,
  :code,
  prefix: "#"
)

RailsFieldsKit::TableRenderer.registered_field_type?(:custom_field)
# => true

RailsFieldsKit::TableRenderer.filter_call(filter)
# => {
#      helper: :custom_table_field,
#      method: :code,
#      options: { prefix: "#" }
#    }
```

For an end-to-end integration, register the helper before you build call specs, then reset it after the scoped customization if you need to go back to the defaults:

```ruby
RailsFieldsKit::TableRenderer.register_field_helper(
  :currency_range,
  :rfk_money_field
)

columns = [
  {
    key: :minimum_total,
    filter_input: {
      field_type: :currency_range,
      method: :minimum_total,
      options: { step: 0.01, placeholder: "Minimum total" }
    }
  }
]

call = RailsFieldsKit::TableMetadata.filter_calls(columns).first
form_builder.public_send(call.fetch(:helper), call.fetch(:method), **call.fetch(:options))

RailsFieldsKit::TableRenderer.reset_field_helpers!
RailsFieldsKit::TableRenderer.registered_field_type?(:currency_range)
# => false
```

Use `RailsFieldsKit::TableRenderer.field_helpers`, `RailsFieldsKit::TableRenderer.helper_for`, and `RailsFieldsKit::TableRenderer.registered_field_type?` to inspect the current mapping. Use `RailsFieldsKit::TableRenderer.reset_field_helpers!` to restore the defaults.

## Intended integration with Rails Table Preferences

When Rails Fields Kit metadata is used alongside Rails Table Preferences, keep the public boundary explicit:

- Rails Table Preferences owns table column state such as visibility, order, width, presets, saved filter state, sort state, and export metadata.
- Rails Fields Kit owns field metadata and rendering assistance for the controls attached to those columns, including field type, helper mapping, remote suggestion URLs, selected preload settings, and adapter metadata such as `adapter: :ransack`.
- The host application owns query execution, params construction, authorization, scoping, pagination, persistence, and user-visible success or error copy.

That boundary keeps Rails Fields Kit as an optional metadata bridge. It should not require a hard dependency on Rails Table Preferences, and it should not turn `rfk_table_filters` into a helper-level Ransack DSL before the design proposal in `ROADMAP.md` and issue #33 is explicitly accepted.

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
  editor: RailsFieldsKit::TableCellInput.enum_select(:status)
}
```

```ruby
{
  key: :minimum_total,
  filter_input: RailsFieldsKit::TableFilterInput.money_field(
    :minimum_total,
    step: 0.01
  )
}
```

```ruby
{
  key: :starts_on,
  filter_input: RailsFieldsKit::TableFilterInput.date_field(
    :starts_on,
    min: Date.current
  )
}
```

```ruby
{
  key: :accent_color,
  cell_editor: RailsFieldsKit::TableCellInput.color_field(:accent_color)
}
```

```ruby
{
  key: :status_tokens,
  cell_editor: RailsFieldsKit::TableCellInput.token_search(
    :status_tokens,
    url: search_status_tokens_path(format: :json)
  )
}
```

A table preferences implementation can normalize these values by calling `RailsFieldsKit::TableMetadata.filters` or `RailsFieldsKit::TableMetadata.cell_editors` on either its column list or the table object itself. It can then call `RailsFieldsKit::TableRenderer.filter_call`, `RailsFieldsKit::TableRenderer.cell_editor_call`, or the `RailsFieldsKit::TableMetadata` render shortcuts to map metadata to Rails Fields Kit FormBuilder helpers.
