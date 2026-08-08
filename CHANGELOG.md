# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

- Add `rfk_lookup` for free-text values paired with optional selected IDs, and escaped declarative `option_metadata_fields` previews for Tom Select-backed helpers.

### Release digest

The next release is primarily about making the 0.1.x public surface easier to adopt without moving host-app responsibilities into the gem:

- Token-oriented search helpers and suggestion builders make structured search inputs easier to wire while keeping query parsing and execution in the host application.
- Table metadata adapters and FormBuilder rendering helpers let table integrations describe Rails Fields Kit fields and scoped renderer overrides without taking over table persistence, query ownership, or long-lived global registry changes.
- Native wrapper helpers now cover range, password, file, checkbox, radio button, and browser-native date/time/datetime-local/color inputs while keeping browser behavior, upload workflows, checkbox/radio group semantics, timezone conversion, validation UI, and production CSS in the host application.
- Package-root JavaScript exports, Tom Select request options, create-success events, install generator setup-note opt-out, setup doctor status guidance, machine-readable setup doctor JSON output, and opt-in request-failure surfaces improve integration hooks around rendered fields and host-app setup.
- Controller helper and FormBuilder documentation now call out landed endpoint-side query minimums, endpoint-side search match strategies, supported remote collection wrappers, and enum source boundaries without turning search execution, pagination metadata, adapter-specific SQL behavior, or arbitrary enum adapters into gem-owned behavior.
- The fixed entries below mostly harden request lifecycle docs, suggestion metadata immutability, and table metadata normalization so release reviewers can distinguish user-facing additions from quality fixes.

The detailed entries remain the exhaustive source of truth for release review. Keep proposal or open-PR behavior out of this section until it has landed in the release branch.

### Added

#### FormBuilder helpers

- `rfk_enum_select` now has a focused explicit `enum:` hash guide for Rails enum-shaped sources. Hash keys remain the submitted values, labels stay on the model I18n / humanized-key path, and arbitrary label/value DSLs, remote enum option lookup, and PORO enum adapters remain outside the current public surface.
- `rfk_range_field` now provides a thin native range input wrapper with the same label, hint, error, affix, pass-through option, and accessibility wiring boundaries as the other native helpers. Browser slider behavior, live value previews, custom slider styling, multi-thumb controls, validation policy, and production CSS remain host-app responsibilities.
- `rfk_password_field` now provides a thin native password input wrapper with the same label, hint, error, affix, pass-through option, and accessibility wiring boundaries as the other native helpers. Password visibility toggles, strength meters, credential policy, authentication workflow, and credential storage remain host-app responsibilities.
- `rfk_file_field` now provides a thin native file input wrapper with the same wrapper, label, hint, error, pass-through option, and accessibility wiring boundaries as the other native helpers. Multipart forms, Active Storage direct upload JavaScript, previews, progress UI, file validation, storage configuration, virus scanning, and production CSS remain host-app responsibilities.
- `rfk_check_box` now provides a thin native checkbox wrapper that preserves Rails' hidden field and checked / unchecked value contract while adding the shared wrapper and accessibility wiring. Collection checkbox groups, radio buttons, validation UI redesign, label placement redesign, and production CSS remain outside the current public surface.
- `rfk_radio_button` now provides a thin native radio input wrapper that preserves Rails' value, checked-state, and same-name group behavior while adding the shared wrapper and accessibility wiring. Collection radio groups, fieldset / legend builders, group-level validation UI, and production CSS remain outside the current public surface.
- `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field` now provide thin browser-native wrapper helpers while leaving timezone conversion, masking, custom picker UI, browser normalization, validation policy, locale formatting, and production CSS in the host application.

#### Token search and suggestion metadata

- `rfk_token_search` for token-oriented search inputs such as `status:open keyword`, keeping parsing and search execution in the host application.
- `rfk_token_suggestions_with` for lightweight token suggestion JSON endpoints that can use static suggestions, controller methods, or callables.
- `RailsFieldsKit::TokenSuggestions.build` for composing operator, field, predicate, value, and saved-search suggestion option JSON.
- `RailsFieldsKit::RansackSuggestions.build` for composing Ransack-compatible token suggestion metadata without requiring or executing Ransack, including predicate aliases, custom output field mappings, and mutation-safe value metadata handling.
- Host-app owned shared field/operator metadata can now be documented as a reusable pattern across `RailsFieldsKit::TokenSuggestions.build`, `RailsFieldsKit::RansackSuggestions.build`, and `RailsFieldsKit::TableFilterInput.ransack_filter` without introducing a public Ruby registry API; token parsing, authorization, Ransack configuration, and search execution remain host-app responsibilities.

#### Table metadata and rendering

- `RailsFieldsKit::TableFilterInput` and `RailsFieldsKit::TableCellInput` factory helpers such as `.combobox`, `.select`, `.tags`, `.enum_select`, `.from_type`, `.known_types`, `.known_type?`, `#to_h`, and `#to_hash` for concise table metadata definitions.
- `RailsFieldsKit::TableMetadata` can collect hash-like column definitions and hash-like metadata objects that respond to `to_hash` when table integrations do not expose concrete Hash columns, `to_table_filter`, or `to_table_cell_editor`.
- `RailsFieldsKit::TableFilterInput.token_search` and `RailsFieldsKit::TableFilterInput.ransack_filter` for table metadata that describes token-search filters.
- `RailsFieldsKit::TableMetadata` for collecting Rails Fields Kit filter/editor metadata from table column definitions and table-like objects that respond to `columns`, including common alias keys such as `filter_input`, `search_filter`, `cell_editor`, and `cell_input`, render shortcuts for collected filters and editors, and duplication safety for collected metadata hashes from hash, hash-like metadata, and hash-like column inputs.
- `RailsFieldsKit::TableRenderer` for turning table filter/editor metadata into FormBuilder call specs or dispatching them through a form builder, including ordered batch rendering APIs, custom table field helper registration with normalized field/helper names, block-scoped `with_field_helpers` overrides that restore the registry after the block, normalized field type and method handling, duplication safety for metadata options and hash-like options objects, duplicated mapping introspection, and mapping helper APIs.
- `rfk_table_filters` and `rfk_table_cell_editors` for rendering table metadata directly from a FormBuilder, including mixed hash/object/hash-like columns, enumerator columns, hash-like column inputs, table-like object inputs, custom table helper registrations, reset behavior, and safe-buffer rendering contracts.
- `group_html:` for `rfk_table_filters` and `rfk_table_cell_editors` when a host app needs one group-level outer `<div>` around direct FormBuilder output; table layout, persistence, query execution, and visible save/error copy remain host-app or table-integration responsibilities.

#### Install generator

- `rails generate rails_fields_kit:install --skip-setup-notes` lets host apps skip only the generated `doc/rails_fields_kit_setup.md` artifact while still creating `config/initializers/rails_fields_kit.rb` and leaving Tom Select / importmap setup ownership unchanged.
- `rails rails_fields_kit:doctor` output now starts with a short status legend and next-step guidance so first-time adopters can distinguish `[MISSING]` setup gaps from `[MANUAL]` host-app JavaScript checks; the doctor remains read-only and does not auto-fix setup, choose Tom Select policy, or define host-app CI gates.
- `RailsFieldsKit::SetupDoctor#run(format: :json)` can emit a machine-readable representation of the same read-only setup checks for host-app scripts and release verification. The text output remains the default, and the JSON payload stays diagnostic data rather than a Rails Fields Kit-owned CI pass/fail policy, auto-fix mechanism, SARIF/JUnit output, or formal external schema.

#### JavaScript exports and Tom Select integration

- `tomSelectTextOverrideContract(element)` from the package root for host-app scripts that need to read rendered Tom Select text override values without reaching into the Stimulus controller instance.
- `tomSelectPluginContract(element)` from the package root for host-app scripts that need to read rendered Tom Select plugin data, including the effective plugin list and derived clear/remove flags, without owning plugin assets, control styling, selection mutation, or Tom Select lifecycle behavior.
- `tomSelectSelectionContract(element)` from the package root for host-app scripts that need to read initialized Tom Select-backed field selection values on demand, without mutating selections, exposing Tom Select internals, or owning validation feedback.
- `tomSelectRequestContract(element)` from the package root for host-app scripts that need to read rendered request endpoint and parameter config, including `url`, `selectedUrl`, `createUrl`, `queryParam`, `selectedParam`, `selectedMultipleParam`, `createParam`, `minLength`, and `errorSurfaceId`, without executing requests, authorizing endpoints, or owning visible feedback.
- `readRenderedErrorSurface(element)` from the package root for host-app scripts that need to resolve the rendered opt-in request-failure placeholder for a Tom Select-backed field, without creating feedback, executing requests, retrying failures, or owning visible copy.
- `nativeFieldAccessibilityContract(element)` from the package root for host-app scripts that need to read rendered native input accessibility wiring, including the resolved label association, without taking over id generation, label text, validation messages, focus management, or visible feedback.
- `readRenderedSelectedPreloadConfig(element)` from the package root for host-app scripts that need to read rendered `selected_url:` config values without executing selected preload requests, owning visible fallback copy, or adding retry UI to the gem.
- `action:` support for `rfk_search_with`, `rfk_find_with`, and `rfk_create_with` so generated endpoint actions can match custom routes.
- `rfk_search_with minimum_query_length:` for endpoints that should return empty options for blank or too-short queries while keeping the default blank-query initial options behavior when omitted. FormBuilder `min_length:` remains a browser-side loading hint, and authorization, scoping, query parsing, Ransack integration, and Tom Select lifecycle remain host-app responsibilities.
- `rfk_search_with match:` for endpoint-side SQL LIKE pattern strategies. The default stays `:contains`, while `:prefix` and `:exact` let host apps choose narrower matching without moving case sensitivity, adapter-specific SQL, authorization, or custom query semantics into Rails Fields Kit.
- `rfk_find_with` supports Rails array params for multiple selected option preload in addition to comma-separated `ids`, including custom `ids_param:` names.
- Remote search and selected preload docs now list `{ results: [...] }` alongside raw arrays and `{ options: [...] }` as supported collection response wrappers; create-on-the-fly `{ option: ... }`, pagination metadata, and arbitrary response adapters remain separate from that collection wrapper contract.
- Remote request extension options for Tom Select-backed helpers:
  - `query_params:` for fixed search query parameters.
  - `selected_query_params:` for fixed selected preload query parameters.
  - `create_params:` for fixed create-on-the-fly JSON fields.
- Tom Select option pass-throughs for `max_items:`, `load_throttle:`, and `delimiter:`.
- Opt-in `error_surface:` and `error_surface_html:` support for Tom Select-backed helpers so request-failure events can expose a stable nearby placeholder as `detail.surface` without moving visible error copy or retry UI into the gem.

### Fixed

#### Documentation and release evidence

- Visual reference release evidence docs now distinguish browser-verified `PASS` / `FAIL` results from `SOURCE REVIEW ONLY` and `DEFERRED` handoffs, so CI or source review alone is not treated as visual approval.
- Documentation drift guards now cover visual reference HTML artifact structure, same-file HTML fragment link-check scope, and companion visual reference package/map inventory without turning external URLs, cross-file HTML anchors, or browser screenshots into required checks.
- Configuration docs now distinguish concrete initializer defaults, nil Tom Select data-value omissions, and bundled locale-aware render-text fallbacks before the Quick reference tables.
- Shared metadata navigation docs now have a focused drift guard for README/public API entry links, current public API / host-app-owned source boundaries, and future registry proposals.
- Native affix contract smoke now runs through the maintained JavaScript check runner, keeping package-root helper evidence on the same `npm run check:js` path without changing native wrapper behavior.

#### Packaging and bundled locales

- Bundled Tom Select locale YAML files are now included in the gem package so the existing I18n-backed default `no_results_text`, `loading_text`, and `create_text` copy remains available to host apps without changing locale wording or JavaScript localization ownership.

#### Remote request lifecycle and events

- Tom Select selected items now render with compact token markup instead of reusing rich dropdown option blocks, so selected values keep their label-focused chip layout while dropdown options retain descriptions and badges.
- Tom Select failure events now share a consistent detail shape with `operation`, request context, `response`, `payload`, and `status` across remote search, selected preload, and create failures, and include `surface` when `error_surface: true` is enabled.
- Remote search, selected preload, and create-on-the-fly now document that aborted requests, disconnect-time aborts, and stale responses do not dispatch success or failure events; failure events remain limited to current request errors.
- Remote option rendering now falls back to the configured value field for the visible label when the configured label field is missing or blank; this is display-only and does not change submitted values, endpoint payloads, authorization, or request lifecycle behavior.

#### Token and Ransack suggestion metadata

- `RansackSuggestions` now preserves predicate aliases and duplicates generated value metadata, including custom output field payloads, so downstream mutation does not alter source field configuration.

#### Table metadata collection

- `rfk_table_filters` and `rfk_table_cell_editors` now render an empty safe string for nil table metadata inputs.
- `TableMetadata` now duplicates collected metadata hashes and nested options hashes from hash, hash-like metadata, and hash-like column inputs so downstream mutation does not alter original column definitions.
- `TableMetadata` now validates hash-like columns and hash-like metadata objects by requiring `to_hash` to return a Hash-like object.
- `TableMetadata` now reads struct-like and object column metadata through safe public metadata readers, preferring explicit metadata readers over `to_hash` when both protocols are exposed while avoiding private readers or unrelated `Enumerable#filter` calls.
- `TableMetadata` now keeps single hash, hash-like, and object column definitions intact instead of expanding them through `Hash#to_a`, `to_a`, or table-like single-column returns.
- `TableMetadata` now collects metadata from table-like objects whose `columns` reader returns one column or enumerable column lists while preserving a single hash as one column definition.
- `TableMetadata` now treats explicit `false` object, hash, and hash-like column metadata values as disabled metadata instead of falling through to alias readers or alias keys.
- `TableMetadata` now treats table-like objects with `nil` columns as empty metadata.

#### Table input and renderer immutability

- `TableFilterInput.known_type?` and `TableCellInput.known_type?` now return `false` for nil or blank field type values.
- `TableFilterInput.known_types` and `TableCellInput.known_types` now return duplicated arrays so callers cannot mutate the internal type list.
- `TableFilterInput#field_name` and `TableCellInput#field_name` now return duplicated strings so callers cannot mutate metadata object internals.
- `TableFilterInput#options` and `TableCellInput#options` now return duplicated hashes so callers cannot mutate metadata object internals.
- `TableRenderer.field_helpers` now returns a duplicated hash so callers cannot mutate the internal helper mapping.
- `TableRenderer.register_field_helper` now normalizes field type and helper name values before registration and rejects nil or blank values.
- `TableRenderer` now duplicates metadata options and hash-like options objects before returning call specs so downstream mutation does not alter the original metadata.

#### TableRenderer input normalization and errors

- `TableRenderer` now accepts valid hash-like metadata objects directly, rejects non Hash-like metadata, and validates hash-like metadata returned from `to_hash`.
- `TableRenderer` now normalizes field type and method strings for call specs and helper lookups.
- `TableRenderer` now preserves render result order for filter and cell editor batches.
- `TableRenderer` now preserves single hash-like metadata objects in batch APIs even when they implement `to_a`.
- `TableRenderer` now normalizes batch inputs so nil becomes an empty list, a single hash becomes one metadata entry, arrays are preserved, enumerables are expanded, and other single objects are treated as one entry.
- `TableRenderer` now reports missing or blank metadata `field_type` values with a dedicated error message.
- `TableRenderer` now normalizes metadata `method` values and treats blank methods as missing before rendering.
- `TableRenderer` now defaults missing metadata `options` to an empty hash and rejects non-hash options.

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
