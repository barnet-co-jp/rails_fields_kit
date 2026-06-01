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
- `nativeFieldAccessibilityContract(element)` for reading rendered native input accessibility wiring from package-root JavaScript imports.
- `action:` support for `rfk_search_with`, `rfk_find_with`, and `rfk_create_with` so controller helpers can match custom routes.
- Multiple selected preload endpoints can accept Rails array params in addition to comma-separated `ids`, including custom `ids_param:` names.
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

- Added: token search and suggestion metadata, table metadata and rendering, JavaScript exports, controller action routing, selected preload array params, fixed remote request params, Tom Select option pass-throughs, install generator setup-note opt-out, create-success events, and opt-in request-failure placeholders.
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
- `nativeFieldAccessibilityContract(element)` for rendered native input accessibility wiring: `describedByIds`, `describedByElements`, `hintElement`, `errorElement`, and `wrapperElement`

## Compatibility and responsibility boundary

- Rails: `>= 7.0`, `< 9.0`
- Ruby: `>= 3.1`
- Tom Select must still be installed by the host application.
- The host application still owns bundler or importmap setup for JavaScript entrypoints.
- The install generator creates `config/initializers/rails_fields_kit.rb` by default and can skip only the generated `doc/rails_fields_kit_setup.md` artifact with `--skip-setup-notes`; host apps that skip it should keep setup notes in their own docs and use `doc/setup.md` as the maintained upstream guide.
- Package-root rendered-field contract helpers only read data attributes, aria wiring, and element references already rendered by Rails Fields Kit; visible copy ownership, locale resolution, request execution, query parsing, retry UI, validation feedback, and focus management remain host-app responsibilities.
- Submitted token text parsing, `params[:q]` construction, authorization, scoping, pagination, and result execution remain host-app responsibilities.
- Visible success UI, toast copy, and follow-up app behavior after `rails-fields-kit--tom-select:create` remain host-app responsibilities.
- `error_surface:` only renders an opt-in nearby placeholder; visible error copy and retry behavior for that surface remain host-app responsibilities.
- Request cancellation and stale-response handling do not create request-start, retry, fallback, success, or failure UI; host applications that need those states should pair Rails Fields Kit events with host-owned interaction state.
- Multiple selected preload still accepts comma-separated `ids`; Rails-style array params are supported when the host application's request stack has normalized repeated keys such as `ids[]` into an Array.
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
- package-root helper exports such as `tomSelectTextOverrideContract(element)` and `nativeFieldAccessibilityContract(element)` can be imported from `rails_fields_kit` when that release surface is in scope.
- native accessibility contract checks confirm rendered `aria-describedby` ids and resolved hint / error / wrapper elements without moving validation UI or focus management into the package.
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
- `nativeFieldAccessibilityContract(element)` for rendered native input accessibility wiring
- controller helper `action:` support, selected preload array params, and fixed request params
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

Rails Fields Kit still stops at UI helpers and metadata. Host applications remain responsible for token parsing, search execution, authorization, pagination, JavaScript package manager or importmap choices, setup-note ownership when `--skip-setup-notes` is used, visible copy and locale policy for rendered text overrides, visible success UI after create-on-the-fly succeeds, visible error or retry UI around any opt-in `error_surface:` placeholder, validation feedback and focus management around native accessibility wiring, and any host-owned loading or retry state around aborted or stale requests. Multiple selected preload supports Rails array params only after the host app request stack normalizes repeated keys such as `ids[]` into an Array.

### Verification

- `bundle exec standardrb`
- `bundle exec rspec`
- `bundle exec rake build`
- sample app checklist and CI confirmation for the exact release commit
```