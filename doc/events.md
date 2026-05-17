# Rails Fields Kit events

Rails Fields Kit dispatches Stimulus events from the `rails-fields-kit--tom-select` controller so applications can attach UI feedback without replacing the built-in controller.

## Remote search

- `rails-fields-kit--tom-select:load`
  - Fired after remote search succeeds.
  - Detail: `{ query, options }`
- `rails-fields-kit--tom-select:load-error`
  - Fired after remote search fails or returns a non-2xx response.
  - Detail: `{ query, error }`

## Selected preload

- `rails-fields-kit--tom-select:selected-load`
  - Fired after selected option preload succeeds.
  - Detail: `{ values, options }`
- `rails-fields-kit--tom-select:selected-load-error`
  - Fired after selected option preload fails or returns a non-2xx response.
  - Detail: `{ values, error }`

## Create-on-the-fly

- `rails-fields-kit--tom-select:create-error`
  - Fired after create-on-the-fly fails or returns a non-2xx response.
  - Detail: `{ input, error }`

## Interaction forwarding

These events forward common Tom Select interactions:

- `rails-fields-kit--tom-select:change`
  - Detail: `{ value, values }`
- `rails-fields-kit--tom-select:item-add`
  - Detail: `{ value, item, values }`
- `rails-fields-kit--tom-select:item-remove`
  - Detail: `{ value, item, values }`
- `rails-fields-kit--tom-select:clear`
  - Detail: `{ values }`

Example:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  html: {
    data: {
      action: "rails-fields-kit--tom-select:load-error->customers#error rails-fields-kit--tom-select:change->customers#changed"
    }
  } %>
```
