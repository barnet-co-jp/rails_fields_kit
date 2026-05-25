# Rails Fields Kit Field Helpers

This document lists the FormBuilder helpers provided by Rails Fields Kit.

## Tom Select-backed helpers

### `rfk_select`

Use this for a normal single select that should get Tom Select behavior.

```erb
<%= f.rfk_select :status,
  collection: Order.statuses.keys,
  allow_clear: true %>
```

When replacing an existing `collection_select`, keep the same model attribute and ordinary Rails select options so the submitted param shape stays the same:

```erb
<%= f.collection_select :company_id,
  @companies,
  :id,
  :name,
  { include_blank: "Select a company" } %>
```

```erb
<%= f.rfk_select :company_id,
  collection: @companies,
  collection_value_method: :id,
  collection_label_method: :name,
  include_blank: "Select a company" %>
```

For collection-backed `rfk_select`, Rails still uses the same field name, so existing strong params and normal save flows do not need extra changes just because the form helper changed. Edit-form redisplay and validation rerender also keep using the model value already assigned to `company_id`, so the selected option is preserved the same way as an ordinary Rails select.

Use `selected:` only when the field needs to preload a value that is not already present in the rendered collection, such as a remote combobox or a collection loaded later.

### `rfk_combobox`

Use this for searchable remote selects and editable comboboxes.

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  create_url: customers_path,
  value_field: "id",
  label_field: "name",
  option_description_field: "email",
  option_badge_field: "status" %>
```

### `rfk_autocomplete`

Use this for a text input with suggestions where the submitted value is free text.

```erb
<%= f.rfk_autocomplete :keyword,
  url: suggestions_path(format: :json),
  min_length: 2 %>
```

### `rfk_token_search`

Use this for token-oriented search text such as `status:open assignee:matsuo keyword`. It keeps Rails Fields Kit responsible for the input UI and suggestions while the host app remains responsible for parsing and applying the submitted query.

```erb
<%= f.rfk_token_search :query,
  url: search_token_suggestions_path(format: :json),
  placeholder: "status:open keyword",
  max_items: 20,
  load_throttle: 250,
  query_params: { context: "orders" } %>
```

By default, `rfk_token_search` renders a text input with free-text creation enabled, uses a space delimiter, does not persist created options in the Tom Select option list, and enables Tom Select's `remove_button` plugin. Pass explicit `create:`, `persist:`, `delimiter:`, or `plugins:` options to override those defaults.

### `rfk_tags`

Use this for tag-style multiple selection, usually with create enabled.

```erb
<%= f.rfk_tags :tag_ids,
  url: tags_path(format: :json),
  create_url: tags_path,
  selected_url: selected_tags_path(format: :json),
  value_field: "id",
  label_field: "name" %>
```

### `rfk_multi_select`

Use this for a normal multiple select. Use `rfk_tags` when the UI should feel like tag entry.

```erb
<%= f.rfk_multi_select :category_ids,
  collection: Category.order(:name),
  collection_value_method: :id,
  collection_label_method: :name %>
```

### `rfk_grouped_select`

Use this when options should be grouped with `<optgroup>`.

```erb
<%= f.rfk_grouped_select :customer_id,
  grouped_collection: {
    "Active" => [["Acme Corp", 1]],
    "Archived" => [["Old Corp", 2]]
  } %>
```

### `rfk_enum_select`

Use this for Rails enum attributes.

```erb
<%= f.rfk_enum_select :status %>
```

## Table metadata helpers

Use these helpers when table column definitions already carry Rails Fields Kit metadata through `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, compatible hashes, hash-like column objects, or table-like objects that respond to `columns`.

### `rfk_table_filters`

```erb
<%= f.rfk_table_filters(@table_preferences) %>
```

This collects filter metadata from a column list or table-like object and renders each filter through the matching Rails Fields Kit field helper. `nil` metadata renders an empty safe string, so callers can pass optional table objects without pre-normalizing them.

### `rfk_table_cell_editors`

```erb
<%= f.rfk_table_cell_editors(@table_preferences) %>
```

This collects editable-cell metadata from a column list or table-like object and renders each editor through the matching Rails Fields Kit field helper. Hash-like column objects can expose metadata through `to_hash`; object columns with public metadata readers such as `editor` or `cell_editor` keep those readers as the preferred protocol.

## Native input helpers

These helpers use native HTML inputs while sharing the same wrapper, hint, error, and accessibility behavior.

### `rfk_text_field`

```erb
<%= f.rfk_text_field :name,
  wrapper: true,
  hint: "Displayed to users" %>
```

### `rfk_text_area`

```erb
<%= f.rfk_text_area :description,
  wrapper: true %>
```

### `rfk_number_field`

```erb
<%= f.rfk_number_field :quantity,
  wrapper: true,
  min: 0 %>
```

### `rfk_money_field`

```erb
<%= f.rfk_money_field :amount,
  currency: "JPY",
  wrapper: true %>
```

### `rfk_percent_field`

```erb
<%= f.rfk_percent_field :tax_rate,
  wrapper: true %>
```

### `rfk_email_field`

```erb
<%= f.rfk_email_field :email,
  autocomplete: "email" %>
```

### `rfk_url_field`

```erb
<%= f.rfk_url_field :website_url %>
```

### `rfk_phone_field`

```erb
<%= f.rfk_phone_field :phone,
  autocomplete: "tel" %>
```

### `rfk_search_field`

```erb
<%= f.rfk_search_field :keyword,
  placeholder: "Search" %>
```

## Shared wrapper options

Most helpers support these options:

```erb
<%= f.rfk_text_field :name,
  wrapper: true,
  label: "Customer name",
  hint: "Use the official name",
  prefix: "#",
  suffix: "required",
  required: true %>
```

Common options:

- `wrapper:` wraps the input with label, hint, and errors.
- `label:` controls the label text. Use `false` to suppress label rendering.
- `hint:` renders helper text.
- `prefix:` and `suffix:` render affixes around the input.
- `accessibility: false` disables automatic `aria-describedby`, `aria-invalid`, and `aria-required` output.
- `html:` passes HTML attributes to the input/select.
- `control_html:`, `prefix_html:`, and `suffix_html:` customize wrapper pieces.

## Collection options

Select-like helpers accept array, hash, and object collections.

```erb
<%= f.rfk_select :customer_id,
  collection: @customers,
  collection_value_method: :id,
  collection_label_method: :name %>
```

Option-level customization:

```erb
<%= f.rfk_select :status,
  collection: { "Draft" => "draft", "Published" => "published" },
  disabled: ["published"],
  option_html: {
    "draft" => { data: { color: "gray" } }
  } %>
```

Use boolean `disabled: true` to disable the whole select. Use array/value `disabled:` to disable specific options.

`include_blank:` and `prompt:` keep using the normal Rails `select` option behavior, so a `collection_select` to `rfk_select` migration can preserve blank-option wording without changing controller or model code.

## Remote option options

Tom Select-backed helpers that call remote endpoints accept these request-shaping options:

- `query_params:` adds fixed query parameters to the remote search URL.
- `selected_query_params:` adds fixed query parameters to the selected-option preload URL.
- `create_params:` adds fixed JSON fields to create-on-the-fly POST requests.
- `max_items:` forwards Tom Select's maximum selected item count.
- `load_throttle:` forwards Tom Select's remote load throttle in milliseconds.
- `delimiter:` forwards Tom Select's delimiter option, useful for text-backed token inputs.
- `loading_text:`, `no_results_text:`, and `create_text:` override the bundled or initializer-provided Tom Select copy for one field only.

Use `config.default_loading_text`, `config.default_no_results_text`, and `config.default_create_text` in the initializer when the whole host app should share the same baseline wording. Use the helper options above when a single field needs different copy.

Example:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  create_url: customers_path,
  query_params: { account_id: current_account.id },
  selected_query_params: { account_id: current_account.id },
  create_params: { account_id: current_account.id } %>
```

The main query value still uses `query_param:`. Selected values still use `selected_param:` or `selected_multiple_param:`. Create input text still uses `create_param:`.

## Multiple values

`rfk_tags` and `rfk_multi_select` submit Rails-style array params.

```erb
<%= f.rfk_tags :tag_ids,
  collection: Tag.order(:name),
  collection_value_method: :id,
  collection_label_method: :name %>
```

Rails emits a hidden blank input for multiple selects by default. Disable it when needed:

```erb
<%= f.rfk_tags :tag_ids,
  collection: Tag.order(:name),
  include_hidden: false %>
```