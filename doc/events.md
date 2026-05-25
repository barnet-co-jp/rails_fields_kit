# Rails Fields Kit events

Rails Fields Kit dispatches Stimulus events from the `rails-fields-kit--tom-select` controller so applications can attach UI feedback without replacing the built-in controller.

These events are integration hooks. Rails Fields Kit does not render visible success or error messages by itself, so host applications should subscribe to the events they care about and decide how to show feedback.

## Event map

| Workflow | Success surface | Failure surface | Notes |
| --- | --- | --- | --- |
| Remote search | `rails-fields-kit--tom-select:load` | `rails-fields-kit--tom-select:load-error` | Use when the app needs the fetched option payloads. |
| Selected preload | `rails-fields-kit--tom-select:selected-load` | `rails-fields-kit--tom-select:selected-load-error` | Use when edit forms need labels for already-selected IDs. |
| Create-on-the-fly | `rails-fields-kit--tom-select:item-add` and `rails-fields-kit--tom-select:change` | `rails-fields-kit--tom-select:create-error` | There is no dedicated create-success event today. |

Common error detail fields:

- `operation`: request type (`load`, `selected-load`, `create`)
- `error`: thrown error object
- `response`: fetch response when the request reached the server, otherwise `null`
- `payload`: parsed error payload when available, otherwise `null`
- `status`: HTTP status when available, otherwise `null`

## Remote search

- `rails-fields-kit--tom-select:load`
  - Fired after remote search succeeds.
  - Detail: `{ query, options }`
- `rails-fields-kit--tom-select:load-error`
  - Fired after remote search fails or returns a non-2xx response.
  - Detail: `{ operation, query, error, response, payload, status }`

Use these hooks when the host app wants to react to the fetched option set itself, for example by logging searches, updating nearby helper text, or showing a retry state.

## Selected preload

- `rails-fields-kit--tom-select:selected-load`
  - Fired after selected option preload succeeds.
  - Detail: `{ values, options }`
- `rails-fields-kit--tom-select:selected-load-error`
  - Fired after selected option preload fails or returns a non-2xx response.
  - Detail: `{ operation, values, error, response, payload, status }`

Use these hooks when the host app needs to know whether edit-form labels were resolved successfully before the user starts searching.

## Create-on-the-fly

Current create success is surfaced through the normal Tom Select interaction events after the created option is accepted:

- `rails-fields-kit--tom-select:item-add`
  - Detail: `{ value, item, values }`
- `rails-fields-kit--tom-select:change`
  - Detail: `{ value, values }`

Rails Fields Kit does not dispatch a dedicated `create` success event today. If the host app needs to distinguish create success from ordinary selection, it should combine these interaction events with the field configuration or its own application state.

Create failure keeps its own dedicated event:

- `rails-fields-kit--tom-select:create-error`
  - Fired after create-on-the-fly fails or returns a non-2xx response.
  - Detail: `{ operation, input, error, response, payload, status }`

Use `create-error` when the host app wants to show validation feedback, retry affordances, or analytics for failed inline creation.

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

These are useful even when the field does not use remote search or create-on-the-fly.

## Choosing the right hook

- Use `load` / `selected-load` when the app cares about fetched option payloads.
- Use `item-add` / `change` when the app cares that the selection actually changed, including the current create-success path.
- Use `load-error`, `selected-load-error`, or `create-error` when the app wants visible error UI, retry UI, or logging.
- Keep visible feedback in the host app. Rails Fields Kit only dispatches the events.

Example:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  html: {
    data: {
      action: "rails-fields-kit--tom-select:load-error->customers#error rails-fields-kit--tom-select:create-error->customers#error rails-fields-kit--tom-select:item-add->customers#selected"
    }
  } %>
```