# Rails Fields Kit Public API

This document summarizes the public API intended to be stable for the 0.1.x series.

## Quick navigation

- [Surface summary](#surface-summary)
- [Ruby entrypoint](#ruby-entrypoint)
- [Configuration](#configuration)
- [FormBuilder helpers](#formbuilder-helpers)
- [Controller helpers](#controller-helpers)
- [Token suggestion builders](#token-suggestion-builders)
- [Table metadata adapters](#table-metadata-adapters)
- [JavaScript exports](#javascript-exports)
- [Stimulus values](#stimulus-values)
- [Stimulus lifecycle contract](#stimulus-lifecycle-contract)
- [Stimulus events](#stimulus-events)
- [Internal implementation details](#internal-implementation-details)
- [Compatibility policy](#compatibility-policy)

## Surface summary

| Area | Current public surface | Detailed docs |
| --- | --- | --- |
| Ruby setup | `require "rails_fields_kit"`, `RailsFieldsKit.configure`, configuration accessors | [`configuration.md`](configuration.md) |
| FormBuilder helpers | Tom Select-backed helpers, table metadata helpers, and native wrapper helpers | [`field_helpers.md`](field_helpers.md), [`select_migration.md`](select_migration.md), [`enum_select.md`](enum_select.md), [`textarea_autosize.md`](textarea_autosize.md), [`range_field.md`](range_field.md), [`native_date_time_color_fields.md`](native_date_time_color_fields.md), [`password_field.md`](password_field.md), [`check_box.md`](check_box.md), [`radio_button.md`](radio_button.md), [`file_field.md`](file_field.md), [`native_numeric_fields.md`](native_numeric_fields.md), [`native_contact_fields.md`](native_contact_fields.md) |
| Controller helpers | Remote option JSON, selected preload, create-on-the-fly, and token suggestion endpoint helpers | [`controller_helpers.md`](controller_helpers.md) |
| Token suggestions | Builder objects for token suggestion metadata and Ransack-compatible suggestion metadata | [`token_suggestions.md`](token_suggestions.md), [`ransack_suggestions.md`](ransack_suggestions.md) |
| Table metadata | Metadata objects, collector methods, call-spec helpers, renderer helpers, and custom renderer registry mapping for optional table integrations | [`table_adapters.md`](table_adapters.md), [`table_group_html.md`](table_group_html.md) |
| JavaScript package root | `TomSelectController` plus read-only rendered-field contract helpers | [JavaScript exports](#javascript-exports) |
| Stimulus integration | FormBuilder-generated values, lifecycle expectations, and controller events | [`events.md`](events.md) |

Use the sections below for the exact public names. The linked docs provide examples and host-app responsibility boundaries; this file is the compact public API index.

When comparing token suggestions, Ransack-oriented suggestions, table metadata, and roadmap registry proposals, use [`shared_metadata_navigation.md`](shared_metadata_navigation.md) as the boundary map. It points back here for current public names and keeps host-app metadata patterns separate from future helper-level adapter or registry APIs.

## Ruby entrypoint

```ruby
require "rails_fields_kit"
```

## Configuration

```ruby
RailsFieldsKit.configure do |config|
  config.default_query_param = "q"
  config.default_allow_clear = false
end
```

Public configuration methods:

- `RailsFieldsKit.configuration`
- `RailsFieldsKit.configure`
- `RailsFieldsKit.reset_configuration!`

Configuration attributes are documented in [`configuration.md`](configuration.md). Tom Select interaction attributes include `default_allow_clear`, an app-wide semantic clear-button default that applies only when a helper omits field-level `allow_clear:`; use [`default_allow_clear.md`](default_allow_clear.md) for focused examples and non-goals.

## FormBuilder helpers

Tom Select-backed helpers:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_lookup`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- `rfk_token_search`

Table metadata helpers:

- `rfk_table_filters`
- `rfk_table_cell_editors`

Native input helpers:

- `rfk_text_field`
- `rfk_text_area`
- `rfk_number_field`
- `rfk_range_field`
- `rfk_money_field`
- `rfk_percent_field`
- `rfk_email_field`
- `rfk_url_field`
- `rfk_phone_field`
- `rfk_search_field`
- `rfk_password_field`
- `rfk_check_box`
- `rfk_radio_button`
- `rfk_file_field`
- `rfk_date_field`
- `rfk_time_field`
- `rfk_datetime_local_field`
- `rfk_color_field`

Native wrapper helpers keep the public helper inventory compact while routing family-specific behavior to the focused docs above:

- Attribute pass-through: Native wrapper helpers pass ordinary Rails/native input attributes such as `maxlength`, `minlength`, `pattern`, `required`, `autocomplete`, and `inputmode` to the rendered input through top-level field options or `html:`. Range, date, time, datetime-local, and color fields also pass native attributes such as `min`, `max`, and `step` through the same Rails/native input path.
- Rails-native contracts: checkbox fields pass checked and unchecked values through Rails' native `check_box` helper, while radio fields pass their `tag_value` and checked state through Rails' native `radio_button` helper. Collection checkbox and radio groups stay out of Rails Fields Kit scope.
- File uploads: file fields pass Rails file-input options such as `accept:`, `multiple:`, and `direct_upload:` through to Rails' native `file_field` helper without changing the submitted file parameter shape.
- Rails Fields Kit ownership: Rails Fields Kit owns the wrapper, hint, error, affix, and accessibility wiring around that input.
- Host-app responsibility: character counters, masking, browser validation-message policy, browser validation behavior, server-side validation rules, textarea autosize measurement, range live preview behavior, date/time parsing, timezone conversion, locale formatting, custom pickers, Turbo reconnect sizing, multipart form setup, Active Storage direct upload JavaScript, preview UI, upload progress UI, file size and MIME validation policy, storage configuration, virus scanning, production CSS, group-level radio validation UI, fieldset / legend generation, and manual-resize policy remain host-app responsibility.

See [`field_helpers.md`](field_helpers.md) for details.
See [`grouped_select.md`](grouped_select.md) for the current collection-backed `<optgroup>` boundary and the separation from remote workflows or future optgroup metadata work.
See [`textarea_autosize.md`](textarea_autosize.md) for the current `rfk_text_area` autosize boundary and host-app-owned enhancement guidance.
See [`range_field.md`](range_field.md) for the current `rfk_range_field` thin wrapper boundary and range-specific non-goals.
See [`native_date_time_color_fields.md`](native_date_time_color_fields.md) for the native date, time, datetime-local, and color wrapper boundary and native picker non-goals.
See [`password_field.md`](password_field.md) for the current `rfk_password_field` thin wrapper boundary and password-specific non-goals.
See [`check_box.md`](check_box.md) for the current `rfk_check_box` thin wrapper boundary and Rails checkbox contract non-goals.
See [`radio_button.md`](radio_button.md) for the current `rfk_radio_button` thin wrapper boundary and Rails radio value / checked-state / same-name group contract non-goals.
See [`file_field.md`](file_field.md) for the current `rfk_file_field` thin wrapper boundary and file-upload ownership non-goals.
See [`select_migration.md`](select_migration.md) for a practical server-rendered `collection_select` to `rfk_select` migration pattern.
See [`enum_select.md`](enum_select.md) for the `rfk_enum_select` explicit `enum:` hash boundary, including keys-as-submitted-values behavior and the non-goal boundary around arbitrary label/value DSLs or remote enum option lookup.
See [`collection_group_helpers.md`](collection_group_helpers.md) for the current non-API boundary around collection checkbox / radio groups, semantic `fieldset` / `legend`, group-level hint / error wiring, and host-app ownership of collection semantics.

Current Ransack-oriented public surface stays metadata-first. `rfk_token_search` is a general token-search UI helper, while `rfk_table_filters(columns)` renders metadata that was already prepared elsewhere. Helper-level DSL examples such as `rfk_token_search ..., adapter: :ransack` or `rfk_table_filters @table_preferences, adapter: :ransack` are not current public APIs in the 0.1.x contract.

Collection checkbox / radio group helpers are also not current public APIs. Host apps should keep using ordinary Rails collection helpers or host-app markup for group semantics until a future helper is merged and listed here. Future proposal names, open PR helper names, and single-control wrapper helpers must not be read as current collection group API.

Tom Select-backed `rfk_*` helpers also support opt-in `error_surface:` and `error_surface_html:` options for fields that should expose a stable nearby placeholder on request failures. When enabled, request-failure events described in [`events.md`](events.md) can include that placeholder as `detail.surface`, while visible error copy and retry UI remain host-app responsibility.

Tom Select-backed helpers also support field-level `allow_clear: true` for fields that should expose Tom Select's `clear_button` affordance. When `config.default_allow_clear = true`, the same semantic clear-button default applies app-wide only for helpers that omit `allow_clear:`; field-level `allow_clear: false` suppresses that semantic auto-add for one field. Rails Fields Kit adds `clear_button` to that field's effective plugin list, while Tom Select installation, plugin-specific assets, clear affordance styling, and empty-state wording remain host-app or Rails select-option responsibility. Explicit `plugins:` values still replace initializer defaults for the field, and raw `default_plugins` entries are not removed by `allow_clear: false`; use [`field_helpers.md`](field_helpers.md) for helper-level examples and [`default_allow_clear.md`](default_allow_clear.md) for app-wide default boundaries.

`rfk_table_filters` and `rfk_table_cell_editors` are the direct FormBuilder rendering path. They collect table metadata and return safe-buffer helper output for ordinary Rails views. `TableMetadata.filter_calls` / `cell_editor_calls` and `TableRenderer.filter_call` / `cell_editor_call` are the call-spec path for table integrations that want to inspect or rearrange helper, method, and options before rendering. The batch convenience APIs `TableMetadata.render_filters` / `render_cell_editors` and `TableRenderer.render_filters` / `render_cell_editors` stay in that renderer lane and return ordered render result arrays rather than redefining the helper-level safe-buffer contract.

`rfk_table_filters(columns, group_html: ...)` and `rfk_table_cell_editors(columns, group_html: ...)` can add attributes to one outer group wrapper around the joined helper output. `group_html:` is separate from field-level `wrapper_html:` and does not make Rails Fields Kit own table layout, query execution, persistence, or semantic `fieldset` / `legend` generation; use [`table_group_html.md`](table_group_html.md) for examples and the detailed boundary.

## Controller helpers

Include `RailsFieldsKit::Searchable` in controllers that serve remote option JSON.

Public class methods:

- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`
- `rfk_token_suggestions_with`

`rfk_search_with`, `rfk_find_with`, and `rfk_create_with` support custom `action:` names. `rfk_search_with` also supports `minimum_query_length:` when the endpoint itself should return empty options for blank or too-short queries while preserving the default blank-query behavior when the option is omitted. `rfk_token_suggestions_with` provides lightweight token suggestion endpoints for `rfk_token_search` without taking over query parsing or result filtering.

See [`controller_helpers.md`](controller_helpers.md) for details.

## Token suggestion builders

`RailsFieldsKit::TokenSuggestions.build` creates option JSON for token search suggestion endpoints. It can combine operator, field, predicate, value, and saved-search suggestions while leaving token parsing and search execution to the host application.

`RailsFieldsKit::RansackSuggestions.build` creates Ransack-compatible token suggestion metadata without requiring the `ransack` gem or executing a Ransack search.

See [`token_suggestions.md`](token_suggestions.md) and [`ransack_suggestions.md`](ransack_suggestions.md) for details.

## Table metadata adapters

Rails Fields Kit exposes small metadata objects for table-oriented gems that want optional Rails Fields Kit integration without a hard dependency.

Public classes:

- `RailsFieldsKit::TableFilterInput`
- `RailsFieldsKit::TableCellInput`
- `RailsFieldsKit::TableRenderer`
- `RailsFieldsKit::TableMetadata`

Class responsibilities:

| Class | Public role | Notes |
| --- | --- | --- |
| `RailsFieldsKit::TableFilterInput` | Describes a filter UI that can later be rendered with Rails Fields Kit helpers. | Includes factory methods for built-in field types and `ransack_filter` for Ransack-compatible token-search metadata. |
| `RailsFieldsKit::TableCellInput` | Describes an editable cell UI that can later be rendered with Rails Fields Kit helpers. | Mirrors the built-in field type family used by filter metadata, without the Ransack-specific filter entrypoint. |
| `RailsFieldsKit::TableMetadata` | Collects filter and cell editor metadata from columns or table-like objects. | Can return metadata hashes, FormBuilder call specs, or ordered render result arrays. |
| `RailsFieldsKit::TableRenderer` | Maps metadata into FormBuilder helper calls or render results. | Owns the field type registry and custom helper mapping for table integrations. |

Public metadata methods are grouped by class so reviewers can scan the contract without reading one long mixed list. Use [`table_adapters.md`](table_adapters.md) as the source of truth for examples, custom renderer registry setup, and the difference between built-in factory types and custom renderable mappings.

Focused native metadata guides stay behind that table adapters route, but can be useful when reviewing one built-in field family at a time: use [`table_range_field_metadata.md`](table_range_field_metadata.md) for range metadata, [`table_check_box_metadata.md`](table_check_box_metadata.md) for checkbox metadata, [`table_radio_button_metadata.md`](table_radio_button_metadata.md) for radio button filter and cell-editor metadata, [`table_date_time_color_metadata.md`](table_date_time_color_metadata.md) for date, time, datetime-local, and color metadata, and [`table_file_field_metadata.md`](table_file_field_metadata.md) for file cell-editor metadata. These guides do not add range-pair query semantics, boolean query policy, radio group generation, file upload execution, table persistence, or production styling to Rails Fields Kit responsibility. The date/time/color metadata route also keeps browser-native picker policy, timezone or locale formatting, masking, and custom picker UI outside Rails Fields Kit ownership.

### TableFilterInput methods

- `RailsFieldsKit::TableFilterInput.known_types`
- `RailsFieldsKit::TableFilterInput.known_type?`
- `RailsFieldsKit::TableFilterInput.from_type`
- `RailsFieldsKit::TableFilterInput.select`
- `RailsFieldsKit::TableFilterInput.combobox`
- `RailsFieldsKit::TableFilterInput.autocomplete`
- `RailsFieldsKit::TableFilterInput.tags`
- `RailsFieldsKit::TableFilterInput.multi_select`
- `RailsFieldsKit::TableFilterInput.grouped_select`
- `RailsFieldsKit::TableFilterInput.enum_select`
- `RailsFieldsKit::TableFilterInput.text_field`
- `RailsFieldsKit::TableFilterInput.text_area`
- `RailsFieldsKit::TableFilterInput.number_field`
- `RailsFieldsKit::TableFilterInput.range_field`
- `RailsFieldsKit::TableFilterInput.date_field`
- `RailsFieldsKit::TableFilterInput.time_field`
- `RailsFieldsKit::TableFilterInput.datetime_local_field`
- `RailsFieldsKit::TableFilterInput.color_field`
- `RailsFieldsKit::TableFilterInput.money_field`
- `RailsFieldsKit::TableFilterInput.percent_field`
- `RailsFieldsKit::TableFilterInput.email_field`
- `RailsFieldsKit::TableFilterInput.url_field`
- `RailsFieldsKit::TableFilterInput.phone_field`
- `RailsFieldsKit::TableFilterInput.search_field`
- `RailsFieldsKit::TableFilterInput.password_field`
- `RailsFieldsKit::TableFilterInput.check_box`
- `RailsFieldsKit::TableFilterInput.radio_button`
- `RailsFieldsKit::TableFilterInput.token_search`
- `RailsFieldsKit::TableFilterInput.ransack_filter`
- `RailsFieldsKit::TableFilterInput#to_h`
- `RailsFieldsKit::TableFilterInput#to_hash`
- `RailsFieldsKit::TableFilterInput#to_table_filter`

### TableCellInput methods

- `RailsFieldsKit::TableCellInput.known_types`
- `RailsFieldsKit::TableCellInput.known_type?`
- `RailsFieldsKit::TableCellInput.from_type`
- `RailsFieldsKit::TableCellInput.select`
- `RailsFieldsKit::TableCellInput.combobox`
- `RailsFieldsKit::TableCellInput.autocomplete`
- `RailsFieldsKit::TableCellInput.tags`
- `RailsFieldsKit::TableCellInput.multi_select`
- `RailsFieldsKit::TableCellInput.grouped_select`
- `RailsFieldsKit::TableCellInput.enum_select`
- `RailsFieldsKit::TableCellInput.text_field`
- `RailsFieldsKit::TableCellInput.text_area`
- `RailsFieldsKit::TableCellInput.number_field`
- `RailsFieldsKit::TableCellInput.range_field`
- `RailsFieldsKit::TableCellInput.date_field`
- `RailsFieldsKit::TableCellInput.time_field`
- `RailsFieldsKit::TableCellInput.datetime_local_field`
- `RailsFieldsKit::TableCellInput.color_field`
- `RailsFieldsKit::TableCellInput.money_field`
- `RailsFieldsKit::TableCellInput.percent_field`
- `RailsFieldsKit::TableCellInput.email_field`
- `RailsFieldsKit::TableCellInput.url_field`
- `RailsFieldsKit::TableCellInput.phone_field`
- `RailsFieldsKit::TableCellInput.search_field`
- `RailsFieldsKit::TableCellInput.password_field`
- `RailsFieldsKit::TableCellInput.check_box`
- `RailsFieldsKit::TableCellInput.radio_button`
- `RailsFieldsKit::TableCellInput.file_field`
- `RailsFieldsKit::TableCellInput.token_search`
- `RailsFieldsKit::TableCellInput#to_h`
- `RailsFieldsKit::TableCellInput#to_hash`
- `RailsFieldsKit::TableCellInput#to_table_cell_editor`

### TableMetadata methods

- `RailsFieldsKit::TableMetadata.filters`
- `RailsFieldsKit::TableMetadata.cell_editors`
- `RailsFieldsKit::TableMetadata.filter_calls`
- `RailsFieldsKit::TableMetadata.cell_editor_calls`
- `RailsFieldsKit::TableMetadata.render_filters`
- `RailsFieldsKit::TableMetadata.render_cell_editors`

### TableRenderer methods

- `RailsFieldsKit::TableRenderer.field_helpers`
- `RailsFieldsKit::TableRenderer.registered_field_types`
- `RailsFieldsKit::TableRenderer.helper_for`
- `RailsFieldsKit::TableRenderer.registered_field_type?`
- `RailsFieldsKit::TableRenderer.register_field_helper`
- `RailsFieldsKit::TableRenderer.unregister_field_helper`
- `RailsFieldsKit::TableRenderer.with_field_helpers`
- `RailsFieldsKit::TableRenderer.reset_field_helpers!`
- `RailsFieldsKit::TableRenderer.filter_call`
- `RailsFieldsKit::TableRenderer.filter_calls`
- `RailsFieldsKit::TableRenderer.cell_editor_call`
- `RailsFieldsKit::TableRenderer.cell_editor_calls`
- `RailsFieldsKit::TableRenderer.render_filter`
- `RailsFieldsKit::TableRenderer.render_filters`
- `RailsFieldsKit::TableRenderer.render_cell_editor`
- `RailsFieldsKit::TableRenderer.render_cell_editors`

Use `TableRenderer.registered_field_types` when an integration needs a mutation-safe list of renderable field type names, including custom mappings registered with `TableRenderer.register_field_helper`, without exposing the helper method names. `TableFilterInput.known_types` and `TableCellInput.known_types` remain limited to the built-in factory family.

The returned metadata hashes use `type: "rails_fields_kit"`, a string `field_type`, an optional `method`, and an `options` hash. `to_h` and `to_hash` return the same metadata hash as `to_table_filter` or `to_table_cell_editor`.

`TableFilterInput.ransack_filter` is the current public entrypoint when table-oriented code wants Ransack-compatible token-search metadata. `TableMetadata` can collect metadata from Hash columns, hash-like columns that respond to `to_hash`, object columns with public metadata readers, enumerable column lists, and table-like objects that respond to `columns`. Explicit `false` filter/editor metadata disables that slot instead of falling through to alias keys or readers. `TableRenderer` can turn collected metadata into FormBuilder call specs or dispatch it to a form builder. See [`table_adapters.md`](table_adapters.md) for the protocol, custom registry examples, and Rails Table Preferences integration notes.

`TableRenderer.unregister_field_helper(field_type)` removes a custom-only renderer mapping from the current registry. If a built-in field type was temporarily overridden with `register_field_helper`, unregistering that built-in type restores the default helper instead of making the built-in type unknown. Use `with_field_helpers(custom_field: :custom_table_field) { ... }` when a test or integration needs scoped renderer overrides that restore the exact previous registry snapshot after the block, including custom-only mappings, built-in overrides, exception paths, and the block return value. Use `reset_field_helpers!` when a test or integration needs to discard all custom mappings at once. The registry APIs do not change `TableFilterInput.known_types`, `TableCellInput.known_types`, table preference persistence, UI generation, or authorization policy.

## JavaScript exports

Package-root imports use the documented `rails_fields_kit` entrypoint. The current exports are split between the Stimulus controller and read-only rendered-field contract readers.

`package.json` also publishes TypeScript declaration metadata for the package root and direct controller entrypoint through its `types` fields. Treat those `.d.ts` files as package metadata and editor assistance for the documented runtime exports below; they do not add a separate runtime API, expose Tom Select internals, or define a host-app `tsconfig` policy. Use [`typescript_declaration_release_evidence.md`](typescript_declaration_release_evidence.md) when declaration visibility is in release or PR evidence scope.

### Current package-root exports

| Export | Kind | Responsibility boundary |
| --- | --- | --- |
| `TomSelectController` | Stimulus controller | Registers Rails Fields Kit's Tom Select-backed field behavior on the rendered element. Host apps still own Stimulus boot, Tom Select installation, endpoint behavior, authorization, query parsing, visible feedback copy, and retry UI. |
| `tomSelectTextOverrideContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered text override data attributes and returns `noResultsText`, `loadingText`, and `createText`, or `null` when the element does not look like a matching Rails Fields Kit field. It does not execute requests, resolve locales, mutate Tom Select, or own visible feedback. |
| `tomSelectPluginContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered Tom Select plugin data and returns `plugins`, `hasClearButton`, and `hasRemoveButton`, or `null` when the element does not look like a matching Rails Fields Kit field. It does not install plugin assets, expose Tom Select plugin objects, mutate selections, style clear/remove controls, or own empty-state behavior. |
| `tomSelectSelectionContract(element)` | rendered-field contract reader | Reads an initialized Rails Fields Kit Tom Select-backed field and returns `{ values }` using the same current-value shape as forwarded interaction events, or `null` when the element is not a matching initialized field. It does not mutate Tom Select, expose the controller instance, execute requests, change hidden fields, or own validation feedback. |
| `tomSelectRequestContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered Tom Select request data attributes and returns the controller identifier, remote search / selected preload / create endpoint flags, URL values, request parameter names, remote search `queryParams`, create `createParams`, `minLength`, and `errorSurfaceId`, or `null` when the element is not a Rails Fields Kit Tom Select-backed field. It does not execute requests, parse query strings, mutate Tom Select, authorize endpoints, retry requests, or own visible feedback. |
| `tomSelectFieldKindContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered Tom Select helper-lane kind data and returns the controller identifier and `kind`, or `null` when the element is not a matching Rails Fields Kit field or no kind is rendered. It does not redefine helper taxonomy, mutate Tom Select, execute requests, or own visible behavior. |
| `readRenderedErrorSurface(element)` | rendered-field contract reader | Resolves the opt-in request-failure placeholder element referenced by a rendered Tom Select-backed field's `errorSurfaceId`, or `null` when no placeholder is rendered or found. It does not create placeholders, reveal feedback, dispatch events, retry requests, or own visible copy. |
| `readRenderedTomSelectInteractionConfig(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered Tom Select interaction configuration attributes and returns `maxOptions`, `maxItems`, `loadThrottle`, `delimiter`, `dropdownParent`, `preload`, `openOnFocus`, `closeAfterSelect`, `hideSelected`, and `persist`, or `null` when the element is not a matching Rails Fields Kit field. It does not initialize Tom Select, mutate configuration, execute requests, own modal / drawer / portal layout, standardize z-index, or own interaction policy. |
| `readRenderedSelectedPreloadConfig(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered selected preload data attributes and returns `selectedUrl`, `selectedParam`, `selectedMultipleParam`, and `selectedQueryParams`, or `null` when no selected preload URL is rendered. It does not execute selected preload requests, authorize endpoints, mutate Tom Select, or own visible fallback or retry UI. |
| `readRenderedOptionPayloadMapping(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered Tom Select option payload mapping data and returns `valueField`, `labelField`, `searchFields`, `optionDescriptionField`, and `optionBadgeField`, or `null` when the element is not a rendered Tom Select-backed field. It does not execute requests, parse endpoint responses, mutate Tom Select, validate payloads, or own option rendering HTML. |
| `readRenderedTableFilterMetadata(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered table filter metadata attributes and returns `adapter`, `paramName`, and `fields`, or `null` when the element is not rendered from a table filter metadata lane. It does not execute Ransack, parse token queries, mutate Tom Select, or own table search behavior. |
| `nativeFieldAccessibilityContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered native input, select, or textarea accessibility wiring, affix elements, and returns `describedByIds`, `describedByElements`, `labelElement`, `hintElement`, `errorElement`, `prefixElement`, `suffixElement`, and `wrapperElement`, or `null` for non-element or non-native-field inputs. It does not generate ids, mutate aria attributes, create validation messages, format affix values, move focus, or own visible feedback. |
| `nativeFieldConstraintContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered native input, select, or textarea constraint attributes and returns `maxLength`, `minLength`, `pattern`, `autocomplete`, and `inputMode`, or `null` for non-element or non-native-field inputs. It does not mutate DOM attributes, run validation, own browser validation messages, masking, formatting, normalization, autocomplete policy, or visible feedback. |

### Import patterns

Package-root imports use the documented entrypoint:

```js
import {
  TomSelectController,
  nativeFieldAccessibilityContract,
  nativeFieldConstraintContract,
  readRenderedErrorSurface,
  readRenderedOptionPayloadMapping,
  readRenderedSelectedPreloadConfig,
  readRenderedTableFilterMetadata,
  readRenderedTomSelectInteractionConfig,
  tomSelectFieldKindContract,
  tomSelectPluginContract,
  tomSelectRequestContract,
  tomSelectSelectionContract,
  tomSelectTextOverrideContract
} from "rails_fields_kit"

const accessibilityContract = nativeFieldAccessibilityContract(inputElement)
const constraintContract = nativeFieldConstraintContract(inputElement)
const copyContract = tomSelectTextOverrideContract(fieldElement)
const errorSurface = readRenderedErrorSurface(fieldElement)
const fieldKindContract = tomSelectFieldKindContract(fieldElement)
const interactionConfig = readRenderedTomSelectInteractionConfig(fieldElement)
const optionPayloadMapping = readRenderedOptionPayloadMapping(fieldElement)
const pluginContract = tomSelectPluginContract(fieldElement)
const requestContract = tomSelectRequestContract(fieldElement)
const selectedPreloadConfig = readRenderedSelectedPreloadConfig(fieldElement)
const tableFilterMetadata = readRenderedTableFilterMetadata(fieldElement)
const selectionContract = tomSelectSelectionContract(fieldElement)
```

Direct controller import is also supported when the host app wants only the controller file:

```js
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

Direct helper subpath imports are supported only for helper files that `package.json` exports for host apps that intentionally pin or alias those files directly:

```js
import nativeFieldAccessibilityContract from "rails_fields_kit/native_field_accessibility_contract"
import nativeFieldConstraintContract from "rails_fields_kit/native_field_constraint_contract"
import readRenderedErrorSurface from "rails_fields_kit/read_rendered_error_surface"
import tomSelectPluginContract from "rails_fields_kit/tom_select_plugin_contract"
import tomSelectTextOverrideContract from "rails_fields_kit/tom_select_text_override_contract"
```

Prefer package-root imports for normal rendered-field contract helper use. Direct helper subpaths are setup and troubleshooting routes for explicit host-app pins or bundler aliases; they do not add helper names, return shapes, or responsibility boundaries beyond the package-root table above. The package-root-only readers `readRenderedTomSelectInteractionConfig`, `readRenderedOptionPayloadMapping`, and `readRenderedTableFilterMetadata` intentionally stay on the `rails_fields_kit` package-root route in this 0.1.x surface; do not infer direct subpaths for them unless a future issue explicitly expands the direct helper subpath policy. Keep the package-root table in this document as the helper inventory source of truth, and keep README, setup, and generated setup notes as routing guidance rather than mirrors of every helper export.

### Contract reader boundary

Rendered-field contract helpers stay read-only. They inspect data attributes, current Tom Select value state, and element references that Rails Fields Kit already rendered and return plain objects for host-app scripts that need to inspect configuration or selection state without reaching into the Stimulus controller instance, mutating Tom Select, or duplicating wrapper traversal.

For Tom Select plugin state, `tomSelectPluginContract(element)` reports the rendered effective plugin list and derived clear/remove flags. It does not confirm plugin asset loading, clear/remove affordance styling, or Tom Select plugin lifecycle behavior.

`tomSelectSelectionContract(element)` complements the forwarded interaction events in [`events.md`](events.md). Use events when the host app needs to react as selection changes; use the contract reader when a lightweight QA check or integration script needs to inspect the current rendered state on demand.

`tomSelectRequestContract(element)` reports only the rendered request-lane contract. For a matching Rails Fields Kit Tom Select-backed field it returns:

- `controller`: the Rails Fields Kit Tom Select Stimulus controller identifier.
- `hasRemoteSearch`, `hasSelectedPreload`, and `hasCreateEndpoint`: booleans derived from the rendered URL values.
- `url`, `selectedUrl`, and `createUrl`: rendered endpoint values, or `null` when that lane is absent.
- `queryParam`, `selectedParam`, `selectedMultipleParam`, and `createParam`: rendered request parameter names, using the controller defaults when the attributes are absent.
- `queryParams`: rendered fixed remote search params as a plain object, or `{}` when absent, invalid, or not an object.
- `createParams`: rendered fixed create params as a plain object, or `{}` when absent, invalid, or not an object.
- `minLength`: the rendered numeric minimum query length, defaulting to `0` when absent or not numeric.
- `errorSurfaceId`: the rendered request-failure placeholder id, or `null` when no error surface is rendered.

The helper does not execute `fetch`, inspect endpoint responses, parse query strings, or decide authorization / retry / visible feedback policy. Selected preload fixed params remain on `readRenderedSelectedPreloadConfig(element).selectedQueryParams`, so remote search, selected preload, and create fixed params keep distinct read-only surfaces.

`tomSelectFieldKindContract(element)` reports only the rendered helper-lane kind value for matching Rails Fields Kit Tom Select-backed fields. It returns the controller identifier and `kind`, or `null` for non-matching elements and fields without a rendered kind value. The helper does not define a new helper taxonomy, reinterpret grouped-select rendering, execute requests, mutate Tom Select, or own visible behavior.

`readRenderedErrorSurface(element)` uses the same rendered `errorSurfaceId` lane to find the opt-in placeholder element in the same document. It is useful before or outside a request-failure event, but it does not mutate feedback visibility or replace request-failure events' `detail.surface` contract.

`readRenderedTomSelectInteractionConfig(element)` reads the rendered Tom Select interaction configuration values that Rails Fields Kit put on the field, including numeric limits, boolean interaction toggles, delimiter, `dropdownParent`, and `persist`. Missing optional values are returned as `null`, while missing `persist` follows the controller fallback and returns `false`. It does not initialize Tom Select, change controller values, infer initializer defaults, mutate selections, execute requests, validate selector reachability, own modal / drawer / portal layout, standardize z-index, or own host-app interaction policy.

`readRenderedOptionPayloadMapping(element)` reports only the rendered option payload mapping config. It returns `valueField`, `labelField`, `searchFields`, `optionDescriptionField`, and `optionBadgeField`, applying controller defaults when attributes are absent. It does not execute endpoints, inspect response payloads, render options, mutate Tom Select, or decide endpoint validation / authorization policy.

For payload values consumed by the rendered Tom Select controller, `0` and `false` are present values: labels, descriptions, badges, and configured metadata rows render their string forms. `null`, `undefined`, and the empty string are absent values; an absent label follows the documented label fallback and becomes an empty label when fallback is disabled, while absent optional description, badge, and metadata rows are omitted. The same boundary preserves explicit `0` and `false` in selected preload values instead of treating them as blanks.

`readRenderedTableFilterMetadata(element)` reports only the rendered table-filter metadata contract. It is intended for fields rendered through `rfk_table_filters` / `TableRenderer.render_filter`, not direct `rfk_token_search` calls. The helper does not parse token strings, run Ransack, execute searches, or decide adapter support.

For native fields, `labelElement` first uses the rendered `label[for]` association and then falls back to the nearest `.rfk-field` wrapper label. Missing labels return `null`. `prefixElement` and `suffixElement` read the rendered affix elements inside the nearest `.rfk-field` wrapper when present and return `null` otherwise; they do not format values, parse currency or percent content, mutate markup, or change focus behavior.

`nativeFieldConstraintContract(element)` reports only native constraint attributes already rendered on Rails Fields Kit native input, select, or textarea elements. It returns string values from `getAttribute()` and `null` for absent attributes, so it preserves the HTML attribute contract rather than normalizing numeric limits or applying browser validation state. The helper does not mutate attributes, run validation, own validation messages, apply masking or formatting, normalize input, decide autocomplete policy, or create visible feedback.

Future package-root helpers should follow the same boundary: read the rendered Rails Fields Kit contract or configuration from an element, but do not take over request lifecycles, locale resolution, visible feedback, query parsing, retry UI, validation feedback, or other application-specific behavior. Proposal or open-PR helper names are not current public API until they are merged and listed in the table above.

## Stimulus values

The Tom Select controller reads data values generated by the FormBuilder helpers. Publicly documented options include remote URLs, request parameter names, JSON field names, selected preload settings, create-on-the-fly settings, rendering labels, plugin lists, `max_options`, `max_items`, `load_throttle`, `delimiter`, and `dropdown_parent`.

Rails Fields Kit also renders `data-rails-fields-kit--tom-select-kind-value` as a helper-lane signal for Tom Select-backed fields. Treat it as rendered configuration for Rails Fields Kit diagnostics and controller behavior rather than the preferred host-app integration surface: host apps should use documented helper options, events, and package-root contract readers when those surfaces exist. `rfk_grouped_select` currently renders through the collection-backed select lane, so its `kind` value matches that underlying lane instead of declaring a separate grouped-select taxonomy.

Remote endpoint extensions:

- `query_params:` adds fixed query parameters to search requests.
- `depends_on:` renders the dependency-selector map consumed as the `dependsOn` Stimulus value for remote-search requests.
- `clear_on_dependency_change:` renders the boolean `clearOnDependencyChange` Stimulus value; its default is false.
- `selected_query_params:` adds fixed query parameters to selected preload requests.
- `create_params:` adds fixed JSON fields to create requests.
- `error_surface:` adds a generated placeholder id so request-failure events can expose `detail.surface` for host-app feedback.

`error_surface_html:` customizes the generated placeholder element, but it does not change the event names or move visible feedback responsibility into the gem.

See [`dependent_query_params.md`](dependent_query_params.md) for merge and selection behavior; dependency values do not alter selected preload or define endpoint semantics, authorization, or business rules.

## Stimulus lifecycle contract

Tom Select-backed `rfk_*` fields initialize from the controller's Stimulus `connect()` lifecycle on the rendered element. In Turbo-enabled Rails apps, replacing or revisiting a server-rendered form is expected to reconnect the controller without a separate host-app `turbo:load` reinitializer for normal Rails Fields Kit usage.

## Stimulus events

Events dispatched by the Tom Select controller are part of the public integration surface.

The compact event family includes:

- remote search success / failure: `load`, `load-error`
- selected preload success / failure: `selected-load`, `selected-load-error`
- create-on-the-fly success / failure: `create`, `create-error`
- dependency changes: `dependency-change`
- forwarded interaction events: `change`, `item-add`, `item-remove`, `clear`

Use [`events.md`](events.md) as the source of truth for exact event names, payload shapes, request cancellation behavior, `detail.surface`, and host-app visible feedback responsibilities.

## Internal implementation details

These are not intended as stable public APIs:

- private FormBuilder helper methods prefixed with `rfk_` but defined under `private`
- internal normalization methods in `RailsFieldsKit::Searchable`
- exact HTML structure of rich option rendering beyond documented classes/data and event payloads
- generated documentation wording

## Compatibility policy

For the 0.1.x series, small API adjustments may still happen, but documented public APIs should not be removed without a changelog entry.
