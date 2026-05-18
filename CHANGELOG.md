# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- `rfk_token_search` for token-oriented search inputs such as `status:open keyword`, keeping parsing and search execution in the host application.
- `rfk_token_suggestions_with` for lightweight token suggestion JSON endpoints that can use static suggestions, controller methods, or callables.
- `RailsFieldsKit::TokenSuggestions.build` for composing operator, field, predicate, value, and saved-search suggestion option JSON.
- `RailsFieldsKit::RansackSuggestions.build` for composing Ransack-compatible token suggestion metadata without requiring or executing Ransack.
- `RailsFieldsKit::TableFilterInput` and `RailsFieldsKit::TableCellInput` factory helpers such as `.combobox`, `.select`, `.tags`, `.enum_select`, `.from_type`, `.known_types`, and `.known_type?` for concise table metadata definitions.
- `RailsFieldsKit::TableFilterInput.token_search` and `RailsFieldsKit::TableFilterInput.ransack_filter` for table metadata that describes token-search filters.
- `RailsFieldsKit::TableMetadata` for collecting Rails Fields Kit filter/editor metadata from table column definitions and table-like objects that respond to `columns`, including common alias keys such as `filter_input`, `search_filter`, `cell_editor`, and `cell_input`, plus render shortcuts for collected filters and editors.
- `RailsFieldsKit::TableRenderer` for turning table filter/editor metadata into FormBuilder call specs or dispatching them through a form builder, including batch rendering APIs and custom table field helper registration.
- `rfk_table_filters` and `rfk_table_cell_editors` for rendering table metadata directly from a FormBuilder.
- `action:` support for `rfk_search_with`, `rfk_find_with`, and `rfk_create_with` so generated endpoint actions can match custom routes.
- Remote request extension options for Tom Select-backed helpers:
  - `query_params:` for fixed search query parameters.
  - `selected_query_params:` for fixed selected preload query parameters.
  - `create_params:` for fixed create-on-the-fly JSON fields.
- Tom Select option pass-throughs for `max_items:`, `load_throttle:`, and `delimiter:`.

## 0.1.0 - 2026-05-18

### Added

- Initial Rails engine skeleton.
- `RailsFieldsKit.configure` and configuration defaults.
- Tom Select-backed FormBuilder helpers:
  - `rfk_select`
  - `rfk_combobox`
  - `rfk_autocomplete`
  - `rfk_tags`
  - `rfk_multi_select`
  - `rfk_grouped_select`
  - `rfk_enum_select`
- Native field helpers:
  - `rfk_text_field`
  - `rfk_text_area`
  - `rfk_number_field`
  - `rfk_money_field`
  - `rfk_percent_field`
  - `rfk_email_field`
  - `rfk_url_field`
  - `rfk_phone_field`
  - `rfk_search_field`
- Wrapper support for labels, hints, errors, prefixes, suffixes, and accessibility attributes.
- Selected option preload with `selected:` and remote selected option loading with `selected_url:`.
- Remote option loading with configurable request params and JSON field names.
- Create-on-the-fly option support with `create_url:`.
- Rich option rendering with description and badge fields.
- Tom Select UX options:
  - `open_on_focus`
  - `close_after_select`
  - `hide_selected`
  - `persist`
  - `max_options`
  - `preload`
  - custom no-results/loading/create text
- Option-level customization:
  - disabled options
  - grouped options
  - per-option HTML attributes
- `RailsFieldsKit::Searchable` controller concern.
- `rfk_search_with` for remote search endpoints.
- `rfk_find_with` for selected option lookup endpoints.
- `rfk_create_with` for create-on-the-fly endpoints.
- Controller helper support for scopes, ordering, distinct results, rich fields, assignments, authorization, and before-save hooks.
- Stimulus events for remote loading, selected preload, create errors, and Tom Select interaction forwarding.
- Install generator.
- Documentation:
  - `doc/setup.md`
  - `doc/public_api.md`
  - `doc/field_helpers.md`
  - `doc/controller_helpers.md`
  - `doc/configuration.md`
  - `doc/events.md`
  - `doc/development.md`
  - `doc/sample_app_checklist.md`
  - `doc/sample_app_results.md`
  - `doc/final_release_checklist.md`
  - `doc/release_notes_0_1_0.md`
  - `doc/release.md`

### Changed

- Rails support targets Rails 7.0 and newer.
- Rails dependency is bounded to Rails 7 and Rails 8 for the initial release line.
- Tom Select installation and JavaScript bundling strategy are intentionally left to the host application.

### Fixed

- Avoided requiring mountable engine namespace isolation for this helper-only engine.
- Preserved explicit `false` option values when falling back to configuration defaults.
- Separated boolean `disabled:` for the entire select from array/value `disabled:` for specific options.