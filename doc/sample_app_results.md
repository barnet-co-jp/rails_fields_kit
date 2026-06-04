# Rails Fields Kit Sample App Results

Use this file to record manual verification results before publishing a release.

Use the route map below to choose the evidence lane for the release or PR under review. Keep release-wide checks separate from feature-specific evidence; this file records what was manually verified, not a new release gate or runtime contract.

| Review goal | Start with | Use when |
| --- | --- | --- |
| Release-wide confidence | Target release, local gem checks, branch head CI confirmation, generator checks | Every release candidate or release PR needs baseline package, CI, and generator evidence. |
| JavaScript setup | JavaScript setup checks, event checks, Turbo reconnect checks | The release touches package-root exports, Stimulus registration, importmap/jsbundling setup, events, or reconnect behavior. |
| Native wrapper and accessibility | Form helper checks, native helper representative wrapper and accessibility lane checks, native wrapper customization checks | Native helper wrapper, class, hint/error, affix, or accessibility wiring changed. |
| Visual reference review | Visual reference render checks | Static HTML visual references or the one-screen visual reference index changed. |
| Remote lifecycle feedback | Selected preload representative lane checks, create-on-the-fly representative failure lane checks, visible feedback checks | Selected preload, remote search, create-on-the-fly, request-failure, or visible fallback behavior changed. |
| Token and table metadata | Token suggestion and Ransack suggestion metadata checks, table metadata checks | Token suggestions, saved-search metadata, Ransack metadata, table filters, or cell editor metadata changed. |

## Target release

- Version:
- Date:
- Tester:
- Sample app Rails version:
- Ruby version:
- Gem source:
  - [ ] local path checkout
  - [ ] built gem package
  - [ ] other:
- JavaScript setup:
  - [ ] esbuild
  - [ ] jsbundling-rails
  - [ ] importmap
  - [ ] other:

## Local gem checks

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
```

Result:

- [ ] StandardRB passed
- [ ] RSpec passed
- [ ] Gem build passed
- [ ] No RubyGems validation warnings

Notes:

## Branch head CI confirmation

- Branch / PR:
- Commit SHA:
- Workflow run URL:
- [ ] GitHub Actions passed for the same branch head reviewed in this checklist

Notes:

## Generator checks

```bash
rails generate rails_fields_kit:install
```

Result:

- [ ] `config/initializers/rails_fields_kit.rb` generated
- [ ] `doc/rails_fields_kit_setup.md` generated
- [ ] generated setup notes match current public API and setup walkthrough

Notes:

## JavaScript setup checks

- [ ] Tom Select package installed
- [ ] `import { TomSelectController } from "rails_fields_kit"` resolved
- [ ] `import { nativeFieldAccessibilityContract } from "rails_fields_kit"` resolved
- [ ] `import TomSelectController from "rails_fields_kit/tom_select_controller"` resolved
- [ ] documented controller registration succeeded
- [ ] importmap pins resolved `rails_fields_kit` and `rails_fields_kit/tom_select_controller` when importmap was used
- [ ] documented controller registration still worked from the existing Stimulus boot file after adding those importmap pins
- [ ] at least one rendered native helper field was readable through `nativeFieldAccessibilityContract(element)` without adding a new package-root helper export
- [ ] Tom Select CSS loaded
- [ ] browser console has no import errors

Notes:

## Form helper checks

- [ ] `rfk_select`
- [ ] `rfk_combobox`
- [ ] `rfk_autocomplete`
- [ ] `rfk_tags`
- [ ] `rfk_multi_select`
- [ ] `rfk_grouped_select`
- [ ] `rfk_enum_select`
- [ ] `rfk_token_search`
- [ ] native helpers such as `rfk_text_field` and `rfk_money_field`

Notes:

## Visual reference render checks

Use this section when the release or PR changes one of the static visual reference HTML files.

- Changed visual reference file(s):
- Rendered artifact or screenshot link(s):

Use the matrix below for changed or release-critical visual references before treating the checkbox pass as complete. Keep static visual artifact evidence separate from runtime sample-app lanes; the matrix records what was rendered, not new helper behavior.

| Artifact | Viewport checked | State or lane checked | Responsibility boundary confirmed | Evidence location |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |

- [ ] desktop viewport checked for state visibility, readable labels, and expected spacing
- [ ] narrow/mobile viewport checked for wrapping, overflow, state visibility, and readable feedback copy
- [ ] review notes call out any intentionally deferred visual follow-up instead of treating CI green as visual approval

Notes:

## Native helper representative wrapper and accessibility lane checks

- [ ] one representative native helper field covered the end-to-end `wrapper: true` lane
- [ ] the field rendered the documented label, hint, prefix, and suffix while staying in the native helper family rather than a Tom Select lane
- [ ] `nativeFieldAccessibilityContract(element)` read the representative field's rendered `describedByIds`, `hintElement`, `errorElement`, and `wrapperElement` contract from package-root import code
- [ ] an edit form or validation rerender kept the same value and preserved the shared wrapper / accessibility wiring for that representative field
- [ ] a comparable `accessibility: false` example clearly removed the automatic accessibility wiring that the release docs treat as opt-out behavior

Notes:

## Native wrapper customization checks

- [ ] `wrapper_html:` added a representative class or `data` attribute to the outer wrapper while keeping the configured `wrapper_class`
- [ ] `label_html:`, `hint_html:`, and `error_html:` added representative attributes without losing generated label, hint, or validation error behavior
- [ ] `control_html:`, `prefix_html:`, and `suffix_html:` added representative attributes on an affix field without changing the input value or submitted param shape
- [ ] `html:` still targeted the input element itself, separate from generated wrapper pieces
- [ ] hint / error ids still fed the shared accessibility wiring when `accessibility:` remained enabled
- [ ] `accessibility: false` stayed an explicit opt-out from automatic aria wiring only, not from the wrapper customization lane
- [ ] repo-wide initializer class defaults still provided the shared baseline while field-level `*_html` options only layered additional attributes for that field

Notes:

## `collection_select` migration checks

- [ ] documented `collection_select` to `rfk_select` swap preserved the same submitted attribute and redisplay behavior
- [ ] `include_blank:` kept the expected blank-option behavior from `doc/select_migration.md`
- [ ] representative `disabled:` options still rendered and behaved as expected
- [ ] representative grouped options still rendered correctly
- [ ] representative `option_html:` data or HTML attributes still reached the rendered options
- [ ] the migration path stayed aligned with `doc/field_helpers.md` and `doc/public_api.md`

Notes:

## `rfk_select` representative collection-backed single-value lane checks

- [ ] one representative `rfk_select` field covered the end-to-end collection-backed single-value lane
- [ ] the field rendered the current selected value from the documented server-rendered collection lane
- [ ] if that representative field enabled `allow_clear: true`, clearing the selected value returned it to the documented blank or placeholder state
- [ ] clearing the representative field still kept it in the collection-backed single-value contract rather than drifting into a remote-search, token-metadata, or create-on-the-fly lane
- [ ] an edit form or validation rerender kept the same selected value on that representative field
- [ ] representative `include_blank:` still exposed the documented blank-option behavior for that lane
- [ ] representative `disabled:` options and `option_html:` attributes remained visible on that field without drifting into a remote-search or token-metadata lane
- [ ] the representative field stayed independent from `url:`, `selected_url:`, and `create_url:`

Notes:

## Controller helper checks

- [ ] `rfk_search_with` returns remote options
- [ ] the representative selected preload lane below can load selected labels through `selected_url:` and receives any fixed `selected_query_params:` it relies on
- [ ] `rfk_create_with` creates options on the fly
- [ ] `rfk_token_suggestions_with` returns token suggestion option JSON
- [ ] at least one representative non-default `action:` route still worked from the documented route shape
- [ ] fixed `query_params:` reached representative remote search requests
- [ ] fixed `create_params:` were merged into representative create-on-the-fly requests
- [ ] validation errors return `422`
- [ ] authorization failures return `403`
- [ ] wrapped responses work with `options` / `option`
- [ ] rich fields return description and badge data
- [ ] Ransack-compatible suggestion metadata works as expected if it is part of the release surface

Notes:

## Selected preload representative lane checks

- [ ] one representative edit-form field with `selected_url:` covered the end-to-end selected preload lane
- [ ] saved ID only initial state restored the selected label through `selected_url:`
- [ ] representative fixed `selected_query_params:` still reached the selected preload request
- [ ] `rails-fields-kit--tom-select:selected-load` was observed before the field settled into its normal selected state
- [ ] a representative failure path left user-understandable host-app fallback or visible feedback after `rails-fields-kit--tom-select:selected-load-error`
- [ ] if that field used `error_surface: true`, the selected preload failure path still exposed the expected inline placeholder through `event.detail.surface`
- [ ] a Turbo-driven validation rerender or same-form revisit still restored the label for that same representative field
- [ ] one representative multiple-value field with `selected_url:` restored visible labels for saved IDs instead of leaving a raw ID-only state
- [ ] if that multiple-value lane relied on a custom `selected_multiple_param:`, the selected preload request still used the documented key, and a comparable endpoint still accepted comma-separated `ids`

Notes:

## Create-on-the-fly representative failure lane checks

- [ ] one representative field with `create_url:` covered the end-to-end create-on-the-fly failure lane
- [ ] a failed create request dispatched `rails-fields-kit--tom-select:create-error`
- [ ] the representative failure path left host-app fallback copy or retry UI visible near the field
- [ ] if that field used `error_surface: true`, the failure path still exposed the expected inline placeholder through `event.detail.surface`
- [ ] a follow-up success or fresh interaction cleared stale inline failure UI for that same field
- [ ] retry policy and final visible copy remained a host-app responsibility rather than a built-in Rails Fields Kit behavior

Notes:

## `rfk_autocomplete` representative suggestion-only lane checks

- [ ] one representative `rfk_autocomplete` field covered the end-to-end suggestion-only lane
- [ ] remote suggestions appeared as typing assist for that field
- [ ] choosing a suggestion still left the submitted value as free text rather than a selected ID or created record payload
- [ ] a normal submit, edit-form redisplay, or validation rerender kept that same field in the free-text helper lane
- [ ] the representative field stayed independent from `selected_url:` and `create_url:`

Notes:

## `rfk_multi_select` representative collection-backed lane checks

- [ ] one representative `rfk_multi_select` field covered the end-to-end collection-backed multiple-value lane
- [ ] the field selected multiple known values from the documented collection-backed lane
- [ ] the submitted value stayed an ordinary array of selected IDs or values rather than tag-entry or free-text creation payload
- [ ] an edit form or validation rerender kept the same selected values on that representative field
- [ ] the representative field stayed independent from `create_url:` and token-style parsing

Notes:

## `rfk_grouped_select` representative optgroup-preserving lane checks

- [ ] one representative `rfk_grouped_select` field covered the end-to-end optgroup-preserving lane
- [ ] the field rendered the documented grouped collection with its current optgroup structure intact
- [ ] choosing a value kept the submitted value in the ordinary selected ID or value lane rather than a remote-search or token-metadata lane
- [ ] an edit form or validation rerender kept the same selected value while preserving the grouped labels on that representative field
- [ ] the representative field stayed independent from `url:`, `selected_url:`, and `create_url:`

Notes:

## `rfk_enum_select` representative enum-backed lane checks

- [ ] one representative `rfk_enum_select` field covered the end-to-end enum-backed lane
- [ ] the field rendered the current enum labels and values from the model-backed enum lane
- [ ] choosing a value kept the submitted value in the ordinary enum-backed selected-value lane rather than a free-text or created-record lane
- [ ] an edit form or validation rerender kept the same selected enum value and redisplayed the matching label for that representative field
- [ ] the representative field stayed clearly tied to the enum-backed attribute rather than a hand-maintained collection helper lane

Notes:

## Token suggestion and Ransack suggestion metadata checks

- [ ] `rfk_token_suggestions_with(..., wrap: "options")` returns the documented wrapped suggestion payload
- [ ] operator suggestions such as `OR` or `not()` use the documented option fields
- [ ] field suggestions such as `status:` and `assignee:` match the documented labels and descriptions
- [ ] value suggestions such as `status:open` and `status:closed` are returned when configured
- [ ] saved-search suggestions such as `saved:mine` return the expected label and optional description
- [ ] the sample app still treats submitted token text as a host-app parsing concern
- [ ] Ransack field suggestions expose `ransack_predicate` and `ransack_field` when that release surface is in scope
- [ ] Ransack value suggestions preserve `ransack_value` and any documented extra metadata when that release surface is in scope
- [ ] the same allowed field list drove both the documented suggestion builder config and the host-app parser whitelist
- [ ] submitted token text was turned into `params[:q]` by the host app parser or search object, not by Rails Fields Kit
- [ ] the sample app treated Ransack suggestion payload as metadata only, not as query execution performed by the gem

Notes:

## Visible feedback checks

- [ ] `placeholder` copy reads as intended before interaction
- [ ] `loading_text` appears during remote search and clears after the response returns
- [ ] `no_results_text` appears for empty search responses
- [ ] `create_text` shows the intended affordance when create-on-the-fly is enabled
- [ ] `create-error` handling produces visible host-app feedback when create fails
- [ ] an `error_surface: true` field exposed a usable inline placeholder during a representative request failure
- [ ] a representative `error_surface_html:` field preserved its custom wrapper class or attrs without losing the shared placeholder `id`, hidden default, `role`, `aria-live`, or `aria-atomic` contract
- [ ] request-failure events for that custom placeholder field still surfaced the same inline placeholder through `event.detail.surface`
- [ ] stale inline error content cleared after success or a follow-up interaction
- [ ] a comparable field without `error_surface: true` kept the default no-inline-placeholder behavior

Notes:

## Table metadata checks

Use this section when table metadata is part of the release surface, or when `doc/table_metadata_visual_reference.html` is release-critical evidence even though the static artifact itself did not change.

- Visual reference artifact:
- Viewport(s) checked:
- Table metadata lane(s) checked:
  - [ ] filters
  - [ ] Ransack token filter metadata
  - [ ] native field metadata
  - [ ] cell editors
  - [ ] custom helper mapping
- Evidence location:
- [ ] `doc/table_metadata_visual_reference.html` was checked for the same representative lane(s) recorded above when visual evidence is in scope
- [ ] `RailsFieldsKit::TableFilterInput` metadata renders through the documented helper path
- [ ] `RailsFieldsKit::TableCellInput` metadata renders through the documented helper path
- [ ] `rfk_table_filters` renders collected filter metadata
- [ ] `rfk_table_cell_editors` renders collected cell editor metadata
- [ ] native field metadata such as `search_field`, `money_field`, or `text_area` rendered through the documented helper path
- [ ] direct `TableRenderer` call-spec usage still matches the documented helper / method / options shape when used
- [ ] a representative `TableRenderer.register_field_helper` mapping rendered through the documented call-spec path
- [ ] `TableRenderer.reset_field_helpers!` restored the default mapping after the representative custom helper check
- [ ] table metadata remained rendering assistance only; representative query execution or persistence stayed in the host app / table integration

Notes:

## Turbo reconnect checks

- Evidence location:
- Tested lane(s):
  - [ ] selected preload
  - [ ] remote search
  - [ ] create-on-the-fly
  - [ ] visible request-failure feedback
  - [ ] other:
- [ ] Tom Select initializes on first render without a host-app `setupXxx()` helper
- [ ] Turbo-driven validation rerender reconnects the replaced field without duplicate Tom Select initialization
- [ ] same-form revisit through Turbo reconnects the field without duplicate Tom Select initialization
- [ ] representative selected preload, remote search, and create-on-the-fly lanes still work after reconnect when they are in scope for this release
- [ ] pending requests from a disconnected field did not leave stale success or error UI in the manually observed result; deeper request lifecycle guarantees stay in the runtime quality lane
- [ ] no separate `turbo:load` reinitializer was needed for normal `rfk_*` usage

Notes:
- Remaining caveats / follow-up:

## Event checks

- [ ] `rails-fields-kit--tom-select:load`
- [ ] `rails-fields-kit--tom-select:load-error`
- [ ] `rails-fields-kit--tom-select:selected-load`
- [ ] `rails-fields-kit--tom-select:selected-load-error`
- [ ] `rails-fields-kit--tom-select:create`
- [ ] `rails-fields-kit--tom-select:create-error`
- [ ] `rails-fields-kit--tom-select:change`
- [ ] `rails-fields-kit--tom-select:item-add`
- [ ] `rails-fields-kit--tom-select:item-remove`
- [ ] `rails-fields-kit--tom-select:clear`
- [ ] a representative selected preload success dispatched `selected-load` with the requested saved value or values and resolved options
- [ ] a representative selected preload failure dispatched `selected-load-error` separately from remote search and create-on-the-fly failures
- [ ] selected preload event evidence stayed tied to the `selected_url:` lane rather than ordinary remote search
- [ ] a representative single select or combobox dispatched `change` when the selected value changed
- [ ] a representative multiple select or tags field dispatched `item-add` and `item-remove` for add/remove actions
- [ ] a representative clearable field dispatched `clear` when its selected value was cleared
- [ ] interaction forwarding events were recorded separately from remote `load` / `load-error`, selected preload, create-on-the-fly, and visible-feedback lanes
- [ ] create-on-the-fly success dispatched the dedicated `create` event before the normal selection events continued
- [ ] `event.detail.input` matched the submitted text for the create success case
- [ ] `event.detail.option` exposed the created option payload needed by the host app
- [ ] `item-add` and `change` still matched the accepted selection after dedicated create success
- [ ] request-failure events for an `error_surface: true` field exposed `event.detail.surface`
- [ ] a comparable field without `error_surface: true` kept `event.detail.surface` at `null`
- [ ] stale inline error content cleared after a fresh request or follow-up interaction when the message stayed inside the placeholder

Notes:

## Release notes

- [ ] Version-specific release note draft reviewed or updated

Notes:

## Decision

- [ ] Ready to publish
- [ ] Needs fixes before publishing

Summary: