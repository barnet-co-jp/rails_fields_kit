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

Load Tom Select CSS:

```js
import "tom-select/dist/css/tom-select.css"
```

## Verify form helpers

Create a form that exercises:

- `rfk_select`
- `rfk_combobox`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_enum_select`
- native helpers such as `rfk_text_field` and `rfk_money_field`

## Verify controller helpers

Add a controller with:

- `include RailsFieldsKit::Searchable`
- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`

Verify:

- remote search returns options
- edit forms can load selected labels through `selected_url:`
- create-on-the-fly adds a newly-created option
- validation errors return `422`
- authorization failures return `403`

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
- `rails-fields-kit--tom-select:create-error`
- `rails-fields-kit--tom-select:change`
- `rails-fields-kit--tom-select:item-add`
- `rails-fields-kit--tom-select:item-remove`
- `rails-fields-kit--tom-select:clear`

## Release gate

Before release, confirm:

```bash
bundle exec rspec
bundle exec rake build
```

Then perform the sample app checks above.
