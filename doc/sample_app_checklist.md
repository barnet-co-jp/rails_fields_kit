# Rails Fields Kit Sample App Checklist

Use this checklist before publishing a release.

## Choose where to record evidence

Use the checklist below to decide what to exercise, then record only the evidence needed for the release or PR under review. Keep release-wide evidence in [`sample_app_results.md`](sample_app_results.md). For a narrow PR that is not a release candidate, a PR comment is enough when it names the checked lane, branch or commit, and result.

When package-root read-only helper exports are in scope, use [`package_root_helper_release_evidence.md`](package_root_helper_release_evidence.md) to choose representative helper checks before recording the result.

When setup doctor JSON output is in scope, use [`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md) as the payload source of truth before recording evidence. Keep the evidence representative: branch or commit checked, Ruby API call used, observed `summary["missing"]`, and whether manual advisory checks were reviewed as host-app responsibilities.

When TableMetadata collection source shapes are in scope, use [`table_metadata_collection_evidence.md`](table_metadata_collection_evidence.md) to choose representative hash-like, table-like, and explicit false checks before recording the result.

When checkbox table metadata is in scope, use [`table_check_box_metadata.md`](table_check_box_metadata.md) as the source-of-truth boundary before recording table metadata evidence. Keep `TableFilterInput.check_box` / `TableCellInput.check_box` evidence in the table metadata lane, separate from native `rfk_check_box` wrapper evidence.

When file field table metadata is in scope, use [`table_file_field_metadata.md`](table_file_field_metadata.md) as the source-of-truth boundary before recording table metadata evidence. Keep `TableCellInput.file_field` evidence in the cell-editor metadata lane, and do not add `TableFilterInput.file_field` evidence because upload controls are not filter/query helpers.

When a shared field/operator metadata source feeds token suggestions, Ransack suggestions, and table filter metadata, use [`shared_metadata_navigation.md#sample-app-and-release-evidence-lane`](shared_metadata_navigation.md#sample-app-and-release-evidence-lane) as the evidence source of truth so the release note stays in the current builders lane instead of implying a registry API.

When the `rfk_text_area` autosize boundary is in scope, use [`textarea_autosize_release_evidence.md`](textarea_autosize_release_evidence.md) with the native helper lane so release notes do not treat host-owned autosize enhancement as Rails Fields Kit behavior.

| Lane | Record in `sample_app_results.md` when... | PR comment is enough when... | Evidence to capture |
| --- | --- | --- | --- |
| Release baseline | Preparing a release candidate or release PR | Never; keep release baseline evidence in the results file | version, tester, gem source, branch head CI, local checks, generator result |
| Host-app setup and package-root exports | Setup, importmap, bundler, Stimulus registration, generated notes, setup doctor JSON output, or package-root helper exports are in release scope | A narrow docs/spec PR only confirms one export, setup note signal, or representative JSON payload lane | import path or command checked, setup doctor JSON `summary["missing"]` and manual advisory review when relevant, package-root helper evidence guide lane when relevant, branch/commit, pass/fail notes; screenshots are not expected unless a visual surface changed |
| Visual references | A static visual reference, one-screen index, visual lane, or release-critical rendered state changed | A small visual docs PR needs review notes before release evidence is collected | artifact, viewport, state or lane, responsibility boundary, evidence location |
| Native, remote, token, table, Turbo, and event lanes | The release candidate depends on that behavior family | A focused feature PR checks one representative lane and does not claim release readiness | lane name, representative field or endpoint, observed event/result, host-app responsibility boundary |
| Deferred or blocked evidence | A release candidate intentionally carries known caveats | A PR needs human visual/browser verification or a follow-up issue | blocker, required human check, follow-up issue or PR link |

### Choose the representative lane for a narrow PR

Use this chooser before copying checklist items into a PR comment. Pick the smallest row that matches the change, then jump to the named checklist section below. Do not mark release readiness unless the release baseline row is also in scope.

| Change in scope | Start with this checklist lane | Evidence usually recorded in | Keep out of scope for the narrow PR |
| --- | --- | --- | --- |
| Setup docs, generated notes, importmap/jsbundling visibility, setup doctor JSON output, or package-root helper import/read-only contract | `Host-app setup and package-root exports`, then `Verify setup doctor JSON evidence`, `JavaScript setup checks`, or the helper-specific evidence guide | PR comment for narrow docs/spec work; `sample_app_results.md` for release candidates | visual screenshots, request execution, helper behavior not changed by the PR, full JSON schema mirrors, or universal host-app CI pass/fail policy |
| Static visual reference HTML, one-screen index, or visual reference map wording | `Visual references`, then `Visual reference render checks` | PR comment when browser-capable review is still pending; `sample_app_results.md` for release-critical artifact changes | runtime CSS, production helper markup, or CI success as visual approval |
| Native wrapper, accessibility, constraint attributes, generated described-by id boundary, or field-level customization | `Native helper representative wrapper and accessibility lane checks` and the native customization lane | PR comment for a focused helper/docs PR; release evidence only when the release depends on the lane | Tom Select request lifecycle, masking, validation-message policy, server-side validation |
| `rfk_text_area` autosize boundary or host-owned autosize enhancement notes | `Native helper representative wrapper and accessibility lane checks`, then `textarea_autosize_release_evidence.md` | PR comment for a focused docs PR; `sample_app_results.md` for release candidates | built-in `autosize:` option, JavaScript measurement, production CSS preset, Turbo reconnect sizing hook |
| Remote search, selected preload, create-on-the-fly, request-failure feedback, Turbo, or events | The matching remote lifecycle, visible feedback, Turbo, or event lane | PR comment for one representative field; release results when the behavior is release-critical | endpoint authorization policy, retry UI, visible copy ownership unless the PR changes that surface |
| Token suggestions, Ransack suggestions, table filters, cell editors, checkbox table metadata, file field table metadata, or TableMetadata collection shape | `Token suggestion and Ransack suggestion metadata` or `Verify table metadata adapters` | PR comment for scoped metadata/docs work; release evidence for release candidates | query execution, parser semantics, boolean query policy, checked-value interpretation, file upload execution, multipart form policy, Active Storage direct upload, preview UI, preference persistence, or table integration redesign |

Avoid duplicating the whole checklist into a PR comment. Use the comment for scoped evidence and use `sample_app_results.md` as the primary release evidence log.

## Prepare a Rails app

Use a Rails 7+ application with Stimulus enabled.

```bash
rails new rfk_sample --javascript=esbuild
cd rfk_sample
```

Point the sample app Gemfile at the local checkout or built gem.

```ruby
gem "rails_fields_kit", path: "../rails_fields_kit"
```

Install dependencies:

```bash
bundle install
yarn add tom-select
```

## Install Rails Fields Kit

```bash
rails generate rails_fields_kit:install
```

Confirm these files are created:

- `config/initializers/rails_fields_kit.rb`
- `doc/rails_fields_kit_setup.md`

Confirm the generated setup notes still match the maintained walkthrough in `doc/setup.md` and the documented JavaScript registration flow.

## Verify setup doctor JSON evidence

Use this lane only when structured setup visibility is in release or PR scope. Keep the runtime payload contract in [`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md); this checklist records what was observed for the branch under review.

```ruby
output = StringIO.new
RailsFieldsKit::SetupDoctor.new.run(io: output, format: :json)
payload = JSON.parse(output.string)
```

Verify:

- the evidence names the branch or commit checked and the Ruby API call used
- `summary["missing"]` was recorded as the representative required setup signal
- manual advisory checks were reviewed as host-app follow-up items rather than automatic Rails Fields Kit failures
- evidence notes link back to `setup_doctor_machine_readable.md` instead of copying the full payload schema
- CLI `--json`, auto-fix behavior, formal schema publication, SARIF / JUnit output, and universal host-app CI pass/fail policy stayed out of scope

## Register JavaScript

Register the controller:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

Confirm both documented import paths resolve in the sample app:

```js
import { TomSelectController } from "rails_fields_kit"
import DirectTomSelectController from "rails_fields_kit/tom_select_controller"

console.assert(TomSelectController === DirectTomSelectController)
```

If the sample app uses a bundler alias or custom resolver, confirm it still resolves those documented import paths rather than an app-specific private path or an undocumented pin name.

If the sample app uses importmap, confirm the documented `config/importmap.rb` pins for `rails_fields_kit` and `rails_fields_kit/tom_select_controller` resolve without switching to a private asset path or an undocumented pin name.

If the sample app uses importmap, confirm the documented controller registration still works from the app's existing Stimulus boot file after those pins are added.

Load Tom Select CSS:

```js
import "tom-select/dist/css/tom-select.css"
```

## Verify form helpers

Create a form that exercises:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_lookup` with separate text and `id_field:` params
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- `rfk_token_search`
- native helpers such as `rfk_text_field` and `rfk_money_field`

## Verify native wrapper customization

Use one representative native helper with `wrapper: true` and field-level wrapper customization options.

Verify:

- `wrapper_html:` can add a representative class or `data` attribute to the outer wrapper while keeping the configured `wrapper_class`
- `label_html:`, `hint_html:`, and `error_html:` can add representative attributes without losing generated label, hint, or validation error behavior
- `control_html:`, `prefix_html:`, and `suffix_html:` can add representative attributes on an affix field without changing the input value or submitted param shape
- `html:` still targets the input element itself, separate from generated wrapper pieces
- generated hint / error ids and any custom input `id:` boundary match [`field_helpers.md#generated-described-by-ids`](field_helpers.md#generated-described-by-ids) for the representative field without turning the checklist into a full generated-id inventory
- hint / error ids still feed the shared accessibility wiring when `accessibility:` remains enabled
- `accessibility: false` remains an explicit opt-out from automatic aria wiring only, not from the wrapper customization lane
- repo-wide class defaults from the initializer still provide the shared baseline; field-level `*_html` options only layer additional attributes for that field

## Verify `collection_select` migration path

Create at least one server-rendered form that starts from the documented `collection_select` example in [`select_migration.md`](select_migration.md), then swap it to `rfk_select` and confirm:

- the same model attribute still drives the selected value on first render, edit forms, and validation rerender
- `include_blank:` keeps the documented blank-option behavior from the migration guide
- representative `disabled:` options still render and behave as expected after the helper swap
- representative grouped options still render correctly after the helper swap
- representative `option_html:` data or HTML attributes still reach the rendered options after the helper swap
- the migration path stays aligned with the helper reference in `field_helpers.md` and the public API summary in `public_api.md`

## Verify `rfk_select` representative collection-backed single-value lane

Use one representative `rfk_select` field backed by a server-rendered collection and keep that same field outside remote search, selected preload, and create-on-the-fly lanes.

Verify that same field can demonstrate the collection-backed single-value contract end to end:

- the representative field renders the current selected value from the documented server-rendered collection lane
- if the representative field enables `allow_clear: true`, clearing that selected value returns the field to the documented blank or placeholder state
- clearing the representative field still stays in the collection-backed single-value contract rather than drifting into a remote-search, token-metadata, or create-on-the-fly lane
- an edit form or validation rerender keeps the same selected value on that representative field
- representative `include_blank:` still exposes the documented blank-option behavior for that lane
- representative `disabled:` options and `option_html:` attributes remain visible on that field without changing it into a remote-search or token-metadata lane
- the representative field does not depend on `url:`, `selected_url:`, or `create_url:` to remain understandable in the sample app

## Verify controller helpers

Add a controller with:

- `include RailsFieldsKit::Searchable`
- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`
- `rfk_token_suggestions_with`

Verify:

- remote search returns options
- the representative selected preload lane below can load selected labels through `selected_url:` and receives any fixed `selected_query_params:` it relies on
- create-on-the-fly adds a newly-created option
- token suggestion endpoints return option JSON for `rfk_token_search`
- at least one representative non-default `action:` route still works from the documented route shape, such as `rfk_find_with action: :selected` or `rfk_token_suggestions_with action: :search_tokens`
- fixed `query_params:` reach representative remote search requests when the field relies on request context
- fixed `create_params:` are merged into representative create-on-the-fly requests when the field relies on them
- wrapped responses work with `options` / `option` when the helper flow relies on them
- rich option payloads return representative `description` / `badge` data when the UI depends on them
- validation errors return `422`
- authorization failures return `403`

If the release surface includes `RailsFieldsKit::RansackSuggestions.build`, also confirm the sample endpoint can return the expected predicate metadata without handing query parsing to the gem.

## Verify selected preload representative lane

Use one representative server-rendered edit-form field with `selected_url:` and whatever host-app fallback UI or `error_surface:` wiring the release expects to support.

Verify that same field can demonstrate the full selected preload lane end to end:

- saved ID only initial state restores the selected label through `selected_url:`
- representative fixed `selected_query_params:` still reach the selected preload request when the integration relies on request context
- `rails-fields-kit--tom-select:selected-load` is observed for the success path before the field settles into its normal selected state
- a representative failure path leaves user-understandable host-app fallback or visible feedback after `rails-fields-kit--tom-select:selected-load-error`
- if the field uses `error_surface: true`, the selected preload failure path still exposes the expected inline placeholder through `event.detail.surface`
- a Turbo-driven validation rerender or same-form revisit still restores the label for that same representative field when `selected_url:` is configured
- one representative multiple-value field with `selected_url:` restores visible labels for saved IDs instead of leaving a raw ID-only state
- if that multiple-value lane relies on a custom `selected_multiple_param:`, the selected preload request still uses the documented key, and a comparable endpoint still accepts comma-separated `ids`

## Verify create-on-the-fly representative failure lane

Use one representative field with `create_url:` and whatever host-app fallback UI or `error_surface:` wiring the release expects to support.

Verify that same field can demonstrate the create-on-the-fly failure lane end to end:

- a failed create request dispatches `rails-fields-kit--tom-select:create-error`
- the representative failure path leaves host-app fallback copy or retry UI visible near the field
- if the field uses `error_surface: true`, the failure path still exposes the expected inline placeholder through `event.detail.surface`
- a follow-up success or fresh interaction clears stale inline failure UI for that same field
- retry policy and final visible copy still remain a host-app responsibility rather than a built-in Rails Fields Kit behavior

## Verify `rfk_autocomplete` representative suggestion-only lane

Use one representative `rfk_autocomplete` field with remote suggestions and keep that same field outside the `selected_url:` and create-on-the-fly lanes.

Verify that same field can demonstrate the suggestion-only contract end to end:

- remote suggestions appear as typing assist for the representative field
- choosing a suggestion still leaves the submitted value as free text rather than a selected ID or created record payload
- a normal submit, edit-form redisplay, or validation rerender keeps that same field in the free-text helper lane
- the representative field does not depend on `selected_url:` or `create_url:` to remain understandable in the sample app

## Verify `rfk_multi_select` representative collection-backed lane

Use one representative `rfk_multi_select` field backed by a known collection and keep that same field outside tag-entry or create-on-the-fly lanes.

Verify that same field can demonstrate the collection-backed multiple-value contract end to end:

- the representative field selects multiple known values from the documented collection-backed lane
- the submitted value stays an ordinary array of selected IDs or values rather than tag-entry or free-text creation payload
- an edit form or validation rerender keeps the same selected values on that representative field
- the representative field does not depend on `create_url:` or token-style parsing to remain understandable in the sample app

## Verify `rfk_tags` representative tag-entry lane

Use one representative `rfk_tags` field for tag entry and keep that same field separate from the ordinary collection-backed `rfk_multi_select` lane.

Verify that same field can demonstrate the tag-entry contract end to end:

- the representative field keeps existing tags visible while a new tag is typed or accepted
- when `create_url:` is enabled for that field, the evidence records either a successful created tag or the deliberate create-on-the-fly failure path for the same tag-entry lane
- an edit form or validation rerender keeps the same tags visible on that representative field
- when the field relies on saved IDs, `selected_url:` restores visible labels without leaving a raw ID-only state
- the submitted value and evidence notes stay in the tag-entry / create-on-the-fly lane rather than drifting into the ordinary collection-backed `rfk_multi_select` lane
- endpoint authorization, created-record policy, retry UI, and final visible copy remain host-app responsibilities rather than built-in Rails Fields Kit behavior

## Verify `rfk_grouped_select` representative optgroup-preserving lane

Use one representative `rfk_grouped_select` field backed by grouped server-rendered collections and keep that same field outside remote search or create-on-the-fly lanes.

Verify that same field can demonstrate the optgroup-preserving contract end to end:

- the representative field renders the documented grouped collection with its current optgroup structure intact
- choosing a value keeps the submitted value in the ordinary selected ID or value lane rather than a remote-search or token-metadata lane
- an edit form or validation rerender keeps the same selected value while preserving the grouped labels for that representative field
- the representative field does not depend on `url:`, `selected_url:`, or `create_url:` to remain understandable in the sample app

## Verify `rfk_enum_select` representative enum-backed lane

Use one representative `rfk_enum_select` field backed by a current Rails enum attribute and keep that same field outside arbitrary hand-maintained collections or remote search lanes.

Verify that same field can demonstrate the enum-backed contract end to end:

- the representative field renders the current enum labels and values from the model-backed enum lane
- choosing a value keeps the submitted value in the ordinary enum-backed selected-value lane rather than a free-text or created-record lane
- an edit form or validation rerender keeps the same selected enum value and redisplays the matching label for that representative field
- the representative field remains clearly tied to the enum-backed attribute rather than a hand-maintained collection helper lane

## Verify token suggestion and Ransack suggestion metadata

Create at least one token suggestion endpoint that uses `rfk_token_suggestions_with(..., wrap: "options")` and confirm:

- operator suggestions such as `OR` or `not()` are returned with the documented option fields
- field suggestions such as `status:` and `assignee:` match the current labels and descriptions from `doc/token_suggestions.md`
- value suggestions such as `status:open` and `status:closed` are returned when the field configuration includes values
- saved-search suggestions such as `saved:mine` are returned with the expected label and optional description
- the endpoint still returns suggestion metadata only, and submitted token parsing remains a host-app responsibility

If the release surface includes `RailsFieldsKit::RansackSuggestions.build`, also confirm:

- the response exposes `ransack_predicate` and `ransack_field` metadata on field suggestions
- value suggestions preserve `ransack_value` and any documented extra metadata
- the same allowed field list drives both the documented suggestion builder config and the host-app parser whitelist from `doc/ransack_suggestions.md`
- submitted token text is turned into `params[:q]` by the host app parser or search object, not by Rails Fields Kit
- the sample app treats that payload as metadata for a parser or search object, not as query execution performed by the gem

## Verify visible feedback surfaces

Rails Fields Kit does not choose user-facing copy for the host app. In the sample app, confirm at least one searchable field exercises the visible states that your release expects to rely on:

- `placeholder` copy reads naturally before the user interacts with the field
- `loading_text` appears while remote search is in flight and clears after the response returns
- `no_results_text` appears for empty search responses instead of leaving the dropdown blank
- `create_text` appears with the intended wording when create-on-the-fly is enabled
- failed inline create requests surface visible host-app feedback after `rails-fields-kit--tom-select:create-error`
- at least one field with `error_surface: true` exposes a stable inline placeholder from `load-error`, `selected-load-error`, or `create-error`
- at least one field with custom `error_surface_html:` keeps its representative wrapper class or attrs without losing the shared placeholder `id`, hidden default, `role`, `aria-live`, or `aria-atomic` contract
- request-failure events for that custom placeholder field still expose the same inline placeholder through `event.detail.surface`
- success or a follow-up interaction clears stale inline error content from that placeholder
- a comparable field without `error_surface: true` keeps the default no-inline-placeholder behavior

## Verify table metadata adapters

Create a minimal table definition that exercises:

- `RailsFieldsKit::TableFilterInput.combobox` or `RailsFieldsKit::TableFilterInput.token_search`
- `RailsFieldsKit::TableFilterInput.check_box` or `RailsFieldsKit::TableCellInput.check_box` when checkbox table metadata is in release or PR scope
- `RailsFieldsKit::TableCellInput.file_field` when file field table metadata is in release or PR scope
- `RailsFieldsKit::TableCellInput.enum_select` or another current editor helper
- `rfk_table_filters`
- `rfk_table_cell_editors`

Verify:

- collected filter metadata renders through the documented helper path
- collected cell editor metadata renders through the documented helper path
- native metadata such as `TableFilterInput.search_field`, `money_field`, `text_area`, or `check_box` also renders through the documented helper path when the integration uses common field helpers
- checkbox table metadata, when in scope, keeps `checked_value:` / `unchecked_value:` as Rails checkbox helper contract evidence and stays separate from the native `rfk_check_box` wrapper lane
- checkbox table metadata evidence does not imply boolean query semantics, tri-state filtering, bulk edit persistence, table preference persistence, or authorization policy ownership by Rails Fields Kit
- file field table metadata, when in scope, keeps `accept:`, `multiple:`, and `direct_upload:` as Rails file helper option pass-through evidence and stays in the cell-editor metadata lane
- file field table metadata evidence does not imply `TableFilterInput.file_field`, multipart form policy, Active Storage direct upload JavaScript, preview UI, upload progress UI, table persistence, query execution, file validation policy, storage configuration, virus scanning, authorization, or production CSS ownership by Rails Fields Kit
- any direct `TableRenderer.filter_call` or `TableRenderer.cell_editor_call` usage in your integration still matches the documented call-spec shape
- a representative `TableRenderer.register_field_helper` mapping can be rendered through the documented call-spec path, and `TableRenderer.reset_field_helpers!` restores the default mapping after that scoped customization
- token search or Ransack-oriented metadata, if used, is still treated as UI metadata or rendering assistance rather than query execution
- representative query execution and preference persistence still belong to the host app or table integration rather than Rails Fields Kit

## Verify Turbo reconnect

Use a server-rendered form with at least one `rfk_combobox` or `rfk_tags` field and confirm:

- the field initializes on the first render without a host-app `setupXxx()` helper
- a Turbo-driven validation rerender or same-form revisit reconnects Tom Select on the replaced element
- the sample app does not add a separate `turbo:load` reinitializer just for Rails Fields Kit fields

## Verify events

Listen for the events documented in [`events.md`](events.md):

- `rails-fields-kit--tom-select:load`
- `rails-fields-kit--tom-select:load-error`
- `rails-fields-kit--tom-select:selected-load`
- `rails-fields-kit--tom-select:selected-load-error`
- `rails-fields-kit--tom-select:create`
- `rails-fields-kit--tom-select:create-error`
- `rails-fields-kit--tom-select:change`
- `rails-fields-kit--tom-select:item-add`
- `rails-fields-kit--tom-select:item-remove`
- `rails-fields-kit--tom-select:clear`

For selected preload, confirm:

- the representative `selected_url:` field dispatches `rails-fields-kit--tom-select:selected-load` after selected labels are resolved
- `event.detail.values` matches the requested saved value or values, and `event.detail.options` contains the resolved option payloads
- a representative selected preload failure dispatches `rails-fields-kit--tom-select:selected-load-error` separately from remote search and create-on-the-fly failures
- selected preload success and failure checks stay tied to the selected preload lane rather than the ordinary remote search `load` / `load-error` lane

For interaction forwarding, keep at least one representative lane outside remote request lifecycle and visible-feedback checks, then confirm:

- a single select or combobox dispatches `rails-fields-kit--tom-select:change` when the selected value changes
- a multiple select or tags field dispatches `rails-fields-kit--tom-select:item-add` and `rails-fields-kit--tom-select:item-remove` for representative add/remove actions
- a clearable field dispatches `rails-fields-kit--tom-select:clear` when the current value is cleared
- the event listener records the forwarding events separately from `load`, `load-error`, `selected-load`, `selected-load-error`, `create`, `create-error`, and visible-feedback lanes

For create-on-the-fly success, confirm:

- the dedicated `rails-fields-kit--tom-select:create` hook is observed before the normal selection events continue
- `event.detail.input` matches the submitted text
- `event.detail.option` contains the created option payload the host app needs to inspect
- `rails-fields-kit--tom-select:item-add` and `rails-fields-kit--tom-select:change` still describe the accepted selection after create succeeds

When `error_surface: true` is part of the release surface, also verify the request-failure events above expose `event.detail.surface` for the opted-in field and leave it `null` for a comparable non-opt-in field.

## Release gate

Before release, confirm the current local check set:

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
```

Then perform the sample app checks above, record the result in `doc/sample_app_results.md`, and confirm GitHub Actions is green for the same branch head once the change is ready for review or release.
