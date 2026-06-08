# Rails Fields Kit 0.1.1 Release Notes (Draft)

This draft assumes the next release after `0.1.0` will be `0.1.1`.

If release planning chooses a different version number, rename this file and keep the contents aligned with `CHANGELOG.md` instead of editing the `0.1.0` historical notes in place.

Rails Fields Kit 0.1.1 is a follow-up release that expands the documented public surface around token-oriented search, Ransack-compatible suggestion metadata, table metadata adapters, controller/helper integration details, a dedicated create-success event for create-on-the-fly flows, package-root rendered-field contract helpers, Tom Select integration options, install generator setup-note opt-out, and opt-in inline request-failure placeholders while keeping query execution, visible copy ownership, validation feedback, focus management, JavaScript package ownership, and host-app setup note ownership in the host application.

## Highlights

- `rfk_token_search` for token-oriented search inputs such as `status:open keyword`.
- `rfk_token_suggestions_with` and `RailsFieldsKit::TokenSuggestions.build` for lightweight token suggestion JSON endpoints.
- `RailsFieldsKit::RansackSuggestions.build` for Ransack-compatible token suggestion metadata without requiring or executing Ransack.
- `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer` for table-oriented metadata integration.
- `rfk_table_filters` and `rfk_table_cell_editors` for rendering documented table metadata through a FormBuilder.
- Table metadata collection and renderer fixes that keep hash-like, object, enumerable, nil, and disabled metadata inputs predictable without changing table persistence or query execution ownership.
- `tomSelectTextOverrideContract(element)` for reading rendered Tom Select text override values from package-root JavaScript imports.
- `tomSelectPluginContract(element)` for reading rendered Tom Select plugin data, including the effective plugin list and derived clear/remove flags, from package-root JavaScript imports.
- `nativeFieldAccessibilityContract(element)` for reading rendered native input accessibility wiring and label association from package-root JavaScript imports.
- `readRenderedSelectedPreloadConfig(element)` for reading rendered selected preload config values from package-root JavaScript imports without executing preload requests.
- `action:` support for `rfk_search_with`, `rfk_find_with`, and `rfk_create_with` so controller helpers can match custom routes.
- Multiple selected preload endpoints can accept Rails array params in addition to comma-separated `ids`, including custom `ids_param:` names.
- Remote search and selected preload collection responses can use raw arrays, `{ options: [...] }`, or `{ results: [...] }` wrappers; create-on-the-fly `{ option: ... }`, pagination metadata, and arbitrary response adapters remain separate.
- Fixed remote request params with `query_params:`, `selected_query_params:`, and `create_params:`.
- Tom Select option pass-throughs for `max_items:`, `load_throttle:`, and `delimiter:`.
- `rails generate rails_fields_kit:install --skip-setup-notes` for host apps that want the initializer without generating `doc/rails_fields_kit_setup.md`.
- `rails-fields-kit--tom-select:create` as a dedicated create-on-the-fly success hook with `event.detail.input` and `event.detail.option`.
- Opt-in `error_surface:` / `error_surface_html:` helper options so request-failure events can expose a nearby placeholder as `event.detail.surface`.
- A normalized Tom Select failure event detail shape across remote search, selected preload, and create-on-the-fly failures.
- Documented request cancellation behavior: aborted requests, disconnect-time aborts, and stale responses do not dispatch success or failure events.

## Relationship to `CHANGELOG.md` Unreleased

Use `CHANGELOG.md` as the exhaustive release-history source of truth. This draft is the reviewer-facing and GitHub-release-facing summary for the current `Unreleased` section.

Before cutting the release, compare this draft with the current `Unreleased` entries and confirm it still covers these categories:

- Added: token search and suggestion metadata, table metadata and rendering, JavaScript exports, controller action routing, selected preload array params, remote collection response wrappers, fixed remote request params, Tom Select option pass-throughs, install generator setup-note opt-out, create-success events, and opt-in request-failure placeholders.
- Fixed: remote request lifecycle and event details, token and Ransack suggestion metadata immutability, table metadata collection edge cases, table input and renderer immutability, and TableRenderer input normalization and error messages.

Do not add open-PR or proposal helper names here until they have landed in the release branch and `CHANGELOG.md` has the corresponding current entry.

## Main helpers and builders

FormBuilder helpers:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- `rfk_token_search`
- `rfk_table_filters`
- `rfk_table_cell_editors`
- native helpers such as `rfk_text_field`, `rfk_money_field`, and `rfk_search_field`

Controller helpers:

- `rfk_search_with`
- `rfk_find_with` for selected option lookup endpoints, including comma-separated `ids` and Rails array params for multiple selected preload
- `rfk_create_with`
- `rfk_token_suggestions_with`

Metadata and builder APIs:

- `RailsFieldsKit::TokenSuggestions.build`
- `RailsFieldsKit::RansackSuggestions.build`
- `RailsFieldsKit::TableFilterInput`
- `RailsFieldsKit::TableCellInput`
- `RailsFieldsKit::TableMetadata`
- `RailsFieldsKit::TableRenderer`

JavaScript package-root exports:

- `TomSelectController`
- `tomSelectTextOverrideContract(element)` for rendered text override values: `noResultsText`, `loadingText`, and `createText`
- `tomSelectPluginContract(element)` for rendered Tom Select plugin data: `plugins`, `hasClearButton`, and `hasRemoveButton`
- `readRenderedSelectedPreloadConfig(element)` for rendered selected preload config values: `selectedUrl`, `selectedParam`, `selectedMultipleParam`, and `selectedQueryParams`
- `nativeFieldAccessibilityContract(element)` for rendered native input accessibility wiring: `describedByIds`, `describedByElements`, `labelElement`, `hintElement`, `errorElement`, and `wrapperElement`

## Compatibility and responsibility boundary

- Rails: `>= 7.0`, `< 9.0`
- Ruby: `>= 3.1`
- Tom Select must still be installed by the host application.
- The host application still owns bundler or importmap setup for JavaScript entrypoints.
- The install generator creates `config/initializers/rails_fields_kit.rb` by default and can skip only the generated `doc/rails_fields_kit_setup.md` artifact with `--skip-setup-notes`; host apps that skip it should keep setup notes in their own docs and use `doc/setup.md` as the maintained upstream guide.
- Package-root rendered-field contract helpers only read data attributes, aria wiring, plugin lists, derived plugin flags, and element references, including labels, already rendered by Rails Fields Kit; visible copy ownership, locale resolution, request execution, query parsing, retry UI, validation feedback, plugin asset loading, clear/remove affordance styling, selection mutation, Tom Select lifecycle, and focus management remain host-app responsibilities.
- Submitted token text parsing, `params[:q]` construction, authorization, scoping, pagination, and result execution remain host-app responsibilities.
- Remote search and selected preload collection wrappers describe only the option list envelope; host apps still own pagination policy and any extra response metadata.
- Visible success UI, toast copy, and follow-up app behavior after `rails-fields-kit--tom-select:create` remain host-app responsibilities.
- `error_surface:` only renders an opt-in nearby placeholder; visible error copy and retry behavior for that surface remain host-app responsibilities.
- Request cancellation and stale-response handling do not create request-start, retry, fallback, success, or failure UI; host applications that need those states should pair Rails Fields Kit events with host-owned interaction state.
- Multiple selected preload still accepts comma-separated `ids`; Rails-style array params are supported when the host application's request stack has normalized repeated keys such as `ids[]` into an Array.
- `readRenderedSelectedPreloadConfig(element)` only reads rendered selected preload config; selected preload request execution, endpoint authorization, visible fallback copy, and retry UI remain host-app responsibilities.
- Table metadata helpers expose rendering metadata only; they do not take over table preference persistence or query execution.

## Verification expectations

The release candidate should pass:

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
```

Before publishing, also confirm:

- GitHub Actions CI is green for the exact release commit.
- `doc/sample_app_results.md` is completed for the same branch head.
- documented JavaScript import paths resolve in the sample app.
- package-root helper exports such as `tomSelectTextOverrideContract(element)`, `tomSelectPluginContract(element)`, `readRenderedSelectedPreloadConfig(element)`, and `nativeFieldAccessibilityContract(element)` can be imported from `rails_fields_kit` when that release surface is in scope.
- Tom Select plugin contract checks confirm the rendered effective plugin list and derived clear/remove flags without moving plugin asset loading, control styling, selection mutation, empty-state copy, Tom Select plugin objects, or Tom Select lifecycle into the package.
- native accessibility contract checks confirm rendered `aria-describedby` ids and resolved label / hint / error / wrapper elements without moving id generation, label text, validation UI, or focus management into the package.
- remote search and selected preload wrappers still match `doc/controller_helpers.md` without turning create-on-the-fly response contracts, pagination metadata, or arbitrary response adapters into gem-owned behavior.
- selected preload config reader checks stay limited to rendered config inspection; request execution and visible fallback evidence stay with the selected preload behavior lane.
- Tom Select option pass-throughs such as `max_items:`, `load_throttle:`, and `delimiter:` remain documented only as helper-to-controller options rather than JavaScript package ownership.
- `rails generate rails_fields_kit:install --skip-setup-notes` still skips only `doc/rails_fields_kit_setup.md`, still creates the initializer, and still leaves Tom Select / importmap setup ownership with the host app.
- the sample app confirms `rails-fields-kit--tom-select:create`, `event.detail.input`, and `event.detail.option` when that release surface is in scope.
- representative request-failure flows confirm `event.detail.surface` when `error_surface:` is in scope for the release, and any visible inline error copy still belongs to the host app.
- aborted requests, disconnect-time aborts, and stale responses do not dispatch Tom Select success or failure events.
- `rails-fields-kit--tom-select:item-add` and `rails-fields-kit--tom-select:change` still describe the accepted selection after create succeeds.
- token suggestion and Ransack suggestion metadata checks pass if those surfaces are in scope for the release.
- table metadata helpers or `TableRenderer` call-spec paths are covered if they are in scope for the release.
- remote search, selected preload, create-on-the-fly, and failure event handling still match the current docs.

## Suggested GitHub release body

```markdown
Rails Fields Kit 0.1.1 expands the gem beyond the first 0.1.0 release with token-oriented search helpers, metadata-only Ransack suggestion builders, table adapter metadata for rendering documented field helpers through existing host-app table definitions, package-root rendered-field contract helpers, Tom Select option pass-throughs, install generator setup-note opt-out, a dedicated create-success event for create-on-the-fly flows, and opt-in inline request-failure placeholder hooks.

### Highlights

- `rfk_token_search` for token-style query inputs
- `rfk_token_suggestions_with` and `RailsFieldsKit::TokenSuggestions.build`
- `RailsFieldsKit::RansackSuggestions.build` for metadata-only Ransack-compatible suggestions
- `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer`
- `rfk_table_filters` and `rfk_table_cell_editors`
- table metadata collection and renderer robustness fixes for hash-like, object, enumerable, nil, and disabled metadata inputs
- `tomSelectTextOverrideContract(element)` for rendered Tom Select text override values
- `tomSelectPluginContract(element)` for rendered Tom Select plugin data and derived clear/remove flags
- `readRenderedSelectedPreloadConfig(element)` for rendered selected preload config reads
- `nativeFieldAccessibilityContract(element)` for rendered native input accessibility wiring and label association
- controller helper `action:` support, selected preload array params, and remote collection wrappers such as `{ options: [...] }` and `{ results: [...] }`
- Tom Select option pass-throughs for `max_items:`, `load_throttle:`, and `delimiter:`
- `rails generate rails_fields_kit:install --skip-setup-notes` to skip only the generated setup-note docs artifact while still creating the initializer
- `rails-fields-kit--tom-select:create` with `event.detail.input` / `event.detail.option`
- `error_surface:` / `error_surface_html:` with request-failure `event.detail.surface`
- normalized Tom Select failure event detail payloads
- documented request cancellation and stale-response no-event boundaries

### Compatibility

- Rails >= 7.0, < 9.0
- Ruby >= 3.1
- Tom Select must still be installed by the host application

### Responsibility boundary

Rails Fields Kit still stops at UI helpers and metadata. Host applications remain responsible for token parsing, search execution, authorization, pagination, JavaScript package manager or importmap choices, setup-note ownership when `--skip-setup-notes` is used, selected preload request execution and visible fallback UI, visible copy and locale policy for rendered text overrides, visible success UI after create-on-the-fly succeeds, visible error or retry UI around any opt-in `error_surface:` placeholder, plugin asset loading and clear/remove affordance styling around rendered Tom Select plugin data, id generation and label text policy around native accessibility wiring, validation feedback and focus management, and any host-owned loading or retry state around aborted or stale requests. Remote collection wrappers do not make pagination metadata or arbitrary response adapters gem-owned behavior. Multiple selected preload supports Rails array params only after the host app request stack normalizes repeated keys such as `ids[]` into an Array.

### Verification

- `bundle exec standardrb`
- `bundle exec rspec`
- `bundle exec rake build`
- sample app checklist and CI confirmation for the exact release commit
```
