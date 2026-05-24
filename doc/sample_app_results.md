# Rails Fields Kit Sample App Results

Use this file to record manual verification results before publishing a release.

## Release candidate

- Version: `0.1.0`
- Date:
- Tester:
- Sample app Rails version:
- Ruby version:
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
- [ ] generated setup notes match current public API

Notes:

## JavaScript setup checks

- [ ] Tom Select package installed
- [ ] Rails Fields Kit Stimulus controller registered
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
- [ ] native helpers such as `rfk_text_field` and `rfk_money_field`

Notes:

## Controller helper checks

- [ ] `rfk_search_with` returns remote options
- [ ] `rfk_find_with` returns selected option labels for edit forms
- [ ] `rfk_create_with` creates options on the fly
- [ ] validation errors return `422`
- [ ] authorization failures return `403`
- [ ] wrapped responses work with `options` / `option`
- [ ] rich fields return description and badge data

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

Notes:

## Decision

- [ ] Ready to publish
- [ ] Needs fixes before publishing

Summary:
