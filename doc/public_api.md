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
| FormBuilder helpers | Tom Select-backed helpers, table metadata helpers, and native wrapper helpers | [`field_helpers.md`](field_helpers.md), [`select_migration.md`](select_migration.md) |
| Controller helpers | Remote option JSON, selected preload, create-on-the-fly, and token suggestion endpoint helpers | [`controller_helpers.md`](controller_helpers.md) |
| Token suggestions | Builder objects for token suggestion metadata and Ransack-compatible suggestion metadata | [`token_suggestions.md`](token_suggestions.md), [`ransack_suggestions.md`](ransack_suggestions.md) |
| Table metadata | Metadata objects, collector methods, call-spec helpers, and renderer helpers for optional table integrations | [`table_adapters.md`](table_adapters.md) |
| JavaScript package root | `TomSelectController` plus read-only rendered-field contract helpers | [JavaScript exports](#javascript-exports) |
| Stimulus integration | FormBuilder-generated values, lifecycle expectations, and controller events | [`events.md`](events.md) |

Use the sections below for the exact public names. The linked docs provide examples and host-app responsibility boundaries; this file is the compact public API index.

## Ruby entrypoint

```ruby
require "rails_fields_kit"
```

## Configuration

```ruby
RailsFieldsKit.configure do |config|
  config.default_query_param = "q"
end
```

Public configuration methods:

- `RailsFieldsKit.configuration`
- `RailsFieldsKit.configure`
- `RailsFieldsKit.reset_configuration!`

Configuration attributes are documented in [`configuration.md`](configuration.md).

## FormBuilder helpers

Tom Select-backed helpers:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
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
- `rfk_money_field`
- `rfk_percent_field`
- `rfk_email_field`
- `rfk_url_field`
- `rfk_phone_field`
- `rfk_search_field`

See [`field_helpers.md`](field_helpers.md) for details.
See [`select_migration.md`](select_migration.md) for a practical server-rendered `collection_select` to `rfk_select` migration pattern.

Current Ransack-oriented public surface stays metadata-first. `rfk_token_search` is a general token-search UI helper, while `rfk_table_filters(columns)` renders metadata that was already prepared elsewhere. Helper-level DSL examples such as `rfk_token_search ..., adapter: :ransack` or `rfk_table_filters @table_preferences, adapter: :ransack` are not current public APIs in the 0.1.x contract.

Tom Select-backed `rfk_*` helpers also support opt-in `error_surface:` and `error_surface_html:` options for fields that should expose a stable nearby placeholder on request failures. When enabled, request-failure events described in [`events.md`](events.md) can include that placeholder as `detail.surface`, while visible error copy and retry UI remain host-app responsibility.

Tom Select-backed helpers also support field-level `allow_clear: true` for fields that should expose Tom Select's `clear_button` affordance. Rails Fields Kit adds `clear_button` to that field's effective plugin list, while Tom Select installation, plugin-specific assets, clear affordance styling, and empty-state wording remain host-app or Rails select-option responsibility. Explicit `plugins:` values still replace initializer defaults for the field; use [`field_helpers.md`](field_helpers.md) for the helper-level examples and override notes.

`rfk_table_filters` and `rfk_table_cell_editors` are the direct FormBuilder rendering path. They collect table metadata and return safe-buffer helper output for ordinary Rails views. `TableMetadata.filter_calls` / `cell_editor_calls` and `TableRenderer.filter_call` / `cell_editor_call` are the call-spec path for table integrations that want to inspect or rearrange helper, method, and options before rendering. The batch convenience APIs `TableMetadata.render_filters` / `render_cell_editors` and `TableRenderer.render_filters` / `render_cell_editors` stay in that renderer lane and return ordered render result arrays rather than redefining the helper-level safe-buffer contract.

## Controller helpers

Include `RailsFieldsKit::Searchable` in controllers that serve remote option JSON.

Public class methods:

- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`
- `rfk_token_suggestions_with`

`rfk_search_with`, `rfk_find_with`, and `rfk_create_with` support custom `action:` names. `rfk_token_suggestions_with` provides lightweight token suggestion endpoints for `rfk_token_search` without taking over query parsing or result filtering.

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

Public metadata methods are grouped by class so reviewers can scan the contract without reading one long mixed list.

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
- `RailsFieldsKit::TableFilterInput.money_field`
- `RailsFieldsKit::TableFilterInput.percent_field`
- `RailsFieldsKit::TableFilterInput.email_field`
- `RailsFieldsKit::TableFilterInput.url_field`
- `RailsFieldsKit::TableFilterInput.phone_field`
- `RailsFieldsKit::TableFilterInput.search_field`
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
- `RailsFieldsKit::TableCellInput.money_field`
- `RailsFieldsKit::TableCellInput.percent_field`
- `RailsFieldsKit::TableCellInput.email_field`
- `RailsFieldsKit::TableCellInput.url_field`
- `RailsFieldsKit::TableCellInput.phone_field`
- `RailsFieldsKit::TableCellInput.search_field`
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
- `RailsFieldsKit::TableRenderer.helper_for`
- `RailsFieldsKit::TableRenderer.registered_field_type?`
- `RailsFieldsKit::TableRenderer.register_field_helper`
- `RailsFieldsKit::TableRenderer.reset_field_helpers!`
- `RailsFieldsKit::TableRenderer.filter_call`
- `RailsFieldsKit::TableRenderer.filter_calls`
- `RailsFieldsKit::TableRenderer.cell_editor_call`
- `RailsFieldsKit::TableRenderer.cell_editor_calls`
- `RailsFieldsKit::TableRenderer.render_filter`
- `RailsFieldsKit::TableRenderer.render_filters`
- `RailsFieldsKit::TableRenderer.render_cell_editor`
- `RailsFieldsKit::TableRenderer.render_cell_editors`

The returned metadata hashes use `type: "rails_fields_kit"`, a string `field_type`, an optional `method`, and an `options` hash. `to_h` and `to_hash` return the same metadata hash as `to_table_filter` or `to_table_cell_editor`.

`TableFilterInput.ransack_filter` is the current public entrypoint when table-oriented code wants Ransack-compatible token-search metadata. `TableMetadata` can collect metadata from Hash columns, hash-like columns that respond to `to_hash`, object columns with public metadata readers, enumerable column lists, and table-like objects that respond to `columns`. Explicit `false` filter/editor metadata disables that slot instead of falling through to alias keys or readers. `TableRenderer` can turn collected metadata into FormBuilder call specs or dispatch it to a form builder. See [`table_adapters.md`](table_adapters.md) for the protocol and Rails Table Preferences integration notes.

## JavaScript exports

Package-root imports use the documented `rails_fields_kit` entrypoint. The current exports are split between the Stimulus controller and read-only rendered-field contract readers.

### Current package-root exports

| Export | Kind | Responsibility boundary |
| --- | --- | --- |
| `TomSelectController` | Stimulus controller | Registers Rails Fields Kit's Tom Select-backed field behavior on the rendered element. Host apps still own Stimulus boot, Tom Select installation, endpoint behavior, authorization, query parsing, visible feedback copy, and retry UI. |
| `tomSelectTextOverrideContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered text override data attributes and returns `noResultsText`, `loadingText`, and `createText`, or `null` when the element does not look like a matching Rails Fields Kit field. It does not execute requests, resolve locales, mutate Tom Select, or own visible feedback. |
| `nativeFieldAccessibilityContract(element)` | rendered-field contract reader | Reads Rails Fields Kit-rendered native input, select, or textarea accessibility wiring and returns `describedByIds`, `describedByElements`, `labelElement`, `hintElement`, `errorElement`, and `wrapperElement`, or `null` for non-element or non-native-field inputs. It does not generate ids, mutate aria attributes, create validation messages, move focus, or own visible feedback. |

### Import patterns

Package-root imports use the documented entrypoint:

```js
import {
  TomSelectController,
  nativeFieldAccessibilityContract,
  tomSelectTextOverrideContract
} from "rails_fields_kit"

const accessibilityContract = nativeFieldAccessibilityContract(inputElement)
const copyContract = tomSelectTextOverrideContract(fieldElement)
```

Direct controller import is also supported when the host app wants only the controller file:

```js
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

### Contract reader boundary

Rendered-field contract helpers stay read-only. They inspect data attributes and element references that Rails Fields Kit already rendered and return plain objects for host-app scripts that need to inspect configuration without reaching into the Stimulus controller instance or duplicating wrapper traversal.

For native fields, `labelElement` first uses the rendered `label[for]` association and then falls back to the nearest `.rfk-field` wrapper label. Missing labels return `null`.

Future package-root helpers should follow the same boundary: read the rendered Rails Fields Kit contract or configuration from an element, but do not take over request lifecycles, locale resolution, visible feedback, query parsing, retry UI, validation feedback, or other application-specific behavior. Proposal or open-PR helper names are not current public API until they are merged and listed in the table above.

## Stimulus values

The Tom Select controller reads data values generated by the FormBuilder helpers. Publicly documented options include remote URLs, request parameter names, JSON field names, selected preload settings, create-on-the-fly settings, rendering labels, plugin lists, `max_options`, `max_items`, `load_throttle`, and `delimiter`.

Remote endpoint extensions:

- `query_params:` adds fixed query parameters to search requests.
- `selected_query_params:` adds fixed query parameters to selected preload requests.
- `create_params:` adds fixed JSON fields to create requests.
- `error_surface:` adds a generated placeholder id so request-failure events can expose `detail.surface` for host-app feedback.

`error_surface_html:` customizes the generated placeholder element, but it does not change the event names or move visible feedback responsibility into the gem.

## Stimulus lifecycle contract

Tom Select-backed `rfk_*` fields initialize from the controller's Stimulus `connect()` lifecycle on the rendered element. In Turbo-enabled Rails apps, replacing or revisiting a server-rendered form is expected to reconnect the controller without a separate host-app `turbo:load` reinitializer for normal Rails Fields Kit usage.

## Stimulus events

Events dispatched by the Tom Select controller are part of the public integration surface.

See [`events.md`](events.md).

## Internal implementation details

These are not intended as stable public APIs:

- private FormBuilder helper methods prefixed with `rfk_` but defined under `private`
- internal normalization methods in `RailsFieldsKit::Searchable`
- exact HTML structure of rich option rendering beyond documented classes/data and event payloads
- generated documentation wording

## Compatibility policy

For the 0.1.x series, small API adjustments may still happen, but documented public APIs should not be removed without a changelog entry.