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
