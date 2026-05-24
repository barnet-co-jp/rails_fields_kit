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
bundle exec rspec
bundle exec rake build
```

Result:

- [ ] RSpec passed
- [ ] Gem build passed
- [ ] No RubyGems validation warnings

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
- [ ] validation errors return `422`
- [ ] authorization failures return `403`
- [ ] wrapped responses work with `options` / `option`
- [ ] rich fields return description and badge data
- [ ] Ransack-compatible suggestion metadata works as expected if it is part of the release surface

Notes:

## Table metadata checks

- [ ] `RailsFieldsKit::TableFilterInput` metadata renders through the documented helper path
- [ ] `RailsFieldsKit::TableCellInput` metadata renders through the documented helper path
- [ ] `rfk_table_filters` renders collected filter metadata
- [ ] `rfk_table_cell_editors` renders collected cell editor metadata
- [ ] direct `TableRenderer` call-spec usage still matches the documented helper / method / options shape when used

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

Notes:

## Release notes

- [ ] Version-specific release note draft reviewed or updated

Notes:

## Decision

- [ ] Ready to publish
- [ ] Needs fixes before publishing

Summary:
