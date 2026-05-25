pin "tom-select"
pin "rails_fields_kit", to: "rails_fields_kit/index.js"
pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
```

Then register the controller from the file where the host app already boots Stimulus:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

`rails_fields_kit/index.js` re-exports the same controller as `rails_fields_kit/tom_select_controller`, so both documented import paths stay available after pinning. Rails Fields Kit still leaves the Tom Select pin source and any additional importmap conventions to the host app.

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

For a static collection that already works with `collection_select`, migrating to `rfk_select` is usually a form-helper-only change. Keep the same attribute name and normal Rails select options such as `include_blank:` or `prompt:` and let the registered Stimulus controller enhance the rendered select in place.

```erb
<%= f.rfk_select :company_id,
  collection: @companies,
  collection_value_method: :id,
  collection_label_method: :name,
  include_blank: "Select a company" %>
```

That migration keeps the ordinary submitted param and selected-value redisplay behavior, so host-app controller code and extra Turbo/Vite reinitializers usually do not need to change just for this helper swap.

If the host app wants a stable placeholder for inline error UI, opt in with `error_surface: true`:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  error_surface: true,
  html: {
    data: {
      action: "rails-fields-kit--tom-select:load-error->customers#error rails-fields-kit--tom-select:selected-load-error->customers#error rails-fields-kit--tom-select:create-error->customers#error"
    }
  } %>
```

The helper renders an empty placeholder next to the field, and request-failure events include that element as `event.detail.surface`. The gem still does not choose the message copy or retry behavior.

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

Remote search and selected preload have dedicated success and failure events. Create-on-the-fly currently reports success through the normal `item-add` / `change` interaction events and keeps `create-error` as the dedicated failure hook. When `error_surface: true` is enabled, request-failure events also expose `event.detail.surface` so the host app can render inline error UI without replacing the controller.

Visible success or error UI remains a host-app responsibility.
