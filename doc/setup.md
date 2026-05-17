# Rails Fields Kit Setup

This guide summarizes the steps for adding Rails Fields Kit to a Rails 7+ application.

## 1. Add the gem

```ruby
gem "rails_fields_kit"
```

Then run:

```bash
bundle install
rails generate rails_fields_kit:install
```

The generator creates:

- `config/initializers/rails_fields_kit.rb`
- `doc/rails_fields_kit_setup.md`

## 2. Install Tom Select

Rails Fields Kit provides Rails helpers and a Stimulus controller, but it does not install Tom Select or choose a JavaScript bundling strategy.

Install Tom Select with the JavaScript toolchain already used by the application:

```bash
yarn add tom-select
# or
npm install tom-select
# or
pnpm add tom-select
```

## 3. Register the Stimulus controller

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

Direct import is also supported:

```js
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

## 4. Load Tom Select CSS

Use the stylesheet pipeline or bundler already used by the application.

```js
import "tom-select/dist/css/tom-select.css"
```

Rails Fields Kit intentionally does not generate importmap-specific setup. Importmap applications can pin `tom-select` and register the controller manually.

## 5. Add a searchable combobox

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
    option_description_field: "email",
    option_badge_field: "status",
    placeholder: "Search or create a customer" %>
<% end %>
```

## 6. Add controller endpoints

```ruby
class CustomersController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_search_with(
    model: Customer,
    value: :id,
    label: :name,
    search: [:name, :email],
    description: :email,
    badge: :status,
    value_field: "id",
    label_field: "name",
    description_field: "email",
    badge_field: "status",
    scope: -> { current_account.customers.active },
    order: { name: :asc },
    distinct: true,
    wrap: "options"
  )

  rfk_find_with(
    model: Customer,
    value: :id,
    label: :name,
    description: :email,
    badge: :status,
    value_field: "id",
    label_field: "name",
    description_field: "email",
    badge_field: "status",
    scope: -> { current_account.customers },
    wrap: "option"
  )

  rfk_create_with(
    model: Customer,
    value: :id,
    label: :name,
    create_attribute: :name,
    create_param: "name",
    assign: ->(_customer) { { account_id: current_account.id } },
    authorize: ->(customer) { policy(customer).create? },
    wrap: "option"
  )
end
```

## 7. Listen to events when needed

See [`events.md`](events.md) for the Stimulus events emitted by the Tom Select controller.
