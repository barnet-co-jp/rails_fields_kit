# Rails Fields Kit Sample App Results

Use this file to record manual verification results before publishing a release.

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
- [ ] `import TomSelectController from "rails_fields_kit/tom_select_controller"` resolved
- [ ] documented controller registration succeeded
- [ ] importmap pins resolved `rails_fields_kit` and `rails_fields_kit/tom_select_controller` when importmap was used
- [ ] documented controller registration still worked from the existing Stimulus boot file after adding those importmap pins
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

## `collection_select` migration checks

- [ ] documented `collection_select` to `rfk_select` swap preserved the same submitted attribute and redisplay behavior
- [ ] `include_blank:` kept the expected blank-option behavior from `doc/select_migration.md`
- [ ] representative `disabled:` options still rendered and behaved as expected
- [ ] representative grouped options still rendered correctly
- [ ] representative `option_html:` data or HTML attributes still reached the rendered options
- [ ] the migration path stayed aligned with `doc/field_helpers.md` and `doc/public_api.md`

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

- [ ] Tom Select initializes on first render without a host-app `setupXxx()` helper
- [ ] Turbo-driven validation rerender reconnects the replaced field
- [ ] same-form revisit through Turbo reconnects the field
- [ ] no separate `turbo:load` reinitializer was needed for normal `rfk_*` usage

Notes:

## Event checks

- [ ] `rails-fields-kit--tom-select:load`
- [ ] `rails-fields-kit--tom-select:load-error`
- [ ] `rails-fields-kit--tom-select:create`
- [ ] `rails-fields-kit--tom-select:create-error`
- [ ] `rails-fields-kit--tom-select:change`
- [ ] `rails-fields-kit--tom-select:item-add`
- [ ] `rails-fields-kit--tom-select:item-remove`
- [ ] `rails-fields-kit--tom-select:clear`
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