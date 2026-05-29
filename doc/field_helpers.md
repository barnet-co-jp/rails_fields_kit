# Rails Fields Kit Field Helpers

This document lists the FormBuilder helpers provided by Rails Fields Kit.

## Quick chooser

| If you need... | Choose | Why |
| --- | --- | --- |
| A normal single select backed by a collection you already rendered in Rails | `rfk_select` | Keeps the same field name and ordinary Rails select flow. |
| Remote search, selected preload, or create-on-the-fly while still submitting a selected ID or value | `rfk_combobox` | Uses remote JSON endpoints for options instead of relying on the initial collection. |
| Suggestion UI for a text value that stays free text when submitted | `rfk_autocomplete` | Suggestions help typing, but the submitted value is still plain text. |
| Structured search text such as `status:open keyword` with suggestion metadata | `rfk_token_search` | Rails Fields Kit owns the token input UI, while the host app still parses and executes the query. |
| Ordinary multiple selection from a known collection | `rfk_multi_select` | Keeps a select-style multiple value flow without implying tag creation. |
| Tag-style multiple selection or create-on-the-fly tags | `rfk_tags` | Optimized for tag entry and optional remote tag creation. |
| Grouped `<optgroup>` choices | `rfk_grouped_select` | Keeps grouped collection structure explicit. |
| A Rails enum attribute | `rfk_enum_select` | Uses the enum-backed attribute directly. |

If the choice is mostly about who owns search semantics, use this rule of thumb: `rfk_select`, `rfk_multi_select`, `rfk_grouped_select`, and `rfk_enum_select` stay collection-first; `rfk_combobox` and `rfk_autocomplete` call remote endpoints for suggestions; `rfk_token_search` goes one step further by letting the host app parse submitted token text or build `params[:q]` later.

For a server-rendered `collection_select` migration that keeps the normal Rails param flow, see [`select_migration.md`](select_migration.md).

## Tom Select-backed helpers

For a product-neutral visual comparison of representative Tom Select-backed states, see [`tom_select_visual_reference.html`](tom_select_visual_reference.html).

### Shared request-failure feedback options

All Tom Select-backed helpers support the same opt-in request-failure feedback options:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- `rfk_token_search`

Use `error_surface: true` when the host app wants Rails Fields Kit to render a stable nearby placeholder for request-failure handlers. Use `error_surface_html:` when that placeholder needs custom classes or wrapper attributes.

When enabled, Rails Fields Kit appends a hidden polite status placeholder near the field, wires that placeholder into `aria-describedby`, and exposes the element as `event.detail.surface` on request-failure events documented in [`events.md`](events.md). The host app still decides when to reveal that placeholder, what message to render, and whether to add retry UI.

The same shared option contract applies even when a given helper only uses part of the remote workflow set. For example, a field without create-on-the-fly support will never dispatch `create-error`, but it can still use `error_surface:` for `load-error` or `selected-load-error` when those hooks apply.

### Shared plugin options

All Tom Select-backed helpers can pass plugin names to Tom Select with `plugins:`. When a helper omits `plugins:`, Rails Fields Kit uses `config.default_plugins` from [`configuration.md`](configuration.md) as the app-wide fallback.

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  plugins: ["dropdown_input"] %>
```

Field-level `plugins:` replaces the initializer default for that one field. Use it for deliberate per-field differences rather than expecting it to merge with `config.default_plugins` automatically.

Rails Fields Kit only passes the plugin names through to the rendered Tom Select configuration. The host app remains responsible for installing Tom Select, importing any plugin-specific assets, and understanding plugin-specific behavior.

Helper defaults to keep in mind:

- `rfk_tags` and `rfk_token_search` use `remove_button` by default when `plugins:` is omitted.
- Passing `plugins:` to those helpers is an explicit override, so include `"remove_button"` yourself when you still want that behavior.
- `allow_clear: true` adds `clear_button` to the effective plugin list for that field.

### `rfk_select`

Use this for a normal single select that should get Tom Select behavior.

```erb
<%= f.rfk_select :status,
  collection: Order.statuses.keys,
  allow_clear: true %>
```

Use `allow_clear: true` when the field should stay a collection-backed single select but still let the user return to the blank or placeholder state. This is still the same `rfk_select` lane: the rendered collection remains the source of available options, and ordinary Rails select options such as `include_blank:` or `prompt:` still own the empty-state wording.

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

- ordinary selected state and clearable selected state both stay in the same collection-backed `rfk_select` lane
- move to `rfk_combobox` when the field needs `url:`, `selected_url:`, or `create_url:` because option lookup or label restore comes from remote endpoints instead of the rendered collection

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

#### Representative `error_surface` example

The shared request-failure feedback options above apply here too. This combobox example is representative, not combobox-only:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  create_url: customers_path,
  error_surface: true,
  error_surface_html: { class: "field-error" },
  html: {
    data: {
      action: "rails-fields-kit--tom-select:load-error->customers#error rails-fields-kit--tom-select:create-error->customers#error"
    }
  } %>
```

When enabled, Rails Fields Kit appends a hidden polite status placeholder near the field, wires that placeholder into `aria-describedby`, and exposes the element as `event.detail.surface` on request-failure events. `error_surface_html:` customizes that generated placeholder element only; the host app still decides when to reveal it and what message or retry UI to render.

### `rfk_autocomplete`

Use this for a text input with suggestions where the submitted value stays free text.

```erb
<%= f.rfk_autocomplete :customer_name,
  url: customer_name_suggestions_path(format: :json),
  query_param: "q",
  min_length: 2,
  placeholder: "Type a customer name" %>
```

Use this representative lane when the host app still wants the user's text itself, for example a keyword field or a draft customer-name field. Choosing a suggestion helps fill the text the user is typing, but it does not switch the field into a selected-ID contract.

- `rfk_autocomplete` keeps the submitted value as free text.
- `rfk_combobox` is the helper to use when the field should submit a selected ID or value and may need `selected_url:` or `create_url:` as part of that workflow.
- `rfk_token_search` is the helper to use when the text itself is structured query syntax that the host app will parse later.

Like other remote helpers, `rfk_autocomplete` can still opt into `error_surface: true` for request-failure feedback. Its representative setup does not depend on selected preload or create-on-the-fly support.

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

By default, `rfk_token_search` renders a text input with free-text creation enabled, uses a space delimiter, does not persist created options in the Tom Select option list, and enables Tom Select's `remove_button` plugin. Pass explicit `create:`, `persist:`, `delimiter:`, or `plugins:` options to override those defaults. When you override `plugins:`, include `"remove_button"` yourself if the token UI should still show remove controls.

Use [`controller_helpers.md`](controller_helpers.md) and [`token_suggestions.md`](token_suggestions.md) when the host app wants a maintained controller-side suggestion endpoint for operators, fields, predicates, values, or saved-search shortcuts.

For a current Ransack-oriented lane, keep the same `rfk_token_search` field and switch the suggestion metadata to `RailsFieldsKit::RansackSuggestions.build`. The submitted token text still belongs to the host app's parser and `params[:q]` construction; see [`ransack_suggestions.md`](ransack_suggestions.md) for that boundary.

### `rfk_tags`

Use this for tag-style multiple selection when the same field should keep existing tags visible, accept the next tag in place, and optionally create a missing tag without switching to a separate helper.

```erb
<%= f.rfk_tags :tag_ids,
  url: tags_path(format: :json),
  create_url: tags_path,
  selected_url: selected_tags_path(format: :json),
  selected: @post.tag_ids,
  value_field: "id",
  label_field: "name",
  placeholder: "Add a tag" %>
```

Use this representative lane when the host app wants one field to stay in tag-entry mode from start to finish:

- existing selected tags stay visible while the next input is typed in the same field
- `create_url:` is the maintained path when the host app allows create-on-the-fly tag creation for a missing tag
- `selected_url:` keeps edit-form redisplay aligned when the form starts from saved IDs instead of already-rendered tag labels

By default, `rfk_tags` enables Tom Select's `remove_button` plugin so selected tags can be removed inline. Pass explicit `plugins:` only when the host app intentionally wants to replace that helper default; include `"remove_button"` in the explicit list when the tag UI should keep the same removal affordance.

Compared with `rfk_multi_select`, the interaction stays centered on tag entry and optional creation rather than on settling a known collection first. See [`tom_select_visual_reference.html`](tom_select_visual_reference.html) for the representative `Tags` state when you want the same lane as a quick static surface.

### `rfk_multi_select`

Use this for a normal multiple select. Use `rfk_tags` when the UI should feel like tag entry.

```erb
<%= f.rfk_multi_select :category_ids,
  collection: Category.order(:name),
  collection_value_method: :id,
  collection_label_method: :name %>
```

Use this representative lane when the host app already knows the allowed collection and the submitted value should stay an ordinary array of selected IDs or values.

- `rfk_multi_select` keeps the same collection-backed multiple-value flow that an ordinary Rails multiple select uses.
- `rfk_tags` is the helper to use when the same UI should feel like tag entry or allow create-on-the-fly tag creation.
- `rfk_combobox` is the helper to use when choices come from remote search or when a single selected value needs `selected_url:` or `create_url:` support.

Keep the representative setup collection-first: pass the known collection, keep the normal Rails array attribute, and treat remote tag creation or structured token parsing as separate helper lanes.

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

For a product-neutral visual comparison of representative native helper states, see [`native_field_visual_reference.html`](native_field_visual_reference.html).

If you want one representative lane before the per-helper snippets below, start with a wrapped text field and treat the rest of the native helper family as variations on that same shared contract.

### Representative wrapper and accessibility lane

```erb
<%= f.rfk_text_field :customer_code,
  wrapper: true,
  label: "Customer code",
  hint: "Shown in the admin sidebar",
  prefix: "#",
  suffix: "required",
  required: true,
  wrapper_html: { class: "customer-field", data: { controller: "field-shell" } },
  label_html: { class: "customer-label" },
  control_html: { class: "customer-control" },
  prefix_html: { data: { role: "code-prefix" } },
  suffix_html: { class: "customer-suffix" },
  html: { autocomplete: "off", data: { role: "customer-code-input" } } %>
```

This representative lane keeps the native helper family in its ordinary HTML-input path while still showing the shared wrapper contract in one place:

- `wrapper: true` renders the label, hint, and affixes around the native field.
- `html:` passes attributes to the input itself; `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` pass attributes to the generated wrapper pieces.
- edit-form redisplay and validation rerender keep using the same model-backed value instead of switching to a remote-search or Tom Select lane.
- automatic accessibility wiring keeps the generated hint and error ids connected through `aria-describedby` and also manages `aria-invalid` / `aria-required` unless you opt out.

When the host app needs to own that accessibility wiring itself, keep the same wrapper lane and opt out explicitly:

```erb
<%= f.rfk_text_field :customer_code,
  wrapper: true,
  label: "Customer code",
  hint: "Host app manages accessibility wiring",
  accessibility: false %>
```

`accessibility: false` only removes the shared automatic `aria-describedby`, `aria-invalid`, and `aria-required` output. The wrapped native field, label, hint, prefix, suffix, and validation redisplay behavior still stay in the same helper family.

### Field-level wrapper customization

Use the initializer defaults in [`configuration.md`](configuration.md) when the whole host app should share the same wrapper, label, hint, error, control, prefix, or suffix classes. Use the per-field `*_html` options when one field needs additional classes, `data`, or aria attributes for a Bootstrap, Tailwind, or design-system hook.

Rails Fields Kit appends the configured default classes to any field-level class you pass. For example, `wrapper_html: { class: "customer-field" }` still receives the configured `wrapper_class`, and an invalid field also receives `field_error_class`.

The wrapper customization options map to generated pieces this way:

| Option | Generated piece |
| --- | --- |
| `wrapper_html:` | outer wrapper rendered by `wrapper: true` |
| `label_html:` | generated label |
| `hint_html:` | generated hint |
| `error_html:` | generated validation error message |
| `control_html:` | prefix/suffix control wrapper |
| `prefix_html:` | prefix affix |
| `suffix_html:` | suffix affix |
| `html:` | input or select element itself |

These options only customize rendered HTML attributes. They do not change validation behavior, remote loading, query parsing, or host-app authorization and scoping responsibilities.

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
  required: true,
  wrapper_html: { class: "customer-field" },
  label_html: { data: { role: "field-label" } },
  html: { data: { role: "customer-name-input" } } %>
```

Common options:

- `wrapper:` wraps the input with label, hint, and errors.
- `label:` controls the label text. Use `false` to suppress label rendering.
- `hint:` renders helper text.
- `prefix:` and `suffix:` render affixes around the input.
- `accessibility: false` disables automatic `aria-describedby`, `aria-invalid`, and `aria-required` output.
- `html:` passes HTML attributes to the input/select.
- `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` customize generated wrapper pieces without changing the helper family or host-app responsibility boundary.

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
- `plugins:` passes explicit Tom Select plugin names for one field and overrides `config.default_plugins` for that field.
- `loading_text:`, `no_results_text:`, and `create_text:` override the bundled or initializer-provided Tom Select copy for one field only.
- `error_surface:` adds a stable nearby placeholder for request-failure handlers.
- `error_surface_html:` customizes that generated placeholder element.

When neither the field nor the initializer sets those values, Rails Fields Kit falls back to bundled locale-aware copy at render time. The bundled baseline currently includes English and Japanese, and falls back to English when a locale-specific key is not present.

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