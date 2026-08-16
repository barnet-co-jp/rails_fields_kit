# Rails Fields Kit events

Rails Fields Kit dispatches Stimulus events from the `rails-fields-kit--tom-select` controller so applications can attach UI feedback without replacing the built-in controller.

These events are integration hooks. Rails Fields Kit does not render visible success or error messages by itself, so host applications should subscribe to the events they care about and decide how to show feedback.

Separately from request-failure events, Tom Select dropdown messages rendered from `no_results_text:` and `loading_text:` are short status messages inside the dropdown. The bundled renderer emits those no-results and loading messages with `role="status"`, `aria-live="polite"`, and `aria-atomic="true"` so copy overrides remain accessible status text. Keep those overrides short and state-like; long help, retry controls, loading policy, endpoint behavior, and visible feedback outside the dropdown remain host-app responsibilities.

When a field is rendered with `error_surface: true`, the controller also includes `detail.surface` on request-failure events. That surface is an opt-in empty placeholder element near the field where the host app can render its own message or retry UI.

By default, Rails Fields Kit generates the placeholder id from the form object and method, such as `dummy_model_customer_id_error_surface`. If the same object and method are rendered more than once on a page, pass an explicit `error_surface_html: { id: "..." }` for each field instance. The explicit id is used consistently for the surface element, the field's `aria-describedby`, and the controller data value that resolves `event.detail.surface`.

The generated placeholder is hidden until the controller exposes a request failure, and defaults to `role="status"`, `aria-live="polite"`, `aria-atomic="true"`, and the `rfk-tom-select-error-surface` class. Those defaults make the empty element safe for host-owned accessible feedback without adding visible copy. Host applications can pass explicit `role`, `aria-live`, or `aria-atomic` values through `error_surface_html:` when a field needs a different live-region contract, but Rails Fields Kit still owns only the placeholder wiring.

Rails Fields Kit marks that placeholder with request state metadata before dispatching the failure event. The attributes use the same operation and status values as the event detail:

- `data-rfk-error-state="error"`
- `data-rfk-error-operation="load"`, `"selected-load"`, or `"create"`
- `data-rfk-error-status` when an HTTP status is available

Use those attributes for host-owned CSS, analytics, or lightweight event handlers that need to tell remote search, selected preload, and create-on-the-fly failures apart. They do not make Rails Fields Kit responsible for visible message text, retry UI, loading UI, or endpoint policy. The controller clears the attributes when it hides the opt-in placeholder.

## Event map

| Workflow | Success surface | Failure surface | Notes |
| --- | --- | --- | --- |
| Remote search | `rails-fields-kit--tom-select:load` | `rails-fields-kit--tom-select:load-error` | Use when the app needs the fetched option payloads. |
| Dependency-param change | `rails-fields-kit--tom-select:dependency-change` | — | Host-app follow-up signal after effective dependency params change. |
| Selected preload | `rails-fields-kit--tom-select:selected-load` | `rails-fields-kit--tom-select:selected-load-error` | Use when edit forms need labels for already-selected IDs. |
| Create-on-the-fly | `rails-fields-kit--tom-select:create`, `rails-fields-kit--tom-select:item-add`, and `rails-fields-kit--tom-select:change` | `rails-fields-kit--tom-select:create-error` | Use `create` when the app needs a dedicated hook before ordinary selection events. |

For dependency-driven remote-search setup, merge order, selection clearing, and reconnect behavior, see [`dependent_query_params.md`](dependent_query_params.md). Endpoint semantics, authorization, business rules, and visible feedback remain host-app responsibilities.

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

## Dependency changes

- `rails-fields-kit--tom-select:dependency-change`
  - Fired after the effective dependency params change, after any in-flight remote search is aborted, cached remote options are cleared, optional selection clearing has run, and an open dropdown has been asked to reload its current query.
  - Detail: `{ params, previousParams, changed }`

`params` is the current dependency-param object, `previousParams` is the prior dependency-param object, and `changed` maps each changed key to `{ previous, current }`. No event is dispatched when an `input` or `change` notification leaves the effective dependency params unchanged.

Use this as a host-app follow-up signal when app-owned state or UI needs to react to changed dependency params. It does not make Rails Fields Kit responsible for business logic, endpoint behavior, authorization, or visible feedback.

For dependency setup, request-param merge order, selection clearing, and reconnect behavior, see [`dependent_query_params.md`](dependent_query_params.md).

## Selected preload

- `rails-fields-kit--tom-select:selected-load`
  - Fired after selected option preload succeeds.
  - Detail: `{ values, options }`
- `rails-fields-kit--tom-select:selected-load-error`
  - Fired after selected option preload fails, returns a non-2xx response, or returns 2xx JSON that is empty or does not contain usable option objects with the configured value field.
  - Detail: `{ operation, values, error, response, payload, status, surface }`

Use these hooks when the host app needs to know whether edit-form labels were resolved successfully before the user starts searching.

For selected preload endpoint payload shapes, including invalid 2xx payloads that enter the `selected-load-error` lane instead of creating incomplete options, see [`selected_preload_contract.md`](selected_preload_contract.md). Keep authorization, missing-record policy, visible fallback copy, and retry UI in the host app.

For a copyable field example that wires `selected_url:`, `selected-load`, `selected-load-error`, and `error_surface: true` together on one field, see [`setup.md`](setup.md). Keep the selected-option lookup endpoint itself in [`controller_helpers.md`](controller_helpers.md), and keep the visible fallback copy or retry UI in the host app.

## Create-on-the-fly

Create success now has a dedicated hook before the normal Tom Select interaction events continue:

- `rails-fields-kit--tom-select:create`
  - Fired after the create endpoint succeeds and before the created option is handed back to Tom Select.
  - Detail: `{ input, option }`
- `rails-fields-kit--tom-select:item-add`
  - Detail: `{ value, item, values, option, options }`
- `rails-fields-kit--tom-select:change`
  - Detail: `{ value, values, option, options }`

Use `create` when the host app needs to distinguish inline creation from ordinary selection, for example for analytics, toast messages, hidden field wiring, or follow-up fetches. Keep using `item-add` / `change` when the app only cares that the current selection changed. The forwarded `option` and `options` fields expose the selected option payloads after Tom Select accepts the value, so host apps do not need to read `tomSelect.options[value]` directly.

Create failure keeps its own dedicated event:

- `rails-fields-kit--tom-select:create-error`
  - Fired after create-on-the-fly fails, returns a non-2xx response, or returns 2xx JSON without a usable option object containing the configured value field.
  - Detail: `{ operation, input, error, response, payload, status, surface }`

The create endpoint must return either an option object or `{ option: { ... } }` with a present configured value field. Values such as `0` and `false` remain valid; `null`, an empty string, a missing value field, a non-object payload, or an empty wrapped option are payload-shape failures. A missing label can still use the documented display-only value fallback, so it does not by itself make the option invalid.

Use `create-error` when the host app wants to show validation feedback, retry affordances, or analytics for failed inline creation.

For a copyable field example that wires `create_url:`, `create`, `create-error`, and `error_surface: true` together on one field, see [`setup.md`](setup.md). Keep the actual visible copy and retry policy in the host app, even when the app writes that feedback into `detail.surface`.

If the host app writes its inline error copy into `detail.surface`, keep that copy inside the placeholder element itself. The controller clears and hides that placeholder before a fresh remote request, after successful selected preload or create, and again when forwarded interaction events such as `change`, `item-add`, `item-remove`, or `clear` fire.

If the app mirrors the same error in another element, clear that extra UI from the same success or follow-up hooks. Rails Fields Kit only resets the opt-in placeholder that it rendered.

## Copyable request-failure recipes

Use one small host-app controller when a field needs separate handling for remote search, selected preload, and create-on-the-fly failures. Keep the field helper responsible for wiring the existing events, and keep message copy, retry controls, analytics, and any extra UI state in the host app.

```erb
<div data-controller="customers">
  <%= f.rfk_combobox :customer_id,
    url: customers_path(format: :json),
    selected_url: selected_customers_path(format: :json),
    create_url: customers_path,
    selected: @order.customer_id,
    error_surface: true,
    html: {
      data: {
        action: "rails-fields-kit--tom-select:load->customers#clearFeedback rails-fields-kit--tom-select:selected-load->customers#clearFeedback rails-fields-kit--tom-select:create->customers#clearFeedback rails-fields-kit--tom-select:change->customers#clearFeedback rails-fields-kit--tom-select:load-error->customers#remoteSearchFailed rails-fields-kit--tom-select:selected-load-error->customers#selectedPreloadFailed rails-fields-kit--tom-select:create-error->customers#createFailed"
      }
    } %>

  <div data-customers-target="feedback" role="status" aria-live="polite"></div>
</div>
```

```js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["feedback"]

  remoteSearchFailed(event) {
    this.showFailure(event, "Unable to load matching customers.")
  }

  selectedPreloadFailed(event) {
    this.showFailure(event, "Unable to restore the saved customer label.")
  }

  createFailed(event) {
    this.showFailure(event, "Unable to create that customer.")
  }

  clearFeedback(event) {
    if (event.detail?.surface) event.detail.surface.textContent = ""
    if (this.hasFeedbackTarget) this.feedbackTarget.textContent = ""
  }

  showFailure(event, fallbackMessage) {
    const { payload, status, surface } = event.detail
    const message = payload?.error || payload?.message || fallbackMessage

    if (surface) surface.textContent = message
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = status ? `${message} (${status})` : message
    }
  }
}
```

This recipe intentionally uses only the current `load-error`, `selected-load-error`, and `create-error` hooks. It does not add a request-start event, built-in loading UI, built-in retry UI, toast UI, or a new payload shape. If the app renders retry buttons, loading affordances, or analytics from these hooks, keep those policies in the host controller and clear any UI outside `detail.surface` from the same success or follow-up hooks that clear `feedbackTarget` above.

If the host app only wants field-adjacent visible copy, writing to `detail.surface` is enough. If the app mirrors the same message into another target, that mirror is app-owned state, so clear it explicitly on the success or interaction hooks the app cares about.

## Interaction forwarding

These events forward common Tom Select interactions:

- `rails-fields-kit--tom-select:change`
  - Detail: `{ value, values, option, options }`
- `rails-fields-kit--tom-select:item-add`
  - Detail: `{ value, item, values, option, options }`
- `rails-fields-kit--tom-select:item-remove`
  - Detail: `{ value, item, values, option, options }`
- `rails-fields-kit--tom-select:clear`
  - Detail: `{ values, options }`

These are useful even when the field does not use remote search or create-on-the-fly. The `values` array mirrors Tom Select's current value after Rails Fields Kit normalizes it with the same helper used by the other interaction events. The `option` field is the Tom Select option payload for the event value, or `null` when no option exists for that value, such as free text. The `options` array mirrors `values` and contains each current selected option payload, preserving additional fields returned by remote search, selected preload, create-on-the-fly, or collection-backed select setup; values without an option are represented as `null` in the same position.

For single-value fields, Tom Select's scalar cleared value is wrapped, so a clear event typically has `values: [""]` and `options: [null]`. For multiple-value fields, clear keeps Tom Select's empty array shape as `values: []` and `options: []`.

Rails Fields Kit only exposes the selected candidate payloads on the event. Reflecting business metadata such as price, unit, account, category, or secondary display fields into other controls remains host-app responsibility.

## Choosing the right hook

- Use `load` / `selected-load` when the app cares about fetched option payloads.
- Use `create` when the app needs a dedicated success hook for inline creation.
- Use `item-add` / `change` when the app cares that the selection actually changed after Tom Select accepted the value and needs the selected `option` / `options` payload.
- Use `load-error`, `selected-load-error`, or `create-error` when the app wants visible error UI, retry UI, or logging.
- Use `detail.surface` with `error_surface: true` when the app wants a stable placeholder next to the field without replacing the controller.
- Keep `no_results_text:` and `loading_text:` as dropdown-local status copy overrides, not request-failure UI or retry surfaces.
- Keep visible feedback in the host app. Rails Fields Kit only dispatches the events.

Example:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  error_surface: true,
  html: {
    data: {
      action: "rails-fields-kit--tom-select:create->customers#created rails-fields-kit--tom-select:create-error->customers#error rails-fields-kit--tom-select:item-add->customers#selected"
    }
  } %>
```

```js
error(event) {
  const { surface, payload } = event.detail
  if (!surface) return

  surface.textContent = payload?.error || "Unable to load options"
}
```
