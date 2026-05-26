# Rails Fields Kit Configuration

Rails Fields Kit can be configured from `config/initializers/rails_fields_kit.rb`.

```ruby
RailsFieldsKit.configure do |config|
  config.controller_name = "rails-fields-kit--tom-select"
end
```

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

Plugins applied to Tom Select-backed helpers by default.

Default: `[]`

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