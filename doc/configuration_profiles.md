# Configuration Profile Examples

Rails Fields Kit does not ship named initializer profiles. Keep initializer values as ordinary per-key defaults, then copy only the lines that match the host app context.

Field-level helper options still win for one rendered field. These examples are starting points for app-owned configuration, not presets, modes, or design system policy owned by the gem.

## Choosing a Pattern

Use a profile example when a host app repeats the same defaults across many forms:

- Admin-heavy internal tools: denser remote search, more options in the dropdown, and explicit JSON field names.
- Public forms: conservative remote loading, locale-aware bundled render text, and default wrapper hooks.
- Compact table filters: shorter result lists and search parameters that fit table-filter endpoints.

Do not use these examples to standardize authorization, endpoint behavior, validation policy, Tom Select asset loading, or application-specific design systems. Those remain host app responsibilities.

## Admin-heavy Internal Tools

Use this pattern when authenticated staff screens need broad search and predictable option mapping across many fields.

```ruby
RailsFieldsKit.configure do |config|
  config.default_query_param = "q"
  config.default_value_field = "id"
  config.default_label_field = "name"
  config.default_search_field = "name,email,code"
  config.default_min_length = 1
  config.default_max_options = 75
  config.default_open_on_focus = true
end
```

Keep endpoint scoping, authorization, and result ranking in the host app. A field can still opt out with helper-level options such as `min_length:` or `max_options:`.

## Public Forms

Use this pattern when public or low-context forms should avoid surprising remote requests and keep bundled locale-aware copy.

```ruby
RailsFieldsKit.configure do |config|
  config.default_min_length = 2
  config.default_max_options = 25
  config.default_preload = false
  config.default_open_on_focus = false
end
```

Leave `default_no_results_text`, `default_loading_text`, and `default_create_text` unset when the bundled locale-aware text is good enough. Set them only when the host app needs app-specific wording.

## Compact Table Filters

Use this pattern when Rails Fields Kit fields sit inside dense table-filter or admin-list controls.

```ruby
RailsFieldsKit.configure do |config|
  config.default_query_param = "q"
  config.default_value_field = "value"
  config.default_label_field = "text"
  config.default_search_field = "text"
  config.default_min_length = 0
  config.default_max_options = 20
  config.default_close_after_select = true
end
```

This keeps the initializer focused on rendered-field defaults. Query execution, table persistence, filter semantics, and saved-search behavior belong to the host app or the surrounding table integration.

## Boundary

These examples deliberately avoid a Ruby profile API, generator option, or preset registry. Adding named profiles would make profile names, default values, and host-app UX assumptions part of the public surface. If that becomes valuable later, introduce it through a separate feature decision with its own specs and migration notes.
