# Product Profile

## What this repository is

Rails Fields Kit is a Ruby gem that gives Rails applications a focused set of form helpers for inputs that are awkward with native HTML alone. Its current center of gravity is Tom Select-backed searchable selects, editable comboboxes, tag inputs, token search inputs, and table-oriented metadata helpers.

## Who it serves

- maintainers of the gem
- Rails application developers integrating searchable form fields
- host apps that want optional metadata bridges to table-oriented gems

## What it should do well

- wrap Tom Select in Rails-friendly helpers for naming, redisplay, validation, and accessibility
- support remote search, selected preload, and create-on-the-fly workflows
- expose stable integration points for controller helpers, token suggestion builders, JavaScript rendered-contract helpers, and table metadata
- stay easy to adopt from ordinary Rails forms without taking over the whole frontend stack

## Responsibility boundary

Rails Fields Kit is not a query engine, authorization layer, or table preference persistence layer.

Host applications remain responsible for:

- installing Tom Select in their chosen JavaScript toolchain
- parsing submitted token search text
- building `params[:q]` or equivalent search params
- authorization, scoping, pagination, and result execution
- app-specific success and error UI copy

## Current public surface

- FormBuilder helpers such as `rfk_select`, `rfk_combobox`, `rfk_tags`, `rfk_token_search`, `rfk_table_filters`, and `rfk_table_cell_editors`
- controller helpers under `RailsFieldsKit::Searchable`
- token suggestion builders including `RailsFieldsKit::TokenSuggestions.build` and `RailsFieldsKit::RansackSuggestions.build`
- table metadata objects including `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer`
- package-root JavaScript exports including `TomSelectController` and rendered-field contract helpers documented in `doc/public_api.md`
- Stimulus events dispatched by `rails-fields-kit--tom-select`

## Current non-goals

- hiding all Tom Select configuration
- deciding application-specific search semantics
- owning Ransack execution
- choosing the host app's bundler or importmap strategy
- replacing dedicated table or search gems

## Key docs

- `README.md`: public entrypoint and maintained docs map
- `CHANGELOG.md`: released and unreleased user-visible changes, plus the current release-prep baseline
- `AGENTS.md`: repo-specific source-of-truth order, docs-sync expectations, and release-facing review inventory
- `doc/setup.md`: maintained setup walkthrough
- `lib/generators/rails_fields_kit/templates/rails_fields_kit_setup.md`: generated host-app checklist that should stay pointed back to the maintained docs
- `doc/field_helpers.md` and `doc/controller_helpers.md`: public helper references
- `doc/tom_select_visual_reference.html` and `doc/native_field_visual_reference.html`: static visual references for representative Tom Select-backed and native helper states
- `doc/tom_select_text_override_visual_reference.html`: static visual reference for configured Tom Select text override copy states
- `doc/table_metadata_visual_reference.html`: static visual reference for representative table metadata filter and editor lanes
- `doc/token_search_saved_search_visual_reference.html`: static visual reference for saved-search token suggestion states
- `doc/configuration.md`: initializer defaults and override precedence
- `doc/select_migration.md`: practical `collection_select` to `rfk_select` migration pattern
- `doc/token_suggestions.md` and `doc/ransack_suggestions.md`: token-search suggestion surfaces and host-app responsibility boundary
- `doc/table_adapters.md`: table metadata bridge
- `doc/public_api.md`: intended stable API for 0.1.x
- `doc/events.md`: Stimulus event contract
- `doc/development.md`: local checks
- `doc/release.md`, `doc/final_release_checklist.md`, `doc/selected_preload_release_gate.md`, `doc/sample_app_checklist.md`, `doc/sample_app_results.md`, and `doc/release_notes_0_1_1.md`: release-facing maintainer docs and current next-release draft

## Source-of-truth reminder

Use current code first, then current docs and changelog. Treat `ROADMAP.md` as direction-setting material rather than implemented contract.
