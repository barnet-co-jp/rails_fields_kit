# Rails Fields Kit Configuration

Rails Fields Kit can be configured from `config/initializers/rails_fields_kit.rb`.

```ruby
RailsFieldsKit.configure do |config|
  config.controller_name = "rails-fields-kit--tom-select"
end
```

## Quick reference

Use this table to find the initializer key, field-level override, and default behavior before jumping into the detailed sections below.

| Initializer key | Default or fallback | Field-level override | Applies to | Notes |
| --- | --- | --- | --- | --- |
| `controller_name` | `"rails-fields-kit--tom-select"` | none | Tom Select-backed helpers | Stimulus controller identifier appended to rendered fields. |
| `default_query_param` | `"q"` | `query_param:` | Remote search helpers | Query parameter sent to `url:`. |
| `default_selected_param` | `"id"` | `selected_param:` | `selected_url:` for one value | Selected preload parameter for single-value fields. |
| `default_selected_multiple_param` | `"ids"` | `selected_multiple_param:` | `selected_url:` for multiple values | Selected preload parameter for multi-value fields. |
| `default_create_param` | `"text"` | `create_param:` | Create-on-the-fly helpers | Request parameter sent to `create_url:`. |
| `default_value_field` | `"value"` | `value_field:` | JSON-backed option helpers | JSON key read for option values. |
| `default_label_field` | `"text"` | `label_field:` | JSON-backed option helpers | JSON key read for option labels. |
| `default_search_field` | `"text"` | `search_field:` | Tom Select search config | Use a comma-separated string for multiple fields. |
| `default_option_description_field` | `nil` | `option_description_field:` | Option rendering metadata | `nil` means no secondary description field is rendered. |
| `default_option_badge_field` | `nil` | `option_badge_field:` | Option rendering metadata | `nil` means no badge field is rendered. |
| `default_plugins` | `[]` | `plugins:` | Tom Select-backed helpers | Helper defaults can seed plugins first; `allow_clear: true` adds `clear_button`. |
| `default_min_length` | `0` | `min_length:` | Remote loading | Minimum query length before loading starts. |
| `default_max_options` | `nil` | `max_options:` | Tom Select dropdowns | `nil` leaves the Tom Select data value unset. |
| `default_preload` | `nil` | `preload:` | Tom Select preload behavior | `nil` leaves the Tom Select data value unset. |
| `default_open_on_focus` | `nil` | `open_on_focus:` | Tom Select focus behavior | `nil` leaves the Tom Select data value unset. |
| `default_close_after_select` | `nil` | `close_after_select:` | Tom Select selection behavior | `nil` leaves the Tom Select data value unset. |
| `default_hide_selected` | `nil` | `hide_selected:` | Tom Select selected-option behavior | `nil` leaves the Tom Select data value unset. |
| `default_persist` | `nil` | `persist:` | Create-on-the-fly / token helpers | `nil` leaves the Tom Select data value unset; some helpers can pass their own default. |
| `default_no_results_text` | bundled locale-aware copy | `no_results_text:` | Render text | Unset initializer values use bundled I18n copy with English fallback. |
| `default_loading_text` | bundled locale-aware copy | `loading_text:` | Render text | Unset initializer values use bundled I18n copy with English fallback. |
| `default_create_text` | bundled locale-aware copy | `create_text:` | Render text | Unset initializer values use bundled I18n copy with English fallback. |
| `wrapper_class` | `"rfk-field"` | `wrapper_html:` | Native and Tom Select wrappers | Appended to wrapper classes when `wrapper:` renders a wrapper. |
| `label_class` | `"rfk-label"` | `label_html:` | Labels | Appended to generated label classes. |
| `hint_class` | `"rfk-hint"` | `hint_html:` | Hints | Appended to generated hint classes. |
| `error_class` | `"rfk-error"` | `error_html:` | Validation errors | Appended to generated error classes. |
| `field_error_class` | `"rfk-field--error"` | none | Field wrappers with validation errors | Appended to wrappers when the object has errors for the field. |
| `control_class` | `"rfk-control"` | `control_html:` | Prefix / suffix control wrappers | Appended when a field renders `prefix:` or `suffix:`. |
| `prefix_class` | `"rfk-prefix"` | `prefix_html:` | Prefix elements | Appended to generated prefix classes. |
| `suffix_class` | `"rfk-suffix"` | `suffix_html:` | Suffix elements | Appended to generated suffix classes. |

Field-level options win over initializer defaults for the one rendered helper. For Tom Select defaults whose initializer value is `nil`, Rails Fields Kit omits that data value so the host app's Tom Select setup or Tom Select's own defaults can decide the behavior. Render text defaults are different: leaving the initializer unset uses Rails Fields Kit's bundled locale-aware copy.

## Controller

### `controller_name`

Stimulus controller identifier used by Tom Select-backed helpers.

Default:

```ruby
"rails-fields-kit--tom-select"
```

## Request parameter defaults

### `default_query_param`

Parameter used for remote search queries.

Default: `"q"`

### `default_selected_param`

Parameter used by `selected_url:` for one selected value.

Default: `"id"`

### `default_selected_multiple_param`

Parameter used by `selected_url:` for multiple selected values.

Default: `"ids"`

### `default_create_param`

Parameter used for create-on-the-fly requests.

Default: `"text"`

## JSON field defaults

### `default_value_field`

JSON key used for option values.

Default: `"value"`

### `default_label_field`

JSON key used for option labels.

Default: `"text"`

### `default_search_field`

Tom Select search field name. Use a comma-separated string for multiple fields, such as `"name,email"`.

Default: `"text"`

### `default_option_description_field`

JSON key used for the optional secondary line in option rendering.

Default: `nil`

### `default_option_badge_field`

JSON key used for the optional badge in option rendering.

Default: `nil`

## Tom Select defaults

### `default_plugins`

Plugins applied to Tom Select-backed helpers by default when the helper call does not pass `plugins:`.

Default: `[]`

Field-level `plugins:` replaces this initializer default for that one field. Use it when one helper needs a narrower or wider plugin list than the app-wide baseline.

Some helpers seed their own representative plugin defaults before the initializer fallback is considered:

- `rfk_tags` and `rfk_token_search` use Tom Select's `remove_button` plugin by default when `plugins:` is omitted, because those lanes are multiple-token entry surfaces where removing selected items is part of the expected interaction.
- `allow_clear: true` adds Tom Select's `clear_button` plugin to the effective plugin list for that field.

Rails Fields Kit passes plugin names through to the rendered Tom Select configuration. It does not install Tom Select plugins, import plugin-specific assets, or own plugin-specific behavior beyond the documented helper defaults. Keep those concerns in the host app's Tom Select setup.

### `default_min_length`

Minimum query length before remote loading starts.

Default: `0`

### `default_max_options`

Maximum number of options Tom Select should show.

Default: `nil`

### `default_preload`

Tom Select preload behavior.

Default: `nil`

### `default_open_on_focus`

Whether Tom Select should open when focused.

Default: `nil`

### `default_close_after_select`

Whether Tom Select should close after selection.

Default: `nil`

### `default_hide_selected`

Whether selected options should be hidden from dropdown results.

Default: `nil`

### `default_persist`

Whether created options should persist in Tom Select.

Default: `nil`

## Field-level override precedence

Tom Select-backed helpers use initializer defaults only when the helper call omits the matching field-level option. Passing the option on one helper changes that rendered field without changing the app-wide baseline.

```ruby
# config/initializers/rails_fields_kit.rb
RailsFieldsKit.configure do |config|
  config.default_query_param = "term"
  config.default_value_field = "id"
  config.default_label_field = "name"
  config.default_search_field = "name,email"
  config.default_max_options = 50
end
```

```erb
<%= form.rfk_autocomplete :assignee_id,
  url: users_path,
  query_param: "lookup",
  value_field: "uuid",
  label_field: "display_name",
  search_field: "display_name,email",
  max_options: 10 %>
```

That helper renders `lookup`, `uuid`, `display_name`, `display_name,email`, and `10` for its Tom Select data values. Other helpers that omit those options still use the initializer defaults. The same pattern applies to request parameter defaults (`query_param:`, `selected_param:`, `selected_multiple_param:`, `create_param:`), JSON field defaults (`value_field:`, `label_field:`, `search_field:`, `option_description_field:`, `option_badge_field:`), and Tom Select defaults (`min_length:`, `max_options:`, `preload:`, `open_on_focus:`, `close_after_select:`, `hide_selected:`, `persist:`).

## Render text defaults

When the initializer leaves these values unset, Rails Fields Kit uses bundled locale-aware copy at render time. That keeps the default Tom Select wording closer to the host app locale without taking away existing override paths.

Override precedence for Tom Select-backed helpers is:

1. field-level options such as `loading_text:`, `no_results_text:`, and `create_text:`
2. initializer defaults such as `config.default_loading_text`
3. bundled locale-aware defaults (`I18n.locale`, with English fallback)

### `default_no_results_text`

Text shown when no result is found.

Bundled fallback:

- `en`: `"No results found"`
- `ja`: `"該当する項目はありません"`

### `default_loading_text`

Text shown while remote options are loading.

Bundled fallback:

- `en`: `"Loading..."`
- `ja`: `"読み込み中..."`

### `default_create_text`

Text shown for the create option.

Bundled fallback:

- `en`: `"Add"`
- `ja`: `"追加"`

## Wrapper class defaults

These defaults set the repo-wide baseline classes appended to wrapper pieces. Use helper-level `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` when one field needs extra classes, `data`, or aria attributes without changing the initializer for every field.

### `wrapper_class`

Class used for the outer field wrapper.

Default: `"rfk-field"`

### `label_class`

Class used for labels.

Default: `"rfk-label"`

### `hint_class`

Class used for hints.

Default: `"rfk-hint"`

### `error_class`

Class used for validation error messages.

Default: `"rfk-error"`

### `field_error_class`

Class added to wrappers when the object has errors for the field.

Default: `"rfk-field--error"`

## Affix class defaults

### `control_class`

Class used for controls wrapping inputs with prefixes or suffixes.

Default: `"rfk-control"`

### `prefix_class`

Class used for prefixes.

Default: `"rfk-prefix"`

### `suffix_class`

Class used for suffixes.

Default: `"rfk-suffix"`

## Example initializer

```ruby
RailsFieldsKit.configure do |config|
  config.default_query_param = "q"
  config.default_value_field = "id"
  config.default_label_field = "name"
  config.default_search_field = "name,email"
  config.default_min_length = 2
  config.default_max_options = 50

  # Use only plugin names already available in your Tom Select setup.
  # Field-level plugins: overrides this default for one helper.
  # config.default_plugins = ["dropdown_input"]

  # Uncomment these when your host app wants repo-wide wording.
  # config.default_no_results_text = "No matches"
  # config.default_loading_text = "Searching..."
  # config.default_create_text = "Create"

  config.wrapper_class = "field"
  config.label_class = "form-label"
  config.hint_class = "form-text"
  config.error_class = "invalid-feedback"
  config.field_error_class = "field--invalid"
end
```