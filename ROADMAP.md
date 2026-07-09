# Roadmap

Rails Fields Kit should grow as a focused kit for Rails form fields that remain awkward with native HTML inputs alone.

The core scope is not every possible form control. Native browser inputs such as date, time, color, email, URL, and number should stay native when they already provide a good default. Rails Fields Kit should focus on candidate-based text inputs, searchable selections, tag inputs, remote option loading, and adjacent Rails form integration work.

## Positioning

Rails Fields Kit is not just a combobox helper and is not a query engine.

It should provide modern Rails form fields for candidate-based text inputs, powered by Tom Select where Tom Select is the right fit, and wrapped in Rails-friendly helpers for naming, redisplay, validation errors, accessibility, and Hotwire-friendly behavior.

Query parsing, authorization, scoping, and Active Record relation construction usually belong in the host application, a search object, a controller concern, or a dedicated search gem. Rails Fields Kit may provide UI helpers and optional adapters that make those systems easier to use, but it should not own application-specific search semantics.

## Phase 1: Core Rails field helpers

These fields form the center of the gem.

- `rfk_combobox`
  - Editable combobox for choosing from candidates while still allowing free text or create-on-the-fly flows.
  - Should remain the main differentiator from plain autocomplete helpers.
- `rfk_autocomplete`
  - Text input with remote suggestions.
  - Best for keeping the submitted value as text while improving typing speed.
- `rfk_select`
  - Tom Select-backed wrapper around ordinary single selects.
  - Should stay thin when Tom Select already provides the behavior.
- `rfk_multi_select`
  - Multiple selection with Rails array parameter handling and clearing support.
- `rfk_tags`
  - Tag-style input for arrays of IDs or values, with optional remote search and create-on-the-fly support.
- `rfk_enum_select`
  - Rails enum-friendly select helper.
- Native wrappers
  - Text, text area, number, money, percent, email, URL, phone, search, range, password, checkbox, file, date, time, datetime-local, and color fields with consistent labels, hints, errors, prefixes, suffixes, and accessibility behavior.
  - These helpers are current public API; use `doc/public_api.md` as the exact helper inventory and the focused native wrapper docs for file, checkbox, numeric, contact/search, range, password, and date/time/color boundaries.
  - The package-root `nativeFieldAccessibilityContract(element)` helper can read their rendered accessibility wiring, but Rails Fields Kit still leaves validation copy, focus management, checkbox group semantics, upload lifecycle, range live previews, custom slider styling, multi-thumb range controls, password-specific UX, credential policy, date/time parsing, timezone conversion, custom picker UI, and app-specific feedback behavior to the host app.

## Phase 2: Better remote option workflows

Remote option loading is where Rails integration is often more valuable than Tom Select configuration itself.

Current progress:

- selected-option preload support for edit forms with `selected:` and `selected_url:`
- multi-value selected preload behavior through `selected_multiple_param:`
- richer option rendering metadata such as description and badge fields
- consistent create endpoint error handling and `create-error` events
- documented endpoint response shapes for search, find, and create
- scoped request context through `query_params:`, `selected_query_params:`, and `create_params:`
- Tom Select pass-throughs such as `max_items:`, `load_throttle:`, and `delimiter:`
- package-root JavaScript exports for `TomSelectController` and read-only rendered-field contract helpers documented in `doc/public_api.md`; these helpers inspect rendered Rails Fields Kit contracts without taking over request execution, locale resolution, query parsing, retry UI, or visible feedback
- read-only setup verification through `rails rails_fields_kit:doctor`, which checks initializer and importmap pin visibility while keeping Tom Select package install, Stimulus registration, CSS import, and bundler alias confirmation as host-app manual responsibilities

## Phase 3: Search input helpers

Rails Fields Kit may add helpers for writing complex search text more comfortably, without becoming the search backend.

Current progress:

- `rfk_search_field`
  - A wrapped native search input.
- `rfk_token_search`
  - A Tom Select-backed token-oriented search input for structured search phrases such as `status:open assignee:matsuo keyword`.
- `rfk_token_suggestions_with`
  - A lightweight controller helper for token suggestion JSON endpoints.
- `RailsFieldsKit::TokenSuggestions.build`
  - A builder for operator, field, predicate, value, and saved-search suggestion option JSON.
  - Saved-search support is current only as suggestion metadata for the submitted token search text. Rails Fields Kit does not currently expose a separate saved search selector helper, submitted saved-search ID contract, persistence workflow, execution policy, authorization rule, or sharing model.

Non-goals for the core gem:

- parsing arbitrary query languages into SQL
- deciding what `not(123)` means for a specific model
- building Active Record relations for app-specific search semantics
- replacing dedicated search gems

The host app, controller concern, query object, or search gem should remain responsible for interpreting submitted search text.

## Phase 4: Optional Ransack adapter

Ransack integration is valuable, especially for admin screens and list pages, but it should be optional.

The adapter should help Rails Fields Kit inputs produce or edit Ransack-compatible parameters. It should not install, configure, or hide Ransack.

Current progress:

- `RailsFieldsKit::RansackSuggestions.build` composes Ransack-compatible token suggestion metadata without requiring or executing Ransack.
- `RailsFieldsKit::TableFilterInput.ransack_filter` can describe table filter metadata intended for Ransack-backed token search.

Host app responsibilities should remain explicit:

- adding the `ransack` gem
- calling `Model.ransack(params[:q])` in the controller or equivalent layer
- defining `ransackable_attributes` and `ransackable_associations` when required
- deciding which fields and predicates are allowed
- parsing submitted token search text into Ransack params
- handling authorization, scoping, and result pagination

Feature gate: shared field/operator metadata registry (#405)

Before treating this roadmap lane as implementation guidance, use [`doc/shared_metadata_navigation.md`](doc/shared_metadata_navigation.md) to separate current public API, host-app metadata patterns, and future registry or adapter proposals. The current public names remain listed in [`doc/public_api.md`](doc/public_api.md).

The smallest useful slice is a docs/proposal pattern for a host app owned metadata source that can feed existing Rails Fields Kit surfaces:

- `TokenSuggestions.build` for general token, field, predicate, value, and saved-search suggestion option JSON
- `RansackSuggestions.build` when the same field list needs Ransack predicate metadata in suggestion payloads
- `TableFilterInput.ransack_filter` when table-oriented metadata should point at the same allowed field/predicate set

This is not a current public registry API. The first step should document how applications can keep one allowed field/operator map and pass derived views of it into the current builders. A future Ruby registry object should be split into its own feature issue, and a sample drift check should be split into a quality issue if it becomes useful.

Move from the docs pattern to a Ruby registry API only when the current builders show repeated host-app duplication that a narrow metadata aggregation object can remove. The accepted surface should stay limited to field/operator/value suggestion metadata and derived builder inputs; it should not change `TokenSuggestions.build`, `RansackSuggestions.build`, `TableFilterInput.ransack_filter`, FormBuilder helper signatures, or any rendered response shape.

A Ruby registry spike should document non-goals before implementation: no token query parser, no Active Record relation construction, no allowed predicate enforcement, no Ransack auto configuration, no authorization policy, and no table preference persistence or search execution integration. If those boundaries cannot be kept, keep the docs pattern as the current solution and defer the API.

The registry direction must not move query parsing, Active Record relation construction, authorization, allowed predicate enforcement, or Ransack configuration into Rails Fields Kit. Those remain host app responsibilities even when suggestion metadata is centralized.

Future proposal, not current public API:

```erb
<%= f.rfk_token_search :query,
  adapter: :ransack,
  param_name: :q,
  fields: {
    name: :name_cont,
    email: :email_cont,
    status: :status_eq,
    created_after: :created_at_gteq,
    created_before: :created_at_lteq
  } %>
```

If this direction is adopted later, it should keep Rails Fields Kit responsible for input UI and parameter assistance while leaving the actual search behavior to Ransack and the host application.

## Phase 5: Rails Table Preferences integration

Integration with `matsuo-haruhito/rails_table_preferences` is a strong candidate because it stays close to the gem's view/helper responsibility.

The goal is to let applications that already define table columns and preferences avoid hand-writing repetitive filter and cell-editor views.

Current progress:

- Rails Fields Kit exposes table-oriented metadata objects such as `RailsFieldsKit::TableFilterInput` and `RailsFieldsKit::TableCellInput`.
- Table-oriented gems can read these through `to_table_filter`, `to_table_cell_editor`, `to_h`, and `to_hash` without taking a hard dependency on Rails Fields Kit.
- The current Rails Table Preferences bridge first route is the docs/proposal boundary in [`doc/rails_table_preferences_bridge_boundary.md`](doc/rails_table_preferences_bridge_boundary.md), used with [`doc/table_adapters.md`](doc/table_adapters.md); it keeps this lane dependency-light and avoids adding a runtime adapter, table persistence, query execution, or authorization ownership to Rails Fields Kit.
- `RailsFieldsKit::TableRenderer` maps table filter/editor metadata to FormBuilder call specs or dispatches them through a FormBuilder.
- `RailsFieldsKit::TableRenderer` supports custom table field helper registration, normalized field/helper names, helper-hidden `registered_field_types` introspection, individual `unregister_field_helper` cleanup, reset behavior, ordered rendering, and mutation-safe call specs.
- `RailsFieldsKit::TableMetadata` collects filter/editor metadata from column lists, enumerators, hash columns, hash-like columns, object columns, and table-like objects that respond to `columns`.
- `RailsFieldsKit::TableMetadata` treats explicit `false` metadata as disabled, validates invalid hash-like metadata, prefers object metadata readers over `to_hash`, and duplicates collected metadata/options for downstream mutation safety.
- `rfk_table_filters` and `rfk_table_cell_editors` render collected table metadata directly from a FormBuilder and return safe buffers.
- Token search and Ransack-oriented filter metadata can be represented through `TableFilterInput.token_search` and `TableFilterInput.ransack_filter`.

Implemented helper direction:

```erb
<%= form_with url: users_path, method: :get do |f| %>
  <%= f.rfk_table_filters @table_preferences %>
<% end %>
```

```erb
<%= form_with model: @record do |f| %>
  <%= f.rfk_table_cell_editors @table_preferences %>
<% end %>
```

Future proposal, not current public API:

```erb
<%= search_form_for @q do |f| %>
  <%= f.rfk_table_filters @table_preferences,
    adapter: :ransack %>
<% end %>
```

MVP scope:

- render filters only for columns marked searchable/filterable
- support text, select, enum select, combobox, multi-select, tags, and token-search fields
- allow explicit predicate or parameter mapping when using Ransack
- preserve Rails Fields Kit wrapper, label, hint, error, and accessibility behavior
- avoid owning the table preference persistence layer
- avoid owning the search execution layer

This integration should be implemented as an optional layer, not as a hard dependency from the core gem.

## Current docs and review artifacts

The maintained docs should make the difference between current public API, review artifacts, and future proposals visible:

- `README.md` is the public entrypoint and docs map.
- `doc/setup.md` is the maintained setup walkthrough and source of truth for the read-only setup doctor boundary.
- `doc/public_api.md` is the intended stable API inventory for the 0.1.x series, including package-root JavaScript exports, FormBuilder helpers, controller helpers, table metadata adapters, Stimulus values, and events.
- `CHANGELOG.md` is the exhaustive release-history source for released and `Unreleased` user-visible changes.
- `doc/release_notes_0_1_1.md` is the reviewer-facing and GitHub-release-facing draft summary for the current `Unreleased` section. Keep it aligned with `CHANGELOG.md` and do not add proposal-only or open-PR behavior there until the corresponding current entry has landed.
- `doc/shared_metadata_navigation.md` is the short boundary map for shared token, Ransack, and table metadata patterns; it points readers back to the current API inventory and away from treating roadmap-only registry or adapter examples as implemented contract.
- `doc/masked_input_boundary.md` is the current proposal boundary for masked inputs. It points host apps to native wrappers plus host-owned masking libraries today and keeps `rfk_masked_field` out of the current public API.
- `doc/slug_helper_boundary.md` is the current proposal boundary for title-to-slug workflows. It points host apps to current native text wrappers today and keeps slug generation, uniqueness, transliteration, reserved words, validation, and persistence as host-app responsibilities.
- `doc/mention_field_boundary.md` is the current proposal boundary for textarea mention workflows. It points host apps to `rfk_autocomplete`, `rfk_token_search`, `rfk_tags`, or `rfk_text_area` where those existing lanes fit today and keeps mention parsing, overlay behavior, hidden metadata, authorization, and persistence as host-app responsibilities.
- `doc/datalist_boundary.md` is the current proposal boundary for HTML datalist support. It keeps `rfk_datalist_field` out of the current public API, points host apps to `rfk_text_field list:` plus host-owned `<datalist>` markup today, and separates browser-native datalist limits from Tom Select-backed remote search, create, rich rendering, and selected preload lanes.
- `doc/visual_references.md` and `doc/visual_reference_index.html` are maintained review entrypoints for landed static visual reference artifacts. They help reviewers inspect representative rendered states, but they do not define production runtime behavior or make proposal-only helper names current public API.
- `Product Profile.md` and `AGENTS.md` summarize maintainer-facing source-of-truth order and responsibility boundaries.

When a future feature lands, update the current public API docs and any affected review artifacts first, then sync `CHANGELOG.md` and the release note draft when the change is release-facing. Keep this roadmap aligned with that landed behavior without rewriting proposal lanes as implemented contract.

## Longer-term candidates

These are useful proposals, not current public API, and should not distract from the core Tom Select-backed field kit. Feature gate issues should decide the smallest useful slice and responsibility boundary before any candidate is documented as implemented behavior.

- mention fields for `@user` or `#tag` style textarea interactions; see #367 and [`doc/mention_field_boundary.md`](doc/mention_field_boundary.md). Current support stays in `rfk_autocomplete` for plain text suggestions, `rfk_token_search` for structured search text, `rfk_tags` for tag-entry fields, or `rfk_text_area` for ordinary textarea content; a dedicated mention helper would need a follow-up decision for representative mention type, submitted value shape, suggestion endpoint contract, overlay strategy, and host-app-owned parsing, authorization, and persistence.
- saved search selectors; see #377. Current support stays in `TokenSuggestions.build(saved_searches:)` as suggestion option JSON for `rfk_token_search`; an independent selector helper would need a follow-up decision for helper naming, submitted value shape, and host-app-owned persistence, execution, authorization, and sharing policy.
- field/operator suggestion registries; see #405. The first accepted gate is docs/proposal only; do not add a public Ruby registry before a follow-up feature issue accepts that API.
- datalist helpers for browser-native suggestions; see #1787 and [`doc/datalist_boundary.md`](doc/datalist_boundary.md). Current support stays in `rfk_text_field list:` plus host-owned `<datalist>` markup; a dedicated helper would need a follow-up decision for helper naming, candidate source shape, submitted text value contract, and the boundary between browser-native datalist behavior and Tom Select-backed helper lanes.
- slug helpers for title-to-slug workflows; see #373 and [`doc/slug_helper_boundary.md`](doc/slug_helper_boundary.md). Current support stays in existing native text wrappers; a dedicated slug helper would need a follow-up decision for data hooks, event shape, slug generation ownership, uniqueness, transliteration, reserved words, validation, and persistence policy.
- masked inputs only if a clear Rails integration gap remains; see #378 and [`doc/masked_input_boundary.md`](doc/masked_input_boundary.md) for the current non-API boundary.

## Design guardrails

- Prefer Rails-friendly wrappers over replacing Rails conventions.
- Keep Tom Select configuration accessible rather than hiding it completely.
- Treat app-specific search meaning as host app responsibility.
- Keep integrations optional and dependency-light.
- Make generated markup work naturally with Turbo-driven page updates.
- Document where Rails Fields Kit stops and host app code begins.
