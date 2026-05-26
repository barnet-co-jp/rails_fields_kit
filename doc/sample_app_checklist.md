# Rails Fields Kit Sample App Checklist

Use this checklist before publishing a release.

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

If the sample app uses a bundler alias or custom resolver, confirm it still resolves those documented import paths rather than an app-specific private path.

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
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`
- `rfk_token_search`
- native helpers such as `rfk_text_field` and `rfk_money_field`

## Verify `collection_select` migration path

Create at least one server-rendered form that starts from the documented `collection_select` example in [`select_migration.md`](select_migration.md), then swap it to `rfk_select` and confirm:

- the same model attribute still drives the selected value on first render, edit forms, and validation rerender
- `include_blank:` keeps the documented blank-option behavior from the migration guide
- representative `disabled:` options still render and behave as expected after the helper swap
- representative grouped options still render correctly after the helper swap
- representative `option_html:` data or HTML attributes still reach the rendered options after the helper swap
- the migration path stays aligned with the helper reference in `field_helpers.md` and the public API summary in `public_api.md`

## Verify controller helpers

Add a controller with:

- `include RailsFieldsKit::Searchable`
- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`
- `rfk_token_suggestions_with`

Verify:

- remote search returns options
- edit forms can load selected labels through `selected_url:`
- create-on-the-fly adds a newly-created option
- token suggestion endpoints return option JSON for `rfk_token_search`
- at least one representative non-default `action:` route still works from the documented route shape, such as `rfk_find_with action: :selected` or `rfk_token_suggestions_with action: :search_tokens`
- fixed `query_params:` reach representative remote search requests when the field relies on request context
- fixed `selected_query_params:` reach representative selected preload requests when `selected_url:` is used
- fixed `create_params:` are merged into representative create-on-the-fly requests when the field relies on them
- wrapped responses work with `options` / `option` when the helper flow relies on them
- rich option payloads return representative `description` / `badge` data when the UI depends on them
- validation errors return `422`
- authorization failures return `403`

If the release surface includes `RailsFieldsKit::RansackSuggestions.build`, also confirm the sample endpoint can return the expected predicate metadata without handing query parsing to the gem.

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
- selected preload failures, if exercised, still leave a user-understandable fallback or visible host-app feedback after `rails-fields-kit--tom-select:selected-load-error`
- at least one field with `error_surface: true` exposes a stable inline placeholder from `load-error`, `selected-load-error`, or `create-error`
- success or a follow-up interaction clears stale inline error content from that placeholder
- a comparable field without `error_surface: true` keeps the default no-inline-placeholder behavior

## Verify table metadata adapters

Create a minimal table definition that exercises:

- `RailsFieldsKit::TableFilterInput.combobox` or `RailsFieldsKit::TableFilterInput.token_search`
- `RailsFieldsKit::TableCellInput.enum_select` or another current editor helper
- `rfk_table_filters`
- `rfk_table_cell_editors`

Verify:

- collected filter metadata renders through the documented helper path
- collected cell editor metadata renders through the documented helper path
- native metadata such as `TableFilterInput.search_field`, `money_field`, or `TableCellInput.text_area` also render through the documented helper path when the integration uses common field helpers
- any direct `TableRenderer.filter_call` or `TableRenderer.cell_editor_call` usage in your integration still matches the documented call-spec shape
- a representative `TableRenderer.register_field_helper` mapping can be rendered through the documented call-spec path, and `TableRenderer.reset_field_helpers!` restores the default mapping after that scoped customization
- token search or Ransack-oriented metadata, if used, is still treated as UI metadata or rendering assistance rather than query execution
- representative query execution and preference persistence still belong to the host app or table integration rather than Rails Fields Kit

## Verify Turbo reconnect

Use a server-rendered form with at least one `rfk_combobox` or `rfk_tags` field and confirm:

- the field initializes on the first render without a host-app `setupXxx()` helper
- a Turbo-driven validation rerender or same-form revisit reconnects Tom Select on the replaced element
- selected preload still restores labels after the Turbo rerender when `selected_url:` is configured
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