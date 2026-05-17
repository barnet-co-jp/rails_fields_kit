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

## JavaScript setup

Install Tom Select with the JavaScript toolchain your Rails app already uses:

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
    create_url: customers_path,
    selected: @order.customer,
    value_method: :id,
    label_method: :name,
    value_field: "id",
    label_field: "name",
    search_field: "name,email",
    query_param: "q",
    create_param: "name",
    min_length: 2,
    placeholder: "Search or create a customer" %>
<% end %>
```

`selected:` preloads the current option for edit forms before remote search runs. It accepts a record, a `{ value:, text: }` hash, a `{ id:, name: }` hash, or an array of any of those for multiple fields.

The search endpoint can return an array:

```json
[
  { "id": 1, "name": "Example Customer" }
]
```

or a wrapped result:

```json
{ "options": [{ "id": 1, "name": "Example Customer" }] }
```

The create endpoint should return the created option object:

```json
{ "id": 2, "name": "New Customer" }
```

When the create endpoint returns a non-2xx response, Rails Fields Kit does not add a fallback free-text option. It dispatches a `rails-fields-kit--tom-select:create-error` event with the failed input and error payload so your application can show a validation message.

### Controller concern for search and create endpoints

For simple Active Record-backed option search and create endpoints, include `RailsFieldsKit::Searchable`:

```ruby
class CustomersController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_search_with(
    model: Customer,
    value: :id,
    label: :name,
    search: [:name, :email],
    value_field: "id",
    label_field: "name",
    limit: 20
  )

  rfk_create_with(
    model: Customer,
    value: :id,
    label: :name,
    create_attribute: :name,
    create_param: "name",
    value_field: "id",
    label_field: "name"
  )
end
```

`rfk_create_with` renders `422 Unprocessable Entity` with `{ "errors": ... }` when the record is invalid.

### Normal select wrapper

```erb
<%= f.rfk_select :status, collection: Order.statuses.keys %>
```

### Tag-style multi select

```erb
<%= f.rfk_tags :tag_ids,
  url: tags_path(format: :json),
  selected: @post.tags,
  value_method: :id,
  label_method: :name,
  create: true %>
```

### Autocomplete text field

```erb
<%= f.rfk_autocomplete :keyword,
  url: suggestions_path(format: :json),
  free_text: true %>
```

## Configuration

```ruby
# config/initializers/rails_fields_kit.rb
RailsFieldsKit.configure do |config|
  config.controller_name = "rails-fields-kit--tom-select"
  config.default_query_param = "q"
  config.default_create_param = "text"
  config.default_value_field = "value"
  config.default_label_field = "text"
  config.default_search_field = "text"
  config.default_min_length = 0
  config.default_plugins = []
end
```

## Design principles

Rails Fields Kit does not try to replace native HTML inputs when browsers already provide a good default, such as date, time, color, email, URL, or number inputs.

Instead, it focuses on the gaps that remain common in Rails business applications:

- searchable selects
- editable comboboxes
- autocomplete text fields
- tag inputs
- remote option loading
- create-on-the-fly records
- Active Model friendly naming, values, errors, and redisplay

Select-like fields are powered by Tom Select. When Tom Select already supports the behavior directly, Rails Fields Kit acts as a thin Rails wrapper. When Rails integration is the hard part, such as initial value preload or create-on-the-fly records, Rails Fields Kit provides a higher-level field helper.

## Development

```bash
git pull
bundle install
bundle exec rspec
```

CI is intentionally not required during early implementation.
