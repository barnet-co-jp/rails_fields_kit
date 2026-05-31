# Rails Fields Kit events

Rails Fields Kit dispatches Stimulus events from the `rails-fields-kit--tom-select` controller so applications can attach UI feedback without replacing the built-in controller.

These events are integration hooks. Rails Fields Kit does not render visible success or error messages by itself, so host applications should subscribe to the events they care about and decide how to show feedback.

When a field is rendered with `error_surface: true`, the controller also includes `detail.surface` on request-failure events. That surface is an opt-in empty placeholder element near the field where the host app can render its own message or retry UI.

Rails Fields Kit marks that placeholder with request state metadata before dispatching the failure event. The attributes use the same operation and status values as the event detail:

- `data-rfk-error-state="error"`
- `data-rfk-error-operation="load"`, `"selected-load"`, or `"create"`
- `data-rfk-error-status` when an HTTP status is available

Use those attributes for host-owned CSS, analytics, or lightweight event handlers that need to tell remote search, selected preload, and create-on-the-fly failures apart. They do not make Rails Fields Kit responsible for visible message text, retry UI, loading UI, or endpoint policy. The controller clears the attributes when it hides the opt-in placeholder.

## Event map

| Workflow | Success surface | Failure surface | Notes |
| --- | --- | --- | --- |
| Remote search | `rails-fields-kit--tom-select:load` | `rails-fields-kit--tom-select:load-error` | Use when the app needs the fetched option payloads. |
| Selected preload | `rails-fields-kit--tom-select:selected-load` | `rails-fields-kit--tom-select:selected-load-error` | Use when edit forms need labels for already-selected IDs. |
| Create-on-the-fly | `rails-fields-kit--tom-select:create`, `rails-fields-kit--tom-select:item-add`, and `rails-fields-kit--tom-select:change` | `rails-fields-kit--tom-select:create-error` | Use `create` when the app needs a dedicated hook before ordinary selection events. |

Common error detail fields:

- `operation`: request type (`load`, `selected-load`, `create`)
- `error`: thrown error object
- `response`: fetch response when the request reached the server, otherwise `null`
- `payload`: parsed error payload when available, otherwise `null`
- `status`: HTTP status when available, otherwise `null`
- `surface`: opt-in placeholder element when `error_surface: true` is enabled, otherwise `null`

## Request cancellation and stale responses

Remote search, selected preload, and create-on-the-fly requests are tracked per operation. When a newer request for the same operation starts, the older request is aborted and any stale callback from that older request is ignored.

Rails Fields Kit only dispatches success or failure events for the latest still-current request. Aborted requests, disconnect-time aborts, and stale responses do not dispatch `load`, `selected-load`, `create`, `load-error`, `selected-load-error`, or `create-error` events.

Use the failure events for server errors, non-2xx responses, and payload-shape errors from the current request. If the host app needs a loading indicator or retry affordance that reacts to request start, pair these hooks with host-owned state from the interaction that started the request. Rails Fields Kit does not dispatch a separate request-start event or render built-in loading, retry, or fallback UI.

## Remote search

- `rails-fields-kit--tom-select:load`
  - Fired after remote search succeeds.
  - Detail: `{ query, options }`
- `rails-fields-kit--tom-select:load-error`
  - Fired after remote search fails, returns a non-2xx response, or returns 2xx JSON that is not an array, `{ options: [...] }`, or `{ results: [...] }`.
  - Detail: `{ operation, query, error, response, payload, status, surface }`

Use these hooks when the host app wants to react to the fetched option set itself, for example by logging searches, updating nearby helper text, or showing a retry state. A true empty search result should return `[]`, `{ options: [] }`, or `{ results: [] }`; other 2xx JSON shapes are treated as payload errors so endpoint drift does not look like a successful empty search.

## Selected preload

- `rails-fields-kit--tom-select:selected-load`
  - Fired after selected option preload succeeds.
  - Detail: `{ values, options }`
- `rails-fields-kit--tom-select:selected-load-error`
  - Fired after selected option preload fails or returns a non-2xx response.
  - Detail: `{ operation, values, error, response, payload, status, surface }`

Use these hooks when the host app needs to know whether edit-form labels were resolved successfully before the user starts searching.

For a copyable field example that wires `selected_url:`, `selected-load`, `selected-load-error`, and `error_surface: true` together on one field, see [`setup.md`](setup.md). Keep the selected-option lookup endpoint itself in [`controller_helpers.md`](controller_helpers.md), and keep the visible fallback copy or retry UI in the host app.

## Create-on-the-fly

Create success now has a dedicated hook before the normal Tom Select interaction events continue:

- `rails-fields-kit--tom-select:create`
  - Fired after the create endpoint succeeds and before the created option is handed back to Tom Select.
  - Detail: `{ input, option }`
- `rails-fields-kit--tom-select:item-add`
  - Detail: `{ value, item, values }`
- `rails-fields-kit--tom-select:change`
  - Detail: `{ value, values }`

Use `create` when the host app needs to distinguish inline creation from ordinary selection, for example for analytics, toast messages, hidden field wiring, or follow-up fetches. Keep using `item-add` / `change` when the app only cares that the current selection changed.

Create failure keeps its own dedicated event:

- `rails-fields-kit--tom-select:create-error`
  - Fired when the create endpoint fails, returns a non-2xx response, or returns a 2xx JSON payload that does not describe an option.
  - Detail: `{ operation, input, error, response, payload, status, surface }`

Keep the visible fallback, retry affordance, and error copy in the host app. Rails Fields Kit only exposes the event detail and optional placeholder surface so the app can decide how to respond.
