# Rails Fields Kit Final Release Checklist

Use this checklist immediately before publishing a gem release.

## Code and tests

- [ ] Pull latest `main`.
- [ ] Run `bundle install`.
- [ ] Run `bundle exec standardrb`.
- [ ] Run `bundle exec rspec`.
- [ ] Run `npm run check:js` locally; use the GitHub Actions JavaScript matrix as the final Node 22.x / 24.x branch-head confirmation.
- [ ] Run `bundle exec rake build`.
- [ ] Run `BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rspec`.
- [ ] Run `BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle exec rspec`.
- [ ] Confirm the latest GitHub Actions CI run passed for the release commit.
- [ ] Confirm the latest release-prep pull request passed the representative Rails 7.0 / Ruby 3.1 and Rails 8.0 / Ruby 3.3 compatibility jobs.
- [ ] Confirm the built gem path matches the target version, for example `pkg/rails_fields_kit-x.y.z.gem`.
- [ ] Confirm RubyGems validation warnings are understood or resolved.

## Version, changelog, and release notes

- [ ] Confirm `lib/rails_fields_kit/version.rb` matches the intended release.
- [ ] Confirm `CHANGELOG.md` has an entry for the release version and date.
- [ ] Confirm `CHANGELOG.md` has a fresh `Unreleased` section for the next cycle.
- [ ] Prepare or update `doc/release_notes_0_1_1.md` for the current next-release draft. If release planning chooses a different version number, rename that draft and keep `doc/release_notes_0_1_0.md` as the historical reference.
- [ ] Compare the release note draft with `CHANGELOG.md` before publishing: treat `CHANGELOG.md` as the exhaustive release-history source and the release note as the reviewer-facing / GitHub-release-facing summary.
- [ ] Confirm release note highlights are backed by landed `CHANGELOG.md` entries and do not include proposal-only or open-PR behavior.
- [ ] Confirm each recently merged PR has been classified as docs-only sync, spec-only guard, or runtime behavior change before deciding whether it belongs in `CHANGELOG.md`, the release note draft, both, or neither.
- [ ] Confirm stacked PRs are reviewed in merge order so a follow-up or guard PR does not describe behavior before its base PR has landed.
- [ ] Confirm PR-local notes about skipped local checks, connector-only verification, or stale CI are rechecked on the final release candidate instead of copied into release notes.
- [ ] Confirm major 0.1.1 categories are not one-sided between the release notes and changelog: token search, table metadata, JavaScript exports, request lifecycle, install generator setup-note opt-out, and release-scoped event surfaces.
- [ ] If request-failure placeholder support is part of the release scope, confirm `CHANGELOG.md` and `doc/release_notes_0_1_1.md` mention `error_surface:` / `error_surface_html:` and `event.detail.surface` without implying built-in retry UI.

## Documentation

- [ ] Review `README.md`.
- [ ] Review `Product Profile.md`.
- [ ] Review `AGENTS.md`.
- [ ] Review `doc/setup.md`.
- [ ] Review `doc/setup_doctor_machine_readable.md` when structured setup evidence or SetupDoctor Ruby JSON output is in release scope.
- [ ] Review `doc/support_boundary.md`.
- [ ] Review `doc/public_api.md`.
- [ ] Review `doc/select_migration.md`.
- [ ] Review `doc/field_helpers.md`.
- [ ] Review `doc/dependent_query_params.md` when `depends_on:` or `clear_on_dependency_change:` is release-scoped.
- [ ] Review `doc/native_numeric_fields.md` when native numeric wrapper helpers are part of the release surface.
- [ ] Review `doc/native_contact_fields.md` when native contact or native search wrapper helpers are part of the release surface.
- [ ] Review `doc/visual_references.md` as the visual reference family index, and confirm it still matches the README Docs map.
- [ ] Review `doc/visual_reference_index.html` as the one-screen reviewer navigation artifact.
- [ ] Confirm each landed visual reference listed in `doc/visual_references.md` is reachable from `doc/visual_reference_index.html`, and that `README.md` links to the maintained map instead of proposal-only artifacts.
- [ ] Review `doc/tom_select_visual_reference.html`.
- [ ] Review `doc/tom_select_request_failure_visual_reference.html`.
- [ ] Review `doc/tom_select_error_surface_contract_visual_reference.html` as the focused request-failure live-region contract artifact.
- [ ] Review `doc/tom_select_text_override_visual_reference.html`.
- [ ] Review `doc/native_field_visual_reference.html`.
- [ ] Review `doc/native_accessibility_contract_visual_reference.html` as the focused native helper accessibility contract artifact.
- [ ] Review `doc/configuration_wrapper_class_visual_reference.html`.
- [ ] Review `doc/table_metadata_visual_reference.html`.
- [ ] Review `doc/token_search_saved_search_visual_reference.html`.
- [ ] Confirm the static visual reference family above, including the one-screen index, has a representative narrow/mobile viewport pass for wrapping, overflow, state visibility, and readable error surfaces before treating those files as release-ready evidence.
- [ ] Review `doc/controller_helpers.md`.
- [ ] Review `doc/token_suggestions.md`.
- [ ] Review `doc/ransack_suggestions.md`.
- [ ] Review `doc/table_adapters.md`.
- [ ] Review `doc/table_group_html.md` when table metadata helpers use group-level wrappers; keep `doc/table_adapters.md` as the source of truth for table metadata behavior.
- [ ] Review `doc/configuration.md`.
- [ ] Review `doc/default_allow_clear.md` when `default_allow_clear` or field-level `allow_clear:` precedence is release-scoped.
- [ ] Review `doc/events.md`.
- [ ] Review `doc/tom_select_turbo_lifecycle.md`.
- [ ] Review `doc/development.md`.
- [ ] Review `doc/sample_app_checklist.md`.
- [ ] Review `doc/sample_app_results.md`.
- [ ] Review `doc/release.md`.
- [ ] Review `doc/selected_preload_release_gate.md`.
- [ ] Review `doc/package_root_helper_release_evidence.md` as the package-root helper evidence guide, and keep helper names and return-shape details sourced from `doc/public_api.md#javascript-exports` rather than duplicating them in this checklist.
- [ ] Review `doc/release_notes_0_1_1.md` for the current next-release draft.
- [ ] Confirm `README.md` and `doc/public_api.md` still describe both documented JavaScript import paths: `rails_fields_kit` and `rails_fields_kit/tom_select_controller`.
- [ ] Confirm `doc/public_api.md#javascript-exports` is the source of truth for current package-root exports, and that release verification does not treat open-PR or proposal helper names as current public API.
- [ ] Confirm the current package-root export matrix before release:
  - Use this matrix as release-critical representative coverage, not as the full helper inventory; first scan `doc/public_api.md#javascript-exports` and `doc/package_root_helper_release_evidence.md` for the current helper names, return shapes, and evidence lane selection.
  - [ ] `TomSelectController` resolves from `rails_fields_kit` for Stimulus registration.
  - [ ] `tomSelectTextOverrideContract(element)` resolves from `rails_fields_kit`, reads only rendered `noResultsText`, `loadingText`, and `createText` contract values, and keeps visible copy / locale policy as host-app responsibilities.
  - [ ] `tomSelectPluginContract(element)` resolves from `rails_fields_kit`, reads the rendered effective `plugins` list plus derived `hasClearButton` and `hasRemoveButton` flags, and keeps plugin asset loading, clear/remove affordance styling, selection mutation, empty-state copy, Tom Select plugin objects, and Tom Select lifecycle outside the helper evidence lane.
  - [ ] `readRenderedSelectedPreloadConfig(element)` resolves from `rails_fields_kit` as one representative request/config reader lane, with related current helpers such as `tomSelectRequestContract(element)` or `readRenderedTomSelectInteractionConfig(element)` checked through their documented return shapes when release-scoped, without moving request execution, endpoint authorization, selected-preload fallback UI, selector validation, modal / portal layout, or production CSS into the package.
  - [ ] `tomSelectSelectionContract(element)` resolves from `rails_fields_kit` as one representative rendered-state reader lane, with related current helpers such as `tomSelectFieldKindContract(element)`, `readRenderedErrorSurface(element)`, `readRenderedOptionPayloadMapping(element)`, or `readRenderedTableFilterMetadata(element)` checked through their documented return shapes when release-scoped, without mutating selections, redefining helper taxonomy, creating feedback UI, executing endpoints, parsing token strings, running Ransack, or deciding table search behavior.
  - [ ] `nativeFieldAccessibilityContract(element)` resolves from `rails_fields_kit`, reads rendered native helper accessibility contract values such as `describedByIds`, `hintElement`, `errorElement`, and `wrapperElement`, and keeps id generation, validation copy, focus management, and visible feedback as Rails / host-app responsibilities.
- [ ] Confirm future package-root helper exports are documented in `doc/public_api.md#javascript-exports` before being added to this release verification matrix; for release-scoped helpers not covered by the representative rows above, record an evidence location in `doc/sample_app_results.md` or the release PR comment.
- [ ] Confirm token search and table integration docs still distinguish gem responsibilities from host app responsibilities.
- [ ] Confirm release-prep docs, `doc/events.md`, and sample app verification all agree on whether create-on-the-fly success uses a dedicated `rails-fields-kit--tom-select:create` hook or only the generic selection events.
- [ ] For downstream host-app adoption reviews, record the upstream Rails Fields Kit evidence and host-app smoke separately before publishing or recommending a pinned ref:
  - [ ] Upstream evidence comes from current Rails Fields Kit docs and package checks, such as `doc/public_api.md`, `doc/setup.md`, `doc/field_helpers.md`, `doc/controller_helpers.md`, `doc/table_adapters.md`, `doc/events.md`, `doc/configuration.md`, the visual reference index, and JavaScript export smoke checks.
  - [ ] Downstream smoke records the host app surface checked, such as the pinned ref, JavaScript controller wiring, initializer, representative form, preload or selected-value lane, invalid rerender, rollback target, and evidence location.
  - [ ] Keep host-app-specific field names, params, validation copy, authorization, endpoint behavior, and target SHA decisions in the downstream issue or PR rather than treating them as Rails Fields Kit public contract.

## Generated files

- [ ] Run `rails generate rails_fields_kit:install` in a sample app.
- [ ] Confirm `config/initializers/rails_fields_kit.rb` is generated.
- [ ] Confirm `doc/rails_fields_kit_setup.md` is generated.
- [ ] Confirm generated setup notes still point to maintained setup docs and current JavaScript registration expectations.

## Sample app verification

- [ ] Complete `doc/sample_app_results.md`.
- [ ] Confirm the documented JavaScript import paths resolve in the sample app.
- [ ] Confirm Tom Select CSS is loaded.
- [ ] Confirm remote search works.
- [ ] When structured setup evidence is in release scope, record a representative `RailsFieldsKit::SetupDoctor#run(format: :json)` result using `doc/setup_doctor_machine_readable.md` as the payload source of truth; keep CLI `--json`, formal schema, SARIF/JUnit output, auto-fix behavior, and universal host-app CI policy out of this evidence lane.
- [ ] Confirm `doc/visual_references.md` remains accurate as the family index for Tom Select, text override copy, native helper, table metadata, and saved search token visual references.

Record visual reference and sample app evidence in a compact matrix before treating the detailed checks below as complete. Keep the evidence in `doc/sample_app_results.md` or the release PR comment, and include artifact, viewport, state lane, responsibility boundary, and evidence location for each changed or release-critical visual surface.

| Artifact | Viewport checked | State or lane checked | Responsibility boundary confirmed | Evidence location |
| --- | --- | --- | --- | --- |
| `doc/visual_reference_index.html` | desktop + narrow/mobile | task picker, quick links, and reference card scanability | index only guides reviewers to the right static artifact; individual helper behavior stays with the referenced visual file and topic docs | `doc/sample_app_results.md` or release PR comment |
| `doc/tom_select_visual_reference.html` | desktop + narrow/mobile | loading, empty, create, disabled, multi, grouped, autocomplete, preload, tags, tokens, error, and any release-scoped helper lane | host app still owns endpoint behavior, visible feedback copy, retry UI, query parsing, token parsing, and create authorization | `doc/sample_app_results.md` or release PR comment |
| `doc/tom_select_request_failure_visual_reference.html` | desktop + narrow/mobile | hidden placeholder, revealed request failure, selected preload restore failure, create failure, and custom wrapper lanes | Rails Fields Kit exposes an opt-in error surface and event payload; host app still owns retry UI, final visible copy, and request lifecycle policy | `doc/sample_app_results.md` or release PR comment |
| `doc/tom_select_error_surface_contract_visual_reference.html` | desktop + narrow/mobile | hidden live region, host-app-visible feedback, and custom wrapper contract lanes | Rails Fields Kit renders the opt-in live-region contract; host app still owns retry UI, visible copy, and request lifecycle policy | `doc/sample_app_results.md` or release PR comment |
| `doc/tom_select_text_override_visual_reference.html` | desktop + narrow/mobile | field-level copy override and fallback contract lanes | Rails Fields Kit exposes rendered copy contract; host app still owns locale policy and visible copy decisions | `doc/sample_app_results.md` or release PR comment |
| `doc/native_field_visual_reference.html` | desktop + narrow/mobile | prefix, suffix, hint, disabled, readonly, validation error, wrapper customization, and accessibility opt-out lanes | Rails Fields Kit owns wrapper / aria wiring only when enabled; host app still owns validation copy and field semantics | `doc/sample_app_results.md` or release PR comment |
| `doc/native_accessibility_contract_visual_reference.html` | desktop + narrow/mobile | wrapper, label, hint, error, and `aria-describedby` contract-reader lanes | Rails Fields Kit exposes rendered accessibility wiring; host app still owns id generation policy outside rendered helpers, validation copy, focus management, and visible feedback | `doc/sample_app_results.md` or release PR comment |
| `doc/configuration_wrapper_class_visual_reference.html` | desktop + narrow/mobile | initializer-driven wrapper, label, hint, error, control, prefix, and suffix class pass-through lanes | Rails Fields Kit exposes class pass-through and configured wrapper pieces; host app still owns final CSS framework, spacing, and component styling policy | `doc/sample_app_results.md` or release PR comment |
| `doc/table_metadata_visual_reference.html` | desktop + narrow/mobile | filter and editor lanes | Rails Fields Kit exposes metadata / call-spec rendering boundaries without taking over table persistence or query execution | `doc/sample_app_results.md` or release PR comment |
| `doc/token_search_saved_search_visual_reference.html` | desktop + narrow/mobile | saved-search token states | Rails Fields Kit provides token UI and suggestion metadata only; host app still owns parsing, execution, saved-search authorization, and result filtering | `doc/sample_app_results.md` or release PR comment |

- [ ] Confirm `doc/visual_reference_index.html` remains usable at a narrow or mobile viewport, including task picker buttons, quick links, and reference cards without treating index navigation as helper behavior evidence.
- [ ] Confirm `doc/tom_select_visual_reference.html` remains usable at a narrow or mobile viewport, including representative loading, empty, create, disabled, multi, grouped, autocomplete, preload, tags, tokens, and error state cards without text overflow hiding the state meaning.
- [ ] Confirm `doc/tom_select_request_failure_visual_reference.html` remains usable at a narrow or mobile viewport, including hidden placeholder, revealed request failure, selected preload restore failure, create failure, and custom wrapper state cards without implying built-in retry UI or request lifecycle handling.
- [ ] Confirm `doc/tom_select_error_surface_contract_visual_reference.html` remains usable at a narrow or mobile viewport, including the hidden-by-default live region, host-app-visible feedback lane, and custom wrapper attributes without implying built-in retry UI or visible copy ownership.
- [ ] Confirm `doc/tom_select_text_override_visual_reference.html` remains usable at a narrow or mobile viewport, including field-level copy override and fallback contract lanes without clipped labels or hidden state copy.
- [ ] Confirm `doc/native_field_visual_reference.html` remains usable at a narrow or mobile viewport, including prefix, suffix, hint, disabled, readonly, and validation error states with readable labels and feedback copy.
- [ ] Confirm `doc/native_accessibility_contract_visual_reference.html` remains usable at a narrow or mobile viewport, including wrapper, label, hint, error, and `aria-describedby` contract-reader lanes without treating validation UI or focus management as built-in package behavior.
- [ ] Confirm `doc/configuration_wrapper_class_visual_reference.html` remains usable at a narrow or mobile viewport, including configured wrapper, label, hint, error, control, prefix, and suffix class lanes without presenting host-app CSS framework styling as built-in Rails Fields Kit behavior.
- [ ] Confirm `doc/table_metadata_visual_reference.html` remains usable at a narrow or mobile viewport, including filter and editor lanes without clipped control labels, badges, or helper text.
- [ ] Confirm `doc/token_search_saved_search_visual_reference.html` remains usable at a narrow or mobile viewport, including saved-search token states without implying built-in token parsing, saved-search execution, or authorization behavior.
- [ ] Confirm responsive visual-reference checks stay limited to layout overflow, text wrapping, and state visibility rather than changing runtime helper markup or host-app query behavior.
- [ ] Confirm one representative `rfk_select` lane keeps a server-rendered collection-backed selected value stable through edit-form redisplay or validation rerender, while `include_blank:`, representative `disabled:`, and representative `option_html:` stay aligned with current docs and do not depend on remote search or create-on-the-fly hooks.
- [ ] Confirm one representative clearable `rfk_select` lane can return from a selected value to the documented blank or placeholder state with `allow_clear: true` while staying in the collection-backed single-value contract.
- [ ] Confirm one representative `config.default_allow_clear = true` field and one comparable `allow_clear: false` field were recorded in the focused sample-app lane without treating plugin assets, styling, empty-state wording, selection mutation, or Tom Select lifecycle as Rails Fields Kit behavior.
- [ ] Confirm one representative `rfk_autocomplete` lane keeps remote suggestions in the typing-assist role while the submitted value stays free text, without depending on `selected_url:` or create-on-the-fly hooks.
- [ ] Confirm one representative `rfk_multi_select` lane keeps a known collection-backed multiple-value flow, with the submitted value staying an ordinary array of selected IDs or values rather than a tag-entry or free-text creation lane.
- [ ] Confirm one representative `rfk_tags` lane keeps existing tags visible while accepting a new tag or exercising create-on-the-fly evidence, and stays distinct from the ordinary collection-backed `rfk_multi_select` lane.
- [ ] Confirm one representative `rfk_grouped_select` lane preserves the documented optgroup structure while the submitted value stays an ordinary selected ID or value and does not depend on remote search or create-on-the-fly hooks.
- [ ] Confirm one representative `rfk_enum_select` lane preserves the current enum label and value mapping through edit-form redisplay or validation rerender without drifting into a hand-maintained arbitrary collection lane.
- [ ] Confirm one representative native helper lane keeps `wrapper: true` label / hint / prefix / suffix rendering stable through validation rerender, and that a comparable `accessibility: false` example clearly drops the shared automatic wiring.
- [ ] Confirm one representative native helper customization lane preserves field-level `wrapper_html:` / `label_html:` / `hint_html:` / `error_html:` / `control_html:` / `prefix_html:` / `suffix_html:` attributes while `html:` remains scoped to the input element and label / hint / error `aria-describedby` wiring plus error wrapper state stay aligned with `doc/field_helpers.md`.
- [ ] When dependent query params are release-scoped, confirm one feature-specific remote-search lane records fixed-plus-dependency merge, blank omission, default retention versus opt-in clearing, stale-response non-adoption, and reconnect listener cleanup in `doc/sample_app_results.md` or a scoped PR comment. Do not mark manual sample/browser evidence complete from CI or source review alone; record `NOT RUN` or an explicit `DEFERRED` handoff when applicable.
- [ ] Confirm selected preload works in edit forms.
- [ ] Confirm one representative selected preload lane covers saved-ID label restore, `rails-fields-kit--tom-select:selected-load`, `rails-fields-kit--tom-select:selected-load-error`, and any host-app fallback or `error_surface:` boundary together.
- [ ] Confirm one representative multi-value selected preload lane restores visible labels for saved IDs and still uses the documented `selected_multiple_param:` or comma-separated `ids` contract when the endpoint relies on it.
- [ ] Confirm create-on-the-fly works.
- [ ] Confirm create-on-the-fly success dispatched `rails-fields-kit--tom-select:create` before the normal selection events when that hook is part of the release surface.
- [ ] Confirm `event.detail.input` and `event.detail.option` exposed the expected payload for the representative create success flow.
- [ ] Confirm one representative create-on-the-fly failure lane covers `rails-fields-kit--tom-select:create-error`, host-app fallback or retry UI, and any `error_surface:` boundary together.
- [ ] Confirm request-failure events expose `event.detail.surface` when `error_surface:` is part of the release surface.
- [ ] Confirm at least one representative `error_surface_html:` lane keeps its custom class or wrapper attrs without losing the shared placeholder `id`, hidden default, `role`, `aria-live`, or `aria-atomic` contract.
- [ ] Confirm one representative `tomSelectTextOverrideContract(element)` lane imports the helper from `rails_fields_kit`, reads the documented `noResultsText`, `loadingText`, and `createText` rendered contract from a field-level override example and a fallback example, and keeps visible copy and locale policy as host-app responsibilities.
- [ ] Confirm one representative Turbo reconnect lane covers page replacement or same-form revisit without duplicate Tom Select initialization, confirms pending load / selected-load / create requests are aborted or ignored on disconnect, and verifies selected preload or remote search still works after reconnect without a host-app reinitializer.
- [ ] Confirm visible success UI remained a host-app responsibility rather than a built-in Rails Fields Kit surface.
- [ ] Confirm visible error or retry UI around any opt-in `error_surface:` placeholder remained a host-app responsibility.
- [ ] Confirm token search and token suggestion endpoints are covered if they are part of the release surface.
- [ ] Confirm table metadata helpers or call-spec rendering paths are covered if they are in scope for the release.
- [ ] Confirm validation and authorization failures return expected status codes.

## Publishing

- [ ] Confirm RubyGems MFA is available.
- [ ] Confirm `allowed_push_host` is `https://rubygems.org`.
- [ ] Run `bundle exec rake release` only when ready.
- [ ] Confirm the published gem is visible on RubyGems.
- [ ] Create a GitHub Release using the version-specific release note draft if desired.

## Post-release

- [ ] Start the next development cycle in `CHANGELOG.md`.
- [ ] Prepare the next release note draft as needed.
- [ ] Record any sample app findings as issues or follow-up tasks.
