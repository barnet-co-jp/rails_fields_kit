# Rails Fields Kit

Rails Fields Kit is a Rails form helper kit for fields that are still awkward with native HTML inputs alone: searchable selects, editable comboboxes, tag inputs, autocomplete, and create-on-the-fly fields.

The first focus is a Tom Select powered editable combobox for Rails forms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails_fields_kit"
```

Then install:

```bash
bundle install
rails generate rails_fields_kit:install
```

The install generator creates:

- `config/initializers/rails_fields_kit.rb`
- `doc/rails_fields_kit_setup.md`

Rails Fields Kit ships Rails helpers, a Rails engine, a Stimulus controller, and controller-side helpers. It does not install Tom Select or choose a JavaScript bundling strategy for your app.

See [`doc/setup.md`](doc/setup.md) for a complete setup walkthrough.
See [`doc/field_helpers.md`](doc/field_helpers.md) for the FormBuilder helper reference.
See [`doc/controller_helpers.md`](doc/controller_helpers.md) for the controller helper reference.
See [`doc/configuration.md`](doc/configuration.md) for initializer options.
See [`doc/events.md`](doc/events.md) for Stimulus events dispatched by the Tom Select controller.

## JavaScript setup

Install Tom Select with the JavaScript toolchain your app already uses:

```bash
yarn add tom-select
# or
npm install tom-select
# or
pnpm add tom-select
```

Register the Rails Fields Kit Stimulus controller in your application:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

You can also import the controller file directly:

```js
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

Load Tom Select's CSS through your application's stylesheet pipeline or bundler:

```js
import "tom-select/dist/css/tom-select.css"
```

Importmap users can pin and register these modules manually, but Rails Fields Kit does not generate importmap-specific setup.

## Usage

### Editable combobox

```erb
<%= form_with model: @order do |f| %>
  <%= f.rfk_combobox :customer_id,
    url: customers_path(format: :json),
    selected_url: selected_customers_path(format: :json),
    create_url: customers_path,
    selected: @order.customer_id,
    value_field: "id",
    label_field: "name",
    search_field: "name,email",
    query_param: "q",
    selected_param: "id",
    selected_multiple_param: "ids",
    create_param: "name",
    min_length: 2,
    max_options: 50,
    preload: true,
    open_on_focus: true,
    close_after_select: true,
    hide_selected: true,
    persist: false,
    no_results_text: "No customers found",
    loading_text: "Searching...",
    create_text: "Create",
    option_description_field: "email",
    option_badge_field: "status",
    placeholder: "Search or create a customer" %>
<% end %>
```

`selected:` preloads the current option for edit forms before remote search runs. It accepts a record, a `{ value:, text: }` hash, a `{ id:, name: }` hash, an ID value, or an array of any of those for multiple fields.

When `selected_url:` is provided, Rails Fields Kit can load missing selected option labels from the server after Tom Select connects. This is useful when the form only has stored IDs and not the display labels. For one value it sends `selected_param`, default `id`; for multiple values it sends `selected_multiple_param`, default `ids`.

Selected preload dispatches these Stimulus events:

- `rails-fields-kit--tom-select:selected-load`
- `rails-fields-kit--tom-select:selected-load-error`

Remote options can include extra fields for richer rendering:

```json
[
  { "id": 1, "name": "Example Customer", "email": "hello@example.com", "status": "active" }
]
```

Then set `option_description_field:` and `option_badge_field:` to show those fields in Tom Select's dropdown and selected item rendering.

The search endpoint can return an array:
