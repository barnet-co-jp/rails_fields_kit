# Rails Fields Kit Configuration

Rails Fields Kit can be configured from `config/initializers/rails_fields_kit.rb`.

Use [`configuration_profiles.md`](configuration_profiles.md) when you want copyable initializer-default examples for common host-app contexts. Those examples are docs-only patterns, not named profiles, preset APIs, generator options, or design system policy owned by the gem.

```ruby
RailsFieldsKit.configure do |config|
  config.controller_name = "rails-fields-kit--tom-select"
  config.enum_i18n_key = ->(method, value) { "#{method}.#{value}" }
end
```

## Quick reference

Use these grouped tables to find the initializer key, field-level override, and default behavior before jumping into the detailed sections below. Field-level options win over initializer defaults for the one rendered helper.

Read the quick reference in this order:

1. Pick the group that matches the thing you are changing: request params, JSON mapping, enum label lookup, Tom Select behavior, rendered text, or wrapper classes.
2. Use `Field-level override` when only one helper render should differ from the app-wide initializer default.
3. Check `Default or fallback` before adding an initializer. Some defaults render a concrete value, some `nil` Tom Select settings omit the data value, and render text uses bundled locale-aware copy when unset.

Default behavior uses three different patterns:

- Concrete values such as `"q"` or `"value"` are rendered unless the field-level option overrides them.
- `nil` Tom Select interaction defaults leave the matching data value unset so the host app's Tom Select setup or Tom Select itself can decide.
- Render text defaults use bundled locale-aware copy with English fallback when unset; this is different from omitting a Tom Select data value.

### Controller and remote request params

| Initializer key | Default or fallback | Field-level override | Applies to | Notes |
| --- | --- | --- | --- | --- |
| `controller_name` | `"rails-fields-kit--tom-select"` | none | Tom Select-backed helpers | Stimulus controller identifier appended to rendered fields. |
| `default_query_param` | `"q"` | `query_param:` | Remote search helpers | Query parameter sent to `url:`. |
| `default_selected_param` | `"id"` | `selected_param:` | `selected_url:` for one value | Selected preload parameter for single-value fields. |
| `default_selected_multiple_param` | `"ids"` | `selected_multiple_param:` | `selected_url:` for multiple values | Selected preload parameter for multi-value fields. |
| `default_create_param` | `"text"` | `create_param:` | Create-on-the-fly helpers | Request parameter sent to `create_url:`. |

### JSON field mapping and option metadata

| Initializer key | Default or fallback | Field-level override | Applies to | Notes |
| --- | --- | --- | --- | --- |
| `default_value_field` | `"value"` | `value_field:` | JSON-backed option helpers | JSON key read for option values. |
| `default_label_field` | `"text"` | `label_field:` | JSON-backed option helpers | JSON key read for option labels. |
| `default_search_field` | `"text"` | `search_field:` | Tom Select search config | Use a comma-separated string for multiple fields. |
| `default_option_description_field` | `nil` | `option_description_field:` | Option rendering metadata | `nil` means no secondary description field is rendered. |
| `default_option_badge_field` | `nil` | `option_badge_field:` | Option rendering metadata | `nil` means no badge field is rendered. |

### Enum label I18n

| Initializer key | Default or fallback | Field-level override | Applies to | Notes |
| --- | --- | --- | --- | --- |
| `enum_i18n_key` | `->(method, value) { "#{method}.#{value}" }` | none | `rfk_enum_select` | Callable that returns the attribute key passed to `human_attribute_name`. |

`enum_i18n_key` changes only how `rfk_enum_select` builds the attribute key used for model label lookup. The default preserves the existing `status.draft` style. Host applications that use another convention can provide a callable, for example `->(method, value) { "#{method}/#{value}" }`, without overriding private FormBuilder methods.

### Tom Select interaction defaults

| Initializer key | Default or fallback | Field-level override | Applies to | Notes |
| --- | --- | --- | --- | --- |
| `default_plugins` | `[]` | `plugins:` | Tom Select-backed helpers | Helper defaults can seed plugins first; `allow_clear: true` adds `clear_button`. |
| `default_allow_clear` | `false` | `allow_clear:` | Tom Select-backed helpers | Adds `clear_button` when a helper omits `allow_clear:` and the app-wide default is enabled. |
| `default_min_length` | `0` | `min_length:` | Remote loading | Minimum query length before loading starts. |
| `default_max_options` | `nil` | `max_options:` | Tom Select dropdowns | `nil` leaves the Tom Select data value unset. |
| `default_load_throttle` | `nil` | `load_throttle:` | Remote loading | `nil` leaves the Tom Select data value unset. |
| `default_preload` | `nil` | `preload:` | Tom Select preload behavior | `nil` leaves the Tom Select data value unset. |
| `default_open_on_focus` | `nil` | `open_on_focus:` | Tom Select focus behavior | `nil` leaves the Tom Select data value unset. |
| `default_close_after_select` | `nil` | `close_after_select:` | Tom Select selection behavior | `nil` leaves the Tom Select data value unset. |
| `default_hide_selected` | `nil` | `hide_selected:` | Tom Select selected-option behavior | `nil` leaves the Tom Select data value unset. |
| `default_persist` | `nil` | `persist:` | Create-on-the-fly / token helpers | `nil` leaves the Tom Select data value unset; some helpers can pass their own default. |

For Tom Select defaults whose initializer value is `nil`, Rails Fields Kit omits that data value so the host app's Tom Select setup or Tom Select's own defaults can decide the behavior.

### Render text and visible feedback

| Initializer key | Default or fallback | Field-level override | Applies to | Notes |
| --- | --- | --- | --- | --- |
| `default_no_results_text` | bundled locale-aware copy | `no_results_text:` | Render text | Unset initializer values use bundled I18n copy with English fallback. |
| `default_loading_text` | bundled locale-aware copy | `loading_text:` | Render text | Unset initializer values use bundled I18n copy with English fallback. |
| `default_create_text` | bundled locale-aware copy | `create_text:` | Render text | Unset initializer values use bundled I18n copy with English fallback. |

Render text defaults are different from `nil` Tom Select settings: leaving the initializer unset uses Rails Fields Kit's bundled locale-aware copy.

Request-failure feedback options such as `error_surface:` and `error_surface_html:` are field-level helper options, not initializer keys. See [shared request-failure feedback options](field_helpers.md#shared-request-failure-feedback-options) for the `load-error`, `selected-load-error`, and `create-error` surfaces.

### Wrapper and affix classes

| Initializer key | Default or fallback | Field-level override | Applies to | Notes |
| --- | --- | --- | --- | --- |
| `wrapper_class` | `"rfk-field"` | `wrapper_html:` | Native and Tom Select wrappers | Appended to wrapper classes when `wrapper:` renders a wrapper. |
| `label_class` | `"rfk-label"` | `label_html:` | Labels | Appended to generated label classes. |
| `hint_class` | `"rfk-hint"` | `hint_html:` | Hints | Appended to generated hint classes. |
| `error_class` | `"rfk-error"` | `error_html:` | Validation errors | Appended to generated error classes. |
| `field_error_class` | `"rfk-field--error"` | none | Field wrappers with validation errors | Appended to wrappers when the object has errors for the field. |
| `control_class` | `"rfk-control"` | `control_html:` | Prefix / suffix control wrappers | Appended when a field renders `prefix:` or `suffix:`. |
| `prefix_class` | `"rfk-prefix"` | `prefix_html:` | Prefix elements | Appended to generated prefix classes. |
| `suffix_class` | `"rfk-suffix"` | `suffix_html:` | Suffix elements | Appended to generated suffix classes. |

The wrapper and affix class options above apply to HTML that Rails Fields Kit renders around the field. They do not pass Tom Select's internal `classNames` option through to generated control, dropdown, wrapper, option, item, or loading markup. Use field-level `tom_select_class_names:` only when one helper needs Tom Select internal class hooks, and keep that separate from wrapper, label, hint, error, and affix classes.

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

## Enum label I18n

### `enum_i18n_key`

Callable used by `rfk_enum_select` to build the attribute key passed to the model class's `human_attribute_name`.

Default:

```ruby
->(method, value) { "#{method}.#{value}" }
```

For an application that stores enum translations under slash-style attribute keys:

```ruby
RailsFieldsKit.configure do |config|
  config.enum_i18n_key = ->(method, value) { "#{method}/#{value}" }
end
```

The callable receives the enum attribute method and enum key. It must respond to `#call`. Rails Fields Kit still delegates the actual translation lookup and wording to the model's `human_attribute_name`; this setting only changes the generated attribute key. There is no field-level override in 1.0.1.

See [`enum_select.md`](enum_select.md) for the enum source and label boundary.

## Tom Select defaults

### `default_plugins`

Plugins applied to Tom Select-backed helpers by default when the helper call does not pass `plugins:`.

Default: `[]`

Field-level `plugins:` replaces this initializer default for that one field. Use it when one helper needs a narrower or wider plugin list than the app-wide baseline.

Some helpers seed their own representative plugin defaults before the initializer fallback is considered:

- `rfk_tags` and `rfk_token_search` use Tom Select's `remove_button` plugin by default when `plugins:` is omitted, because those lanes are multiple-token entry surfaces where removing selected items is part of the expected interaction.
- `allow_clear: true` adds Tom Select's `clear_button` plugin to the effective plugin list for that field.

Rails Fields Kit passes plugin names through to the rendered Tom Select configuration. It does not install Tom Select plugins, import plugin-specific assets, or own plugin-specific behavior beyond the documented helper defaults. Keep those concerns in the host app's Tom Select setup.

### `default_allow_clear`

App-wide semantic default for adding Tom Select's `clear_button` plugin when a helper does not pass `allow_clear:`.

Default: `false`

Field-level `allow_clear:` replaces this initializer default for that one helper. Use `allow_clear: true` when one field should be clearable even though the app-wide default is off. Use `allow_clear: false` when one field should suppress the app-wide clear affordance.

`allow_clear: false` only suppresses Rails Fields Kit's semantic auto-add. It does not remove plugin names that the host app supplies directly through `plugins:` or `RailsFieldsKit.configuration.default_plugins`.

`default_plugins` remains the raw Tom Select plugin pass-through. `default_allow_clear` only controls the semantic clear-button default and does not install Tom Select plugins, import plugin-specific assets, define styling, or own plugin lifecycle behavior.

See [`default_allow_clear.md`](default_allow_clear.md) for focused examples and non-goals.

### Tom Select internal class names

Rails Fields Kit's initializer class configuration is limited to the wrapper, label, hint, error, affix, and control wrapper pieces that Rails Fields Kit renders. It is not a Tom Select theme or initializer-level internal DOM class API.

Use field-level `tom_select_class_names:` when one Tom Select-backed helper needs to pass Tom Select's `classNames` option for internal generated parts such as the control, dropdown, option, item, or loading states:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  tom_select_class_names: {
    control: "ts-control app-select-control",
    dropdown: "ts-dropdown app-select-dropdown"
  } %>
```

`tom_select_class_names:` is separate from `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:`. Rails Fields Kit passes the provided hash through to Tom Select for that one rendered field; it does not add an initializer-level default, production CSS, theme presets, dark mode, density policy, or Tom Select internal DOM compatibility guarantees.

See [`tom_select_class_names.md`](tom_select_class_names.md) for focused examples and non-goals.

### `default_min_length`

Minimum query length before remote loading starts.

Default: `0`

### `default_max_options`

Maximum number of options Tom Select should show.

Default: `nil`

### `default_load_throttle`

Remote loading throttle in milliseconds for Tom Select-backed helpers when the helper call does not pass `load_throttle:`.

Default: `nil`

Field-level `load_throttle:` replaces this initializer default for that one helper. Leave the initializer unset when the host app wants Tom Select or its local setup to own remote loading cadence.

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
  config.default_load_throttle = 300
  config.default_allow_clear = true
end
```

```erb
<%= form.rfk_autocomplete :assignee_id,
  url: users_path,
  query_param: "lookup",
  value_field: "uuid",
  label_field: "display_name",
  search_field: "display_name,email",
  max_options: 10,
  load_throttle: 150,
  allow_clear: false %>
```

That helper renders `lookup`, `uuid`, `display_name`, `display_name,email`, `10`, and `150` for its Tom Select data values and does not add `clear_button` because `allow_clear: false` overrides the app-wide clear default. Other helpers that omit those options still use the initializer defaults. The same pattern applies to request parameter defaults (`query_param:`, `selected_param:`, `selected_multiple_param:`, `create_param:`), JSON field defaults (`value_field:`, `label_field:`, `search_field:`, `option_description_field:`, `option_badge_field:`), and Tom Select defaults (`plugins:`, `allow_clear:`, `min_length:`, `max_options:`, `load_throttle:`, `preload:`, `open_on_focus:`, `close_after_select:`, `hide_selected:`, `persist:`).

`enum_i18n_key` is intentionally app-wide in 1.0.1 and has no field-level override. Configure it only when the application uses a different `human_attribute_name` key convention for enum labels.

Wrapper and affix class overrides follow a different lane: `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` customize Rails Fields Kit-rendered wrapper pieces only. Use `tom_select_class_names:` when one Tom Select-backed field needs internal Tom Select class hooks for that rendered field.

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

## Request-failure feedback policy

`error_surface:` and `error_surface_html:` stay field-level helper options. They are not initializer defaults because request-failure UI usually depends on the endpoint, surrounding layout, copy, retry affordance, and authorization or validation policy owned by the host app.

When the host app wants the same request-failure placeholder policy across many remote fields, keep that reuse in the host app. A view helper, partial, or FormBuilder extension can pass the same field-level options without adding a Rails Fields Kit initializer key:

```ruby
module RemoteFieldFeedbackHelper
  def rfk_remote_error_surface_options
    {
      error_surface: true,
      error_surface_html: {
        class: "remote-field-feedback",
        data: { controller: "remote-field-feedback" }
      }
    }
  end
end
```

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  **rfk_remote_error_surface_options %>
```

Use that host-owned wrapper to standardize placeholder classes or event-handler wiring. Keep visible message text, retry buttons, endpoint validation, analytics, and authorization decisions in the host app that receives the `load-error`, `selected-load-error`, or `create-error` event. If a future initializer-level default is added by a separate feature decision, update this section after that public surface lands; until then, do not set a `default_error_surface` configuration key.

## Wrapper class defaults

These defaults set the repo-wide baseline classes appended to wrapper pieces. Use helper-level `wrapper_html:`, `label_html:`, `hint_html:`, `error_html:`, `control_html:`, `prefix_html:`, and `suffix_html:` when one field needs extra classes, `data`, or aria attributes without changing the initializer for every field.

These defaults do not target Tom Select's internal generated markup. Use `tom_select_class_names:` for a one-field internal classNames pass-through, or keep broader Tom Select theming in the host app.

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
  config.default_load_throttle = 300
  config.default_allow_clear = true

  # Customize enum label lookup keys when the host app uses another
  # human_attribute_name convention. Default: "#{method}.#{value}".
  # config.enum_i18n_key = ->(method, value) { "#{method}/#{value}" }

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