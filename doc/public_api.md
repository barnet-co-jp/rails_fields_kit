# Rails Fields Kit Public API

This document summarizes the public API intended to be stable for the 0.1.x series.

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

Public metadata methods:

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
- `RailsFieldsKit::TableCellInput.token_search`
- `RailsFieldsKit::TableCellInput#to_h`
- `RailsFieldsKit::TableCellInput#to_hash`
- `RailsFieldsKit::TableCellInput#to_table_cell_editor`
- `RailsFieldsKit::TableMetadata.filters`
- `RailsFieldsKit::TableMetadata.cell_editors`
- `RailsFieldsKit::TableMetadata.filter_calls`
- `RailsFieldsKit::TableMetadata.cell_editor_calls`
- `RailsFieldsKit::TableMetadata.render_filters`
- `RailsFieldsKit::TableMetadata.render_cell_editors`
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

The package exposes the Tom Select Stimulus controller from the JavaScript entrypoint:

```js
import { TomSelectController } from "rails_fields_kit"
```

Direct import is also supported:

```js
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

## Stimulus values

The Tom Select controller reads data values generated by the FormBuilder helpers. Publicly documented options include remote URLs, request parameter names, JSON field names, selected preload settings, create-on-the-fly settings, rendering labels, plugin lists, `max_options`, `max_items`, `load_throttle`, and `delimiter`.

Remote endpoint extensions:

- `query_params:` adds fixed query parameters to search requests.
- `selected_query_params:` adds fixed selected preload query parameters.
- `create_params:` adds fixed JSON fields to create requests.

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
