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

## Controller helper checks

- [ ] `rfk_search_with` returns remote options
- [ ] `rfk_find_with` returns selected option labels for edit forms
- [ ] `rfk_create_with` creates options on the fly
- [ ] `rfk_token_suggestions_with` returns token suggestion option JSON
- [ ] fixed `query_params:` reached representative remote search requests
- [ ] fixed `selected_query_params:` reached representative selected preload requests
- [ ] fixed `create_params:` were merged into representative create-on-the-fly requests
- [ ] validation errors return `422`
- [ ] authorization failures return `403`
- [ ] wrapped responses work with `options` / `option`
- [ ] rich fields return description and badge data
- [ ] Ransack-compatible suggestion metadata works as expected if it is part of the release surface

Notes:

## Visible feedback checks

- [ ] `placeholder` copy reads as intended before interaction
- [ ] `loading_text` appears during remote search and clears after the response returns
- [ ] `no_results_text` appears for empty search responses
- [ ] `create_text` shows the intended affordance when create-on-the-fly is enabled
- [ ] `create-error` handling produces visible host-app feedback when create fails
- [ ] `selected-load-error` handling leaves a visible host-app fallback or understandable failure state when selected preload fails

Notes:

## Table metadata checks

- [ ] `RailsFieldsKit::TableFilterInput` metadata renders through the documented helper path
- [ ] `RailsFieldsKit::TableCellInput` metadata renders through the documented helper path
- [ ] `rfk_table_filters` renders collected filter metadata
- [ ] `rfk_table_cell_editors` renders collected cell editor metadata
- [ ] direct `TableRenderer` call-spec usage still matches the documented helper / method / options shape when used

Notes:

## Turbo reconnect checks

- [ ] Tom Select initializes on first render without a host-app `setupXxx()` helper
- [ ] Turbo-driven validation rerender reconnects the replaced field
- [ ] same-form revisit through Turbo reconnects the field
- [ ] `selected_url:` still restores labels after the rerender
- [ ] no separate `turbo:load` reinitializer was needed for normal `rfk_*` usage

Notes:

## Event checks

- [ ] `rails-fields-kit--tom-select:load`
- [ ] `rails-fields-kit--tom-select:load-error`
- [ ] `rails-fields-kit--tom-select:selected-load`
- [ ] `rails-fields-kit--tom-select:selected-load-error`
- [ ] `rails-fields-kit--tom-select:create-error`
- [ ] `rails-fields-kit--tom-select:change`
- [ ] `rails-fields-kit--tom-select:item-add`
- [ ] `rails-fields-kit--tom-select:item-remove`
- [ ] `rails-fields-kit--tom-select:clear`
- [ ] create-on-the-fly success matched the current success surface documented in `doc/events.md`

Notes:

## Release notes

- [ ] Version-specific release note draft reviewed or updated

Notes:

## Decision

- [ ] Ready to publish
- [ ] Needs fixes before publishing

Summary: