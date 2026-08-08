# Rails Fields Kit 0.1.1 Release Notes (Draft)

This draft assumes the next release after `0.1.0` will be `0.1.1`.

If release planning chooses a different version number, rename this file and keep the contents aligned with `CHANGELOG.md` instead of editing the `0.1.0` historical notes in place.

Rails Fields Kit 0.1.1 is a follow-up release that expands the documented public surface around token-oriented search, Ransack-compatible suggestion metadata, table metadata adapters, block-scoped TableRenderer helper overrides, thin native range, password, file, checkbox, and date/time/datetime-local/color field wrappers, controller/helper integration details, endpoint-side search match strategies, a dedicated create-success event for create-on-the-fly flows, package-root rendered-field contract helpers, TypeScript declaration metadata for the package root and direct controller entrypoint, Tom Select integration options, install generator setup-note opt-out, setup doctor status guidance, machine-readable setup doctor JSON output, and opt-in inline request-failure placeholders while keeping query execution, visible copy ownership, adapter-specific SQL behavior, validation feedback, focus management, long-lived global renderer registry changes, range-specific live previews and custom slider styling, password-specific UX and credential policy, file upload workflows, checkbox collection/radio group semantics, browser-native date/time picker behavior, timezone policy, JavaScript package ownership, host-app setup note ownership, and host-app CI pass/fail policy in the host application.

## Highlights

- `rfk_token_search` for token-oriented search inputs such as `status:open keyword`.
- `rfk_token_suggestions_with` and `RailsFieldsKit::TokenSuggestions.build` for lightweight token suggestion JSON endpoints.
- `RailsFieldsKit::RansackSuggestions.build` for Ransack-compatible token suggestion metadata without requiring or executing Ransack.
- `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer` for table-oriented metadata integration.
- `RailsFieldsKit::TableRenderer.with_field_helpers(...)` for block-scoped table renderer helper overrides that restore the registry after the block without changing table persistence or query ownership.
- `rfk_table_filters` and `rfk_table_cell_editors` for rendering documented table metadata through a FormBuilder.
- `rfk_range_field` for rendering an ordinary native range input through the existing native wrapper lane while leaving browser slider behavior, live value previews, custom slider styling, multi-thumb controls, validation policy, and production CSS in the host application.
- `rfk_password_field` for rendering an ordinary native password input through the existing native wrapper lane while leaving password visibility toggles, strength meters, credential policy, autocomplete policy, authentication workflow, and credential storage in the host application.
- `rfk_file_field` for rendering an ordinary native file input through the existing native wrapper lane while leaving multipart form setup, Active Storage direct upload JavaScript, previews, upload progress UI, validation policy, storage configuration, virus scanning, and production CSS in the host application.
- `rfk_check_box` for rendering an ordinary Rails checkbox through the existing native wrapper lane while preserving Rails' hidden field and checked / unchecked value contract and leaving collection groups, radio buttons, validation UI redesign, label placement redesign, and production CSS outside the current public surface.
- `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field` for rendering browser-native date/time/datetime-local/color inputs through the existing native wrapper lane while leaving timezone conversion, masking, custom picker UI, browser normalization, validation policy, locale formatting, and production CSS in the host application.
- Table metadata collection and renderer fixes that keep hash-like, object, enumerable, nil, and disabled metadata inputs predictable without changing table persistence or query execution ownership.
- `tomSelectTextOverrideContract(element)` for reading rendered Tom Select text override values from package-root JavaScript imports.
- `tomSelectPluginContract(element)` for reading rendered Tom Select plugin data, including the effective plugin list and derived clear/remove flags, from package-root JavaScript imports.
- `tomSelectSelectionContract(element)` for reading initialized Tom Select-backed field selection values on demand from package-root JavaScript imports without exposing Tom Select internals or mutating selections.
- `tomSelectRequestContract(element)` for reading rendered request endpoint and parameter config, including fixed remote-search and create params, from package-root JavaScript imports without executing remote requests.
- `tomSelectFieldKindContract(element)` for reading the rendered Rails Fields Kit helper-lane kind without redefining helper taxonomy or mutating Tom Select.
- `readRenderedTomSelectInteractionConfig(element)` for reading rendered Tom Select interaction options such as `maxOptions`, `maxItems`, `loadThrottle`, `delimiter`, and lifecycle toggles without owning interaction policy.
- `readRenderedErrorSurface(element)` for resolving a rendered opt-in request-failure placeholder from package-root JavaScript imports without creating feedback or retry UI.
- `readRenderedSelectedPreloadConfig(element)` for reading rendered selected preload config values from package-root JavaScript imports without executing preload requests.
- `readRenderedOptionPayloadMapping(element)` for reading rendered option payload field mapping without executing endpoints or owning option rendering.
- `readRenderedTableFilterMetadata(element)` for reading table filter metadata rendered through the table metadata lane without executing Ransack or table searches.
- `nativeFieldAccessibilityContract(element)` for reading rendered native input accessibility wiring, affix elements, and label association from package-root JavaScript imports.
- Package metadata publishes TypeScript declaration metadata for the package root and direct controller entrypoint as editor-facing assistance for the documented runtime exports, without adding a separate runtime API or host-app TypeScript policy.
- `action:` support for `rfk_search_with`, `rfk_find_with`, and `rfk_create_with` so controller helpers can match custom routes.
- `rfk_search_with match:` for endpoint-side SQL LIKE pattern strategies, with `:contains` as the default and `:prefix` / `:exact` as opt-in narrower matches while adapter-specific case behavior stays host-app-owned.
- Multiple selected preload endpoints can accept Rails array params in addition to comma-separated `ids`, including custom `ids_param:` names.
- Remote search and selected preload collection responses can use raw arrays, `{ options: [...] }`, or `{ results: [...] }` wrappers; create-on-the-fly `{ option: ... }`, pagination metadata, and arbitrary response adapters remain separate.
- Fixed remote request params with `query_params:`, `selected_query_params:`, and `create_params:`.
- Tom Select option pass-throughs for `max_items:`, `load_throttle:`, and `delimiter:`.
- `rails generate rails_fields_kit:install --skip-setup-notes` for host apps that want the initializer without generating `doc/rails_fields_kit_setup.md`.
- `rails rails_fields_kit:doctor` now starts with a status legend and next-step guidance so `[MISSING]` setup gaps and `[MANUAL]` host-app JavaScript checks are easier to read without turning the doctor into an auto-fix or CI policy tool.
- `RailsFieldsKit::SetupDoctor#run(format: :json)` can emit the same read-only setup checks as machine-readable JSON for host-app scripts or release verification without making Rails Fields Kit own CI pass/fail policy, auto-fix behavior, SARIF/JUnit output, or a formal external schema.
- `rails-fields-kit--tom-select:create` as a dedicated create-on-the-fly success hook with `event.detail.input` and `event.detail.option`.
- Opt-in `error_surface:` / `error_surface_html:` helper options so request-failure events can expose a nearby placeholder as `event.detail.surface`.
- A normalized Tom Select failure event detail shape across remote search, selected preload, and create-on-the-fly failures.
- Documented request cancellation behavior: aborted requests, disconnect-time aborts, and stale responses do not dispatch success or failure events.

## Relationship to `CHANGELOG.md` Unreleased

Use `CHANGELOG.md` as the exhaustive release-history source of truth. This draft is the reviewer-facing and GitHub-release-facing summary for the current `Unreleased` section.

Before cutting the release, compare this draft with the current `Unreleased` entries and confirm it still covers these categories:

- Added: `rfk_lookup` free-text/selected-ID pairing, declarative `option_metadata_fields` previews, token search and suggestion metadata, table metadata and rendering, scoped TableRenderer helper overrides, native range, password, file, checkbox, and date/time/datetime-local/color field wrappers, JavaScript exports, TypeScript declaration metadata, controller action routing, search match strategies, selected preload array params, remote collection response wrappers, fixed remote request params, Tom Select option pass-throughs, install generator setup-note opt-out, setup doctor status guidance, machine-readable setup doctor JSON output, create-success events, and opt-in request-failure placeholders.
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
- native helpers such as `rfk_text_field`, `rfk_money_field`, `rfk_search_field`, `rfk_range_field`, `rfk_password_field`, `rfk_file_field`, `rfk_check_box`, `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field`

Controller helpers:

- `rfk_search_with`, including endpoint-side `match:` strategies for `:contains`, `:prefix`, and `:exact`
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
- `RailsFieldsKit::TableRenderer.with_field_helpers(...)`

JavaScript package-root exports:

- `TomSelectController`
- `tomSelectTextOverrideContract(element)` for rendered text override values: `noResultsText`, `loadingText`, and `createText`
- `tomSelectPluginContract(element)` for rendered Tom Select plugin data: `plugins`, `hasClearButton`, and `hasRemoveButton`
- `tomSelectSelectionContract(element)` for initialized Tom Select selection state: `values`
- `tomSelectRequestContract(element)` for rendered request endpoint and parameter config: `url`, `selectedUrl`, `createUrl`, `queryParam`, `queryParams`, `selectedParam`, `selectedMultipleParam`, `createParam`, `createParams`, `minLength`, and `errorSurfaceId`
- `tomSelectFieldKindContract(element)` for rendered helper-lane kind values: `controller` and `kind`
- `readRenderedTomSelectInteractionConfig(element)` for rendered interaction config values: `maxOptions`, `maxItems`, `loadThrottle`, `delimiter`, `preload`, `openOnFocus`, `closeAfterSelect`, `hideSelected`, and `persist`
- `readRenderedErrorSurface(element)` for resolving the rendered opt-in request-failure placeholder element referenced by `errorSurfaceId`
- `readRenderedSelectedPreloadConfig(element)` for rendered selected preload config values: `selectedUrl`, `selectedParam`, `selectedMultipleParam`, and `selectedQueryParams`
- `readRenderedOptionPayloadMapping(element)` for rendered option payload mapping values: `valueField`, `labelField`, `searchFields`, `optionDescriptionField`, and `optionBadgeField`
- `readRenderedTableFilterMetadata(element)` for table filter metadata values: `adapter`, `paramName`, and `fields`
- `nativeFieldAccessibilityContract(element)` for rendered native input accessibility wiring: `describedByIds`, `describedByElements`, `labelElement`, `hintElement`, `errorElement`, `prefixElement`, `suffixElement`, and `wrapperElement`

Package metadata also publishes TypeScript declaration metadata for the package root and direct `rails_fields_kit/tom_select_controller` entrypoint. Treat the declarations as editor-facing metadata for the runtime exports above, not as a separate runtime API, helper inventory, or host-app `tsconfig` guide.

## Compatibility and responsibility boundary

- Rails: `>= 7.0`, `< 9.0`
- Ruby: `>= 3.1`
- Tom Select must still be installed by the host application.
- The host application still owns bundler or importmap setup for JavaScript entrypoints.
- The install generator creates `config/initializers/rails_fields_kit.rb` by default and can skip only the generated `doc/rails_fields_kit_setup.md` artifact with `--skip-setup-notes`; host apps that skip it should keep setup notes in their own docs and use `doc/setup.md` as the maintained upstream guide.
- `rails rails_fields_kit:doctor` is a read-only setup visibility diagnostic. Its status legend tells adopters to fix `[MISSING]` lines for the detected route first and review `[MANUAL]` lines as host-app checks; it does not rewrite setup files, choose Tom Select package policy, validate bundler aliases, or define host-app CI gates.
- SetupDoctor machine-readable JSON is an alternate representation of the same read-only checks for host-app scripts and release verification. Use `doc/setup_doctor_machine_readable.md` as the payload reference; the release note does not define a host-app CI pass/fail policy, auto-fix behavior, SARIF/JUnit output, or a formal external schema.
- `rfk_range_field` is a thin native wrapper around Rails range input rendering; browser slider behavior, live value previews, custom slider styling, multi-thumb controls, validation policy, and production CSS remain host-app responsibilities.
- `rfk_password_field` is a thin native wrapper around Rails password input rendering; password visibility toggles, strength meters, credential policy, autocomplete policy, authentication workflow, and credential storage remain host-app responsibilities.
- `rfk_file_field` is a thin native wrapper around Rails file input rendering; multipart form setup, Active Storage direct upload JavaScript, previews, upload progress UI, file size and MIME validation policy, storage configuration, virus scanning, and production CSS remain host-app responsibilities.
- `rfk_check_box` is a thin native wrapper around Rails checkbox rendering; Rails' hidden field and checked / unchecked value contract stays native, while collection checkbox groups, radio buttons, validation UI redesign, label placement redesign, and production CSS remain out of scope.
- `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field` are thin browser-native wrappers; timezone conversion, masking, custom picker UI, browser normalization, validation policy, locale formatting, and production CSS remain host-app responsibilities.
- Package-root rendered-field contract helpers only read data attributes, aria wiring, plugin lists, derived plugin flags, selection values, option mapping, interaction configuration, table metadata, and element references already rendered by Rails Fields Kit; visible copy ownership, locale resolution, request execution, query parsing, retry UI, validation feedback, plugin asset loading, clear/remove affordance styling, selection mutation, Tom Select lifecycle, table search execution, and focus management remain host-app responsibilities.
- Submitted token text parsing, `params[:q]` construction, authorization, scoping, pagination, and result execution remain host-app responsibilities.
- `rfk_search_with match:` selects endpoint-side SQL LIKE pattern shape only. Database collation, case sensitivity, accent handling, PostgreSQL-specific `ILIKE`, normalized search columns, Ransack execution, and authorization-aware custom query semantics remain host-app responsibilities.
- Remote search and selected preload collection wrappers describe only the option list envelope; host apps still own pagination policy and any extra response metadata.
- Visible success UI, toast copy, and follow-up app behavior after `rails-fields-kit--tom-select:create` remain host-app responsibilities.
- `error_surface:` only renders an opt-in nearby placeholder; visible error copy and retry behavior for that surface remain host-app responsibilities.
- Request cancellation and stale-response handling do not create request-start, retry, fallback, success, or failure UI; host applications that need those states should pair Rails Fields Kit events with host-owned interaction state.
- Multiple selected preload still accepts comma-separated `ids`; Rails-style array params are supported when the host application's request stack has normalized repeated keys such as `ids[]` into an Array.
- `readRenderedSelectedPreloadConfig(element)` only reads rendered selected preload config; selected preload request execution, endpoint authorization, visible fallback copy, and retry UI remain host-app responsibilities.
- Table metadata helpers expose rendering metadata only; they do not take over table preference persistence or query execution. `TableRenderer.with_field_helpers(...)` scopes helper registry overrides to the block and restores the prior mapping afterward rather than defining a host-app-wide registry policy.

## Verification expectations

The release candidate should pass the same primary local checks described in `doc/development.md`:

```bash
bundle exec standardrb
bundle exec rspec
npm run check:js
bundle exec rake build
```

Before publishing, also confirm:

- GitHub Actions CI is green for the exact release commit, including the Node JavaScript job matrix tracked in `doc/development.md` rather than duplicated here.
- `doc/sample_app_results.md` is completed for the same branch head.
- documented JavaScript import paths resolve in the sample app.
- native range field checks stay limited to wrapper, label, hint, error, affix, native `min` / `max` / `step` pass-through, and accessibility wiring; live value previews, custom slider styling, multi-thumb controls, validation policy, and production CSS remain host-app-owned.
- native password field checks stay limited to wrapper, label, hint, error, affix, pass-through option, and accessibility wiring; password visibility toggles, strength meters, credential policy, autocomplete policy, authentication workflow, and credential storage remain host-app-owned.
- native file field checks stay limited to wrapper, label, hint, error, pass-through Rails file input options, and accessibility wiring; multipart form setup, Active Storage direct upload JavaScript, previews, upload progress UI, validation policy, storage configuration, virus scanning, and production CSS remain host-app-owned.
- native checkbox checks stay limited to Rails' hidden field and checked / unchecked value contract plus wrapper, hint, error, and accessibility wiring; collection groups, radio buttons, validation UI redesign, label placement redesign, and production CSS remain out of scope.
- native date/time/datetime-local/color checks stay limited to browser-native input rendering, ordinary native attribute pass-through, wrapper, hint, error, and accessibility wiring; timezone conversion, masking, custom picker UI, browser normalization, validation policy, locale formatting, and production CSS remain host-app-owned.
- package-root helper exports such as `tomSelectTextOverrideContract(element)`, `tomSelectPluginContract(element)`, `tomSelectSelectionContract(element)`, `tomSelectRequestContract(element)`, `tomSelectFieldKindContract(element)`, `readRenderedTomSelectInteractionConfig(element)`, `readRenderedErrorSurface(element)`, `readRenderedSelectedPreloadConfig(element)`, `readRenderedOptionPayloadMapping(element)`, `readRenderedTableFilterMetadata(element)`, and `nativeFieldAccessibilityContract(element)` can be imported from `rails_fields_kit` when that release surface is in scope.
- TableRenderer scoped override checks stay limited to block-scoped helper mapping, return value, and restore behavior; they do not make table persistence, query execution, renderer policy, or long-lived host-app registry ownership part of Rails Fields Kit.
- Tom Select plugin contract checks confirm the rendered effective plugin list and derived clear/remove flags without moving plugin asset loading, control styling, selection mutation, empty-state copy, Tom Select plugin objects, or Tom Select lifecycle into the package.
- Tom Select selection contract checks confirm initialized field values through the read-only `values` array without moving selection mutation, hidden fields, event dispatch, validation feedback, request execution, or Tom Select instance lifecycle into the package.
- Tom Select request contract checks confirm rendered request endpoint, fixed params, and parameter config without moving request execution, endpoint authorization, query parsing, visible feedback, retry UI, or pagination policy into the package.
- Tom Select field-kind and interaction-config reader checks confirm rendered helper-lane and option values without redefining helper taxonomy, mutating Tom Select, or owning host-app interaction policy.
- option payload mapping and table filter metadata reader checks confirm rendered metadata inspection without executing endpoints, parsing token strings, running Ransack, or deciding table search behavior.
- error surface reader checks confirm a rendered opt-in placeholder can be resolved through `readRenderedErrorSurface(element)` without moving visible copy, validation policy, retry UI, request execution, authorization, or fallback rendering into the package.
- native accessibility contract checks confirm rendered `aria-describedby` ids and resolved label / hint / error / affix / wrapper elements without moving id generation, label text, validation UI, or focus management into the package.
- TypeScript declaration metadata remains aligned with the package-root and direct controller runtime exports without creating a separate runtime helper surface or host-app TypeScript policy.
- remote search and selected preload wrappers still match `doc/controller_helpers.md` without turning create-on-the-fly response contracts, pagination metadata, or arbitrary response adapters into gem-owned behavior.
- selected preload config reader checks stay limited to rendered config inspection; request execution and visible fallback evidence stay with the selected preload behavior lane.
- Tom Select option pass-throughs such as `max_items:`, `load_throttle:`, and `delimiter:` remain documented only as helper-to-controller options rather than JavaScript package ownership.
- `rfk_search_with match:` checks stay limited to SQL LIKE pattern shape and do not imply Rails Fields Kit owns database collation, PostgreSQL-specific `ILIKE`, normalized search columns, Ransack execution, or authorization-aware custom query semantics.
- `rails generate rails_fields_kit:install --skip-setup-notes` still skips only `doc/rails_fields_kit_setup.md`, still creates the initializer, and still leaves Tom Select / importmap setup ownership with the host app.
- `rails rails_fields_kit:doctor` output includes the status legend and next-step guidance, keeps `[MISSING]` fixes separate from `[MANUAL]` host-app checks, and remains a read-only diagnostic rather than an auto-fix, host-app CI policy, or setup ownership transfer.
- SetupDoctor JSON output points readers back to `doc/setup_doctor_machine_readable.md` for `schema_version`, `summary`, `checks`, and `manual` details without turning release notes into the payload mirror or promising SARIF/JUnit/formal schema output.
- the sample app confirms `rails-fields-kit--tom-select:create`, `event.detail.input`, and `event.detail.option` when that release surface is in scope.
- representative request-failure flows confirm `event.detail.surface` when `error_surface:` is in scope for the release, and any visible inline error copy still belongs to the host app.
- aborted requests, disconnect-time aborts, and stale responses do not dispatch Tom Select success or failure events.
- `rails-fields-kit--tom-select:item-add` and `rails-fields-kit--tom-select:change` still describe the accepted selection after create succeeds.
- token suggestion and Ransack suggestion metadata checks pass if those surfaces are in scope for the release.
- table metadata helpers or `TableRenderer` call-spec paths are covered if they are in scope for the release.
- remote search, selected preload, create-on-the-fly, and failure event handling still match the current docs.

## Suggested GitHub release body

```markdown
Rails Fields Kit 0.1.1 expands the gem beyond the first 0.1.0 release with token-oriented search helpers, metadata-only Ransack suggestion builders, table adapter metadata for rendering documented field helpers through existing host-app table definitions, block-scoped TableRenderer helper overrides, thin native range, password, file, checkbox, and date/time/datetime-local/color field wrappers, package-root rendered-field contract helpers, TypeScript declaration metadata for the package root and direct controller entrypoint, Tom Select option pass-throughs, endpoint-side search match strategies, install generator setup-note opt-out, setup doctor status guidance, machine-readable setup doctor JSON output, a dedicated create-success event for create-on-the-fly flows, and opt-in inline request-failure placeholder hooks.

### Highlights

- `rfk_token_search` for token-style query inputs
- `rfk_token_suggestions_with` and `RailsFieldsKit::TokenSuggestions.build`
- `RailsFieldsKit::RansackSuggestions.build` for metadata-only Ransack-compatible suggestions
- `RailsFieldsKit::TableFilterInput`, `RailsFieldsKit::TableCellInput`, `RailsFieldsKit::TableMetadata`, and `RailsFieldsKit::TableRenderer`
- `RailsFieldsKit::TableRenderer.with_field_helpers(...)` for block-scoped helper registry overrides with cleanup after the block
- `rfk_table_filters` and `rfk_table_cell_editors`
- `rfk_range_field` for an ordinary native range input wrapper while leaving live previews, custom slider styling, multi-thumb controls, validation policy, and production CSS in the host application
- `rfk_password_field` for an ordinary native password input wrapper while leaving password-specific UX and credential policy in the host application
- `rfk_file_field` for an ordinary native file input wrapper while leaving upload workflow, validation policy, storage configuration, and production CSS in the host application
- `rfk_check_box` for an ordinary Rails checkbox wrapper while leaving collection groups, radio buttons, validation UI redesign, label placement redesign, and production CSS outside the current public surface
- `rfk_date_field`, `rfk_time_field`, `rfk_datetime_local_field`, and `rfk_color_field` for browser-native wrapper helpers while leaving timezone conversion, masking, custom picker UI, browser normalization, validation policy, locale formatting, and production CSS in the host application
- table metadata collection and renderer robustness fixes for hash-like, object, enumerable, nil, and disabled metadata inputs
- `tomSelectTextOverrideContract(element)` for rendered Tom Select text override values
- `tomSelectPluginContract(element)` for rendered Tom Select plugin data and derived clear/remove flags
- `tomSelectSelectionContract(element)` for initialized Tom Select selection state reads
- `tomSelectRequestContract(element)` for rendered request endpoint and fixed parameter config without executing remote requests
- `tomSelectFieldKindContract(element)` for rendered helper-lane kind reads
- `readRenderedTomSelectInteractionConfig(element)` for rendered Tom Select interaction config reads
- `readRenderedErrorSurface(element)` for resolving rendered opt-in request-failure placeholders
- `readRenderedSelectedPreloadConfig(element)` for rendered selected preload config reads
- `readRenderedOptionPayloadMapping(element)` for rendered option payload mapping reads
- `readRenderedTableFilterMetadata(element)` for rendered table filter metadata reads
- `nativeFieldAccessibilityContract(element)` for rendered native input accessibility wiring, affix elements, and label association
- TypeScript declaration metadata for package-root and direct controller runtime exports
- controller helper `action:` support, `rfk_search_with match:` strategies, selected preload array params, and remote collection wrappers such as `{ options: [...] }` and `{ results: [...] }`
- Tom Select option pass-throughs for `max_items:`, `load_throttle:`, and `delimiter:`
- `rails generate rails_fields_kit:install --skip-setup-notes` to skip only the generated setup-note docs artifact while still creating the initializer
- setup doctor status guidance that separates `[MISSING]` setup fixes from `[MANUAL]` host-app checks while staying read-only
- SetupDoctor JSON output for host-app scripts and release verification, with payload details kept in `doc/setup_doctor_machine_readable.md` and host-app CI policy left to the host application
- `rails-fields-kit--tom-select:create` with `event.detail.input` / `event.detail.option`
- `error_surface:` / `error_surface_html:` with request-failure `event.detail.surface`
- normalized Tom Select failure event detail payloads
- documented request cancellation and stale-response no-event boundaries

### Compatibility

- Rails >= 7.0, < 9.0
- Ruby >= 3.1
- Tom Select must still be installed by the host application

### Responsibility boundary

Rails Fields Kit still stops at UI helpers and metadata. Host applications remain responsible for token parsing, search execution, authorization, pagination, JavaScript package manager or importmap choices, setup-note ownership when `--skip-setup-notes` is used, Tom Select package and CSS checks surfaced as `[MANUAL]` setup doctor reminders, host-app CI pass/fail policy around any SetupDoctor JSON wrapper, long-lived table renderer registry policy outside a scoped override block, range live value previews, custom slider styling, multi-thumb controls, range validation policy, password visibility toggles, strength meters, credential policy, authentication workflow, credential storage, multipart form setup, Active Storage direct upload JavaScript, previews, upload progress UI, file validation policy, storage configuration, virus scanning, checkbox collection/radio group semantics, validation UI redesign, label placement redesign, browser-native date/time picker behavior, timezone conversion, masking, browser normalization, locale formatting, selected preload request execution and visible fallback UI, visible copy and locale policy for rendered text overrides, visible success UI after create-on-the-fly succeeds, visible error or retry UI around any opt-in `error_surface:` placeholder, plugin asset loading and clear/remove affordance styling around rendered Tom Select plugin data, selection mutation and hidden field policy around current selection reads, request execution and endpoint authorization around rendered request contract config, helper taxonomy and interaction policy around rendered field kind and interaction config reads, endpoint response parsing around option payload mapping reads, table search execution around table filter metadata reads, database collation and adapter-specific SQL behavior around endpoint-side search matching, id generation and label text policy around native accessibility wiring, validation feedback and focus management, host-app TypeScript configuration around declaration metadata, and any host-owned loading or retry state around aborted or stale requests. Remote collection wrappers do not make pagination metadata or arbitrary response adapters gem-owned behavior. Multiple selected preload supports Rails array params only after the host app request stack normalizes repeated keys such as `ids[]` into an Array.

### Verification

- `bundle exec standardrb`
- `bundle exec rspec`
- `npm run check:js`
- `bundle exec rake build`
- sample app checklist and CI confirmation for the exact release commit
```