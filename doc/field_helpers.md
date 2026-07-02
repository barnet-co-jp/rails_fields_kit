# Rails Fields Kit Field Helpers

This document lists the FormBuilder helpers provided by Rails Fields Kit.

## Quick chooser

| If you need... | Choose | Why |
| --- | --- | --- |
| A normal single select backed by a collection you already rendered in Rails | `rfk_select` | Keeps the same field name and ordinary Rails select flow. |
| Remote search, selected preload, or create-on-the-fly while still submitting a selected ID or value | `rfk_combobox` | Uses remote JSON endpoints for options instead of relying on the initial collection. |
| Suggestion UI for a text value that stays free text when submitted | `rfk_autocomplete` | Suggestions help typing, but the submitted value is still plain text. |
| Structured search text such as `status:open keyword` with suggestion metadata | `rfk_token_search` | Rails Fields Kit owns the token input UI, while the host app still parses and executes the query. |
| Request-failure feedback for any Tom Select-backed helper | Keep the chosen helper and opt into `error_surface:`. | Adds a stable hidden placeholder for host-owned visible feedback while leaving copy, retry UI, reveal timing, and production CSS with the host app. See [Shared request-failure feedback options](#shared-request-failure-feedback-options). |
| Ordinary multiple selection from a known collection | `rfk_multi_select` | Keeps a select-style multiple value flow without implying tag creation. |
| Tag-style multiple selection or create-on-the-fly tags | `rfk_tags` | Optimized for tag entry and optional remote tag creation. |
| Grouped `<optgroup>` choices | `rfk_grouped_select` | Keeps grouped collection structure explicit. |
| A Rails enum attribute | `rfk_enum_select` | Uses the enum-backed attribute directly. |
| A native browser input with shared wrapper, hint, error, affix, and accessibility behavior for text, textarea, or search | Start with `rfk_text_field`, `rfk_text_area`, or `rfk_search_field`. | Stays in the ordinary HTML input flow while reusing Rails Fields Kit wrapper conventions. Use [`doc/public_api.md`](public_api.md) for the current helper inventory and [`native_contact_fields.md`](native_contact_fields.md) for contact/search ownership boundaries. |
| A native password control with focused credential-adjacent ownership boundaries | Use `rfk_password_field`. | Keeps password visibility toggles, strength meters, credential policy, authentication workflow, and credential storage outside Rails Fields Kit. Use [`password_field.md`](password_field.md). |
| A native boolean or single-choice control | Use `rfk_check_box` or `rfk_radio_button`. | Keeps Rails checkbox submission and Rails radio value / checked-state behavior in the focused native helper lane instead of implying collection groups. Use [`check_box.md`](check_box.md) or [`radio_button.md`](radio_button.md). |
| A native file upload or range control | Use `rfk_file_field` or `rfk_range_field`. | Keeps upload handling, storage policy, range live preview behavior, and production styling with the host app. Use [`file_field.md`](file_field.md) or [`range_field.md`](range_field.md). |
| Native numeric, money, percent, email, URL, or phone inputs | Use the matching native helper such as `rfk_number_field`, `rfk_money_field`, `rfk_percent_field`, `rfk_email_field`, `rfk_url_field`, or `rfk_phone_field`. | Keeps formatting, rounding, normalization, validation wording, and phone policy with the host app while Rails Fields Kit owns the shared wrapper lane. Use [`native_numeric_fields.md`](native_numeric_fields.md) and [`native_contact_fields.md`](native_contact_fields.md). |
| Native date, time, datetime-local, or color controls | Use `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, or `rfk_color_field`. | Keeps browser-native picker behavior, timezone conversion, locale formatting, masking, and production CSS outside Rails Fields Kit. Use [`native_date_time_color_fields.md`](native_date_time_color_fields.md). |
| Browser-native datalist suggestions, title-to-slug workflows, or masked inputs | No current Rails Fields Kit helper; use the existing native wrapper lane plus [`datalist_boundary.md`](datalist_boundary.md), [`slug_helper_boundary.md`](slug_helper_boundary.md), or [`masked_input_boundary.md`](masked_input_boundary.md). | Keeps `rfk_datalist_field`, `rfk_slug_field`, and `rfk_masked_field` in proposal-only docs while host apps own candidate markup, slug generation, masking libraries, normalization, validation, and persistence policy. |
| Inline textarea mentions such as `@user` or `#tag` | No current Rails Fields Kit helper; see [`mention_field_boundary.md`](mention_field_boundary.md). | Keeps textarea mention overlay, parsing, hidden metadata, authorization, persistence, and suggestion endpoint shape in the proposal / host-app responsibility lane instead of implying a current `rfk_mention_field` API. |

The `A native password, checkbox, radio, file, or range control with focused ownership boundaries` helper family is intentionally split across the password, boolean/radio, and file/range rows above so `rfk_password_field` is not read as the helper for every native control.

If the choice is mostly about who owns search semantics, use this rule of thumb: `rfk_select`, `rfk_multi_select`, `rfk_grouped_select`, and `rfk_enum_select` stay collection-first; `rfk_combobox` and `rfk_autocomplete` call remote endpoints for suggestions; `rfk_token_search` goes one step further by letting the host app parse submitted token text or build `params[:q]` later. When a native browser search input is enough, `rfk_search_field` stays in the native wrapper lane and does not call remote endpoints or take over token parsing.

Datalist, slug, and masked-input helpers are proposal-only. Use [`datalist_boundary.md`](datalist_boundary.md), [`slug_helper_boundary.md`](slug_helper_boundary.md), and [`masked_input_boundary.md`](masked_input_boundary.md) when comparing current native wrapper helpers with those future directions; keep `rfk_datalist_field`, `rfk_slug_field`, `rfk_masked_field`, datalist candidate ownership, slug generation, masking libraries, normalization, validation, and persistence policy out of the current public helper inventory until they land.

Inline textarea mentions are proposal-only. Use [`mention_field_boundary.md`](mention_field_boundary.md) when comparing `rfk_text_area`, `rfk_autocomplete`, `rfk_token_search`, and `rfk_tags` with a future mention helper; keep `rfk_mention_field`, textarea overlay behavior, hidden metadata, and mention-specific endpoint contracts out of the current public helper inventory until they land.

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

Use [`events.md`](events.md) for the event payloads, request-state metadata, and copyable host-controller recipes. Use [`tom_select_request_failure_visual_reference.html`](tom_select_request_failure_visual_reference.html) for static request-failure surface review, and [`tom_select_host_feedback_lifecycle_visual_reference.html`](tom_select_host_feedback_lifecycle_visual_reference.html) when the review is about host-owned visible feedback and follow-up clearing cues. Those visual references are review routes only; they do not add built-in retry UI, default copy, request lifecycle timing, or production CSS to Rails Fields Kit.

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
- `config.default_allow_clear = true` applies the same semantic clear-button default when a helper omits `allow_clear:`; pass `allow_clear: false` to suppress only Rails Fields Kit's semantic auto-add for one field.

Use [`default_allow_clear.md`](default_allow_clear.md) for app-wide clear-button default examples and the boundary between semantic `allow_clear:` behavior and raw `plugins:` / `default_plugins` pass-through.

### Shared Tom Select class names option

Use `tom_select_class_names:` when one Tom Select-backed helper needs to pass Tom Select's internal `classNames` option for generated parts such as the control, dropdown, option, item, or loading states:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  tom_select_class_names: {
    control: "ts-control app-select-control",
    dropdown: "ts-dropdown app-select-dropdown"
  } %>
```

This option is separate from Rails Fields Kit wrapper customization. Use `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` for HTML Rails Fields Kit renders around the field; use `tom_select_class_names:` only for Tom Select internal generated markup on that one field. Rails Fields Kit does not add an initializer-level default, production CSS, theme preset, dark mode, density policy, or Tom Select internal DOM compatibility guarantee. See [`tom_select_class_names.md`](tom_select_class_names.md) for focused examples and non-goals.

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

Option-level metadata also stays in this rendered collection lane. Use value-array `disabled:` to render specific unavailable choices and `option_html:` to pass per-option attributes such as `data` or classes onto the generated `<option>` tags before Tom Select connects. Treat those attributes as display metadata for already-rendered choices; authorization, dynamic visibility, remote option payload mapping, and rich Tom Select renderer behavior still belong to the host app endpoint or separate helper lane.

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

For remote search, current public behavior is a JSON `GET` request to `url:`. Rails Fields Kit appends `query_params:` to that URL as fixed query string scope first, then sets `query_param:` to the typed query value. The host app owns that endpoint's authorization, scoping, and response records; use `selected_url:` for selected-option preload and `create_url:` for create-on-the-fly JSON `POST` requests instead of mixing those request shapes into the remote search endpoint.

`open_on_focus:` and `preload:` are passed through to Tom Select for the remote field; Rails Fields Kit does not add a separate blank-query policy around that combination. If the host app expects focus to show initial suggestions, confirm that the endpoint deliberately accepts the resulting blank or initial query and returns an appropriately scoped, limited result set. `min_length:` is a client-side load gate before the request is made; it does not decide what the server should return for an allowed blank query. Use [`controller_helpers.md#blank-query-policy`](controller_helpers.md#blank-query-policy) for the endpoint-side `minimum_query_length:` policy when the server should reject blank or too-short direct requests.

Fixed `query_params:` and `selected_query_params:` values are URL query params. Array values are sent as repeated query entries for the same key, while `null` / `undefined` values are skipped instead of being serialized. `create_params:` uses a different lane: those fixed values are merged into the create-on-the-fly JSON request body before the user's `create_param:` value is written.

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

Use this representative lane when the host app already has a server-rendered grouped collection and wants to preserve those group labels while submitting the ordinary selected ID or value. Keep remote search, selected preload, create-on-the-fly, token metadata, and future optgroup metadata work in their own helper lanes. See [`grouped_select.md`](grouped_select.md) for the focused collection-backed boundary and review checklist.

### `rfk_enum_select`

Use this for Rails enum attributes.

```erb
<%= f.rfk_enum_select :status %>
```

By default, the helper reads the enum-like source from the model class method that matches the pluralized attribute name, such as `Order.statuses` for `:status`. It renders those enum keys as the submitted values, so the field stays in the same Rails enum parameter flow as an ordinary select over `Order.statuses.keys`.

Labels come from the model class I18n path Rails exposes through `human_attribute_name`, using keys such as `status.open` and falling back to the humanized enum key when no translation is present. Keep explicit `enum:` source support aligned with #590 before documenting broader non-Rails enum shapes here.

`rfk_enum_select` is still collection-first. Use remote helpers such as `rfk_combobox` for endpoint-backed option lookup, and keep Ransack filters or table metadata adapter behavior in their dedicated docs.

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

Rails Fields Kit provides dedicated `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field` helpers for browser-native date, time, datetime-local, and color controls. Use [`native_date_time_color_fields.md`](native_date_time_color_fields.md) for the focused helper mapping and the host-app-owned picker, timezone, masking, validation, and production CSS boundaries.

Use [`check_box.md`](check_box.md) for the focused `rfk_check_box` boundary. It keeps Rails' ordinary checkbox submission contract, hidden unchecked field, checked / unchecked values, and model-backed checked state in Rails' helper lane while Rails Fields Kit provides wrapper and accessibility wiring around the single checkbox control.

Use [`radio_button.md`](radio_button.md) for the focused `rfk_radio_button` boundary. It keeps Rails' ordinary radio value, checked-state, and same-name group behavior in Rails' helper lane while Rails Fields Kit provides wrapper and accessibility wiring around one radio input. Collection radio groups, fieldset / legend builders, group-level validation UI, and production CSS stay with ordinary Rails helpers or host-app markup.

For a product-neutral visual comparison of representative native helper states, see [`native_field_visual_reference.html`](native_field_visual_reference.html). For password inputs, use [`password_field.md`](password_field.md) as the dedicated boundary note: Rails Fields Kit provides the native wrapper lane, while visibility toggles, strength meters, credential policy, authentication flow, and password-specific validation copy stay with the host app. For file inputs, use [`file_field.md`](file_field.md) as the dedicated boundary note: Rails Fields Kit provides the native wrapper lane, while multipart form setup, Active Storage direct uploads, preview UI, progress UI, storage configuration, scanning, and validation policy stay with the host app. For range sliders, use [`range_field.md`](range_field.md) as the dedicated boundary note: Rails Fields Kit provides the same thin native wrapper lane, while live value previews, custom slider styling, multi-thumb controls, and production CSS stay with the host app. For numeric helpers, use [`native_numeric_fields.md`](native_numeric_fields.md) for the formatting, rounding, currency, and masking boundaries that stay with the host app. For contact and native search helpers, use [`native_contact_fields.md`](native_contact_fields.md) for validation wording, normalization, phone policy, search execution, and remote suggestion boundaries.

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

Native wrapper helpers also pass ordinary Rails field options to the rendered input. Put simple Rails helper options such as `maxlength:`, `minlength:`, `pattern:`, `required:`, `autocomplete:`, `inputmode:`, `disabled:`, or `readonly:` at the top level when you want the same shape as a Rails native helper; use `html:` when you want to group input attributes next to wrapper customization. If the same attribute is present in both places, the `html:` value wins because it is merged into the field options last.

```erb
<%= f.rfk_text_field :customer_code,
  wrapper: true,
  maxlength: 12,
  pattern: "[A-Z0-9-]+",
  html: { autocomplete: "off" } %>
```

Those attributes stay browser-native and host-app behavior. Rails Fields Kit does not add character counters, input masks, browser validation-message policy, or server-side validation rules for native wrapper helpers; it only keeps the wrapper, hint, error, affix, and accessibility wiring around the native input.

When the host app needs to own that accessibility wiring itself, keep the same wrapper lane and opt out explicitly:

```erb
<%= f.rfk_text_field :customer_code,
  wrapper: true,
  label: "Customer code",
  hint: "Host app manages accessibility wiring",
  accessibility: false %>
```

`accessibility: false` only removes the shared automatic `aria-describedby`, `aria-invalid`, and `aria-required` output. The wrapped native field, label, hint, prefix, suffix, and validation redisplay behavior still stay in the same helper family.

#### Generated described-by ids

For the ordinary single-field case, Rails Fields Kit generates hint and validation error ids from the form object name and method, such as `customer_code_hint` / `customer_code_error`, and wires those ids into `aria-describedby`. Passing a custom input `id:` through `html:` changes the input id, but it does not rename the generated hint or error ids.

If the same object name and method are rendered more than once in the same document, the generated hint and error ids are also repeated. Prefer a distinct form object name or indexed nested form name when the repeated fields represent separate records. When the host app intentionally renders the same field more than once and needs fully custom ids, set `accessibility: false` and own the matching `aria-describedby`, `hint_html:`, and `error_html:` ids together.

For Tom Select-backed request failure placeholders, `error_surface_html: { id: "..." }` is the supported way to choose a unique placeholder id; Rails Fields Kit uses that explicit id for the generated surface, field data value, and `aria-describedby` wiring.

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

### `rfk_check_box`

```erb
<%= f.rfk_check_box :active,
  wrapper: true,
  label: "Active?",
  checked_value: "yes",
  unchecked_value: "no" %>
```

`rfk_check_box` stays in the same native wrapper lane as the other Rails-backed inputs, but its submitted value contract is Rails' standard `check_box` contract. Rails Fields Kit owns wrapper, label, hint, error, affix, and accessibility wiring around the single checkbox control; Rails still owns the hidden unchecked field, checked / unchecked values, and model-backed checked state. Use [`check_box.md`](check_box.md) for the focused boundary, and keep collection checkbox / radio groups, validation UI policy, label placement redesign, and production CSS out of this helper lane.

### `rfk_radio_button`

```erb
<%= f.rfk_radio_button :status, "published",
  wrapper: true,
  label: "Published",
  hint: "Visible to readers" %>
```

`rfk_radio_button` stays in the same native wrapper lane as the other Rails-backed inputs, but its submitted value contract is Rails' standard `radio_button` contract. Rails Fields Kit owns wrapper, label, hint, error, affix, and accessibility wiring around one radio input; Rails still owns the `tag_value`, checked state, generated name / id behavior, and same-name group semantics. Use [`radio_button.md`](radio_button.md) for the focused boundary, and keep collection radio group helpers, fieldset / legend builders, group-level validation UI, and production CSS out of this helper lane.

### `rfk_file_field`

```erb
<%= f.rfk_file_field :attachment,
  wrapper: true,
  label: "Attachment",
  hint: "Upload one PDF",
  accept: "application/pdf" %>
```

`rfk_file_field` stays in the same native wrapper lane as the other Rails-backed inputs. Rails Fields Kit owns wrapper, label, hint, error, affix, and accessibility wiring around Rails' `file_field`; the host app still owns multipart form setup, Active Storage direct upload JavaScript, preview UI, upload progress UI, storage configuration, scanning, and file validation policy. Use [`file_field.md`](file_field.md) for the focused boundary.

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
<%= f.rfk_select :status,
  collection: { "Draft" => "draft", "Published" => "published" },
  disabled: ["published"],
  option_html: {
    "draft" => { data: { color: "gray" } }
  } %>
```

Use boolean `disabled: true` to disable the whole select. Use array/value `disabled:` to disable specific options. `option_html:` accepts a hash keyed by rendered option value, or a callable that returns an attribute hash for that value, and Rails Fields Kit passes those attributes to Rails' generated `<option>` element.

`option_html:` is collection metadata, not an authorization or visibility policy. Keep tenant scoping, dynamic option filtering, and remote result shaping in the host app endpoint or collection query before rendering the field.

`include_blank:` and `prompt:` keep using the normal Rails `select` option behavior, so a `collection_select` to `rfk_select` migration can preserve blank-option wording without changing controller or model code.

## Remote option options

Tom Select-backed helpers that call remote endpoints accept these request-shaping options:

- `query_params:` adds fixed query parameters to the remote search `GET` URL before the typed query is applied.
- `selected_query_params:` adds fixed query parameters to the selected-option preload URL.
- `create_params:` adds fixed JSON fields to create-on-the-fly POST requests.
- `preload:` forwards Tom Select's preload option. For remote search fields, any blank or initial load it permits is still governed by the host app endpoint.
- `open_on_focus:` forwards Tom Select's open-on-focus option. It can reveal already loaded options or work with `preload:` depending on the Tom Select flow, but it does not create a Rails Fields Kit server-side blank-query policy.
- `min_length:` gates client-side remote loading before a request is sent. It is separate from endpoint-side rules for whether blank or short queries return options; use [`controller_helpers.md#blank-query-policy`](controller_helpers.md#blank-query-policy) for the matching `minimum_query_length:` endpoint policy.
- `max_items:` forwards Tom Select's maximum selected item count.
- `load_throttle:` forwards Tom Select's remote load throttle in milliseconds.
- `delimiter:` forwards Tom Select's delimiter option, useful for text-backed token inputs.
- `plugins:` passes explicit Tom Select plugin names for one field and overrides `config.default_plugins` for that field.
- `allow_clear:` controls Rails Fields Kit's semantic `clear_button` auto-add for one field and can override `config.default_allow_clear`.
- `tom_select_class_names:` passes Tom Select internal `classNames` for one field without changing Rails Fields Kit wrapper classes.
- `loading_text:`, `no_results_text:`, and `create_text:` override the bundled or initializer-provided Tom Select copy for one field only.
- `error_surface:` adds a stable nearby placeholder for request-failure handlers.
- `error_surface_html:` customizes that generated placeholder element.

For remote search and selected-option preload, fixed params are URL query params. Scalar values are set on the request URL, array values are appended as repeated query entries for the same key, and `null` / `undefined` values are skipped. `create_params:` is separate: Rails Fields Kit merges those fixed values into the create-on-the-fly JSON body, not the request URL.

When neither the field nor the initializer sets those values, Rails Fields Kit falls back to bundled locale-aware copy at render time. The bundled baseline currently includes English and Japanese, and falls back to English when a locale-specific key is not present.

Use `config.default_loading_text`, `config.default_no_results_text`, and `config.default_create_text` in the initializer when the whole host app should share the same baseline wording. Use the helper options above when a single field needs different copy.

Example:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  create_url: customers_path,
  query_param: "q",
  query_params: { account_id: current_account.id, region: ["east", "priority"] },
  selected_query_params: { account_id: current_account.id },
  create_params: { account_id: current_account.id } %>
```

For remote search, `url:` receives a JSON `GET` request. Rails Fields Kit appends `query_params:` as fixed query string scope and then sets `query_param:` to the current typed query value. Selected values still use `selected_url:` with `selected_param:` or `selected_multiple_param:`, and create input text still uses `create_url:` with JSON `create_params:` plus `create_param:`.

If a field combines `open_on_focus: true` and `preload: true`, treat the initial request volume and blank-query response as host-app endpoint policy. Rails Fields Kit passes the options through and keeps `min_length:` as the client-side request gate; it does not decide whether the endpoint should return popular options, scoped defaults, or an empty list for a blank query.
