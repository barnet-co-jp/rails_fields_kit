# Rails Fields Kit Controller Helpers

Rails Fields Kit provides `RailsFieldsKit::Searchable` for building JSON endpoints used by remote Tom Select fields.

```ruby
class CustomersController < ApplicationController
  include RailsFieldsKit::Searchable
end
```

## Remote workflow chooser

Use this overview to choose the endpoint helper before reading the detailed option reference below. Rails Fields Kit formats option JSON and wires the rendered field to the endpoint, while the host app still owns authentication, authorization, tenant scoping, query parsing, result execution, and persistence policy.

Scan by workflow first, then match the rendered field option to the controller helper. This keeps the endpoint route readable in narrow Markdown views without turning this page into the field-helper chooser.

### Remote search

- Use when the field should fetch option suggestions while the user types.
- Render with `rfk_combobox`, `rfk_autocomplete`, or another Tom Select-backed helper that has `url:`.
- Pair with `rfk_search_with` in the controller.

### Selected preload

- Use when the field must restore labels for saved values that are not present in the initial collection.
- Render with `selected_url:` plus `selected:` or persisted model values.
- Pair with `rfk_find_with` in the controller.

### Create-on-the-fly

- Use when the field may accept new option text and expects created option JSON back.
- Render with `create_url:`, `create_param:`, and optional `create_params:`. Treat `create_params:` as fixed JSON body values for the create `POST`, not as URL query params.
- Pair with `rfk_create_with` in the controller.

### Token suggestions

- Use when the field should suggest structured token text while submitted query parsing stays in the host app.
- Render with `rfk_token_search` and `url:`.
- Pair with `rfk_token_suggestions_with` in the controller.

Keep the FormBuilder request option and controller helper option aligned. For example, a field using `selected_param: "customer_id"` should pair with `rfk_find_with id_param: :customer_id`, and a field using `create_param: "name"` should pair with `rfk_create_with create_param: "name"`. If a field also uses `create_params:`, read those values as outgoing create JSON body fields; persist only explicitly accepted client fields through `permitted_attributes:` or trusted server-owned values through `assign:`. If the workflow question is mostly about which field helper to render, start from [`field_helpers.md`](field_helpers.md); this page focuses on endpoint responsibilities.

## `rfk_search_with`

Defines a search action, defaulting to `index`.

```ruby
rfk_search_with(
  action: :index,
  model: Customer,
  value: :id,
  label: :name,
  search: [:name, :email],
  value_field: "id",
  label_field: "name",
  description: :email,
  badge: :status,
  description_field: "email",
  badge_field: "status",
  query_param: "q",
  scope: -> { current_account.customers.active },
  order: { name: :asc },
  distinct: true,
  limit: 20,
  minimum_query_length: 1,
  wrap: "options"
)
```

### Common options

- `action:` action method to define. Defaults to `:index`.
- `model:` Active Record model or model-like class.
- `value:` method used for the submitted value.
- `label:` method used for the visible label.
- `search:` columns searched with the query string.
- `query_param:` request parameter name for the query. Defaults to `q`.
- `limit:` maximum number of records. Defaults to `20`.
- `minimum_query_length:` endpoint-side minimum query length. Defaults to `0`, preserving blank-query initial options.
- `scope:` base relation. Supports relation object, symbol scope, or callable evaluated in the controller instance.
- `order:` order passed to the relation.
- `distinct:` calls `distinct` before ordering/limiting.
- `wrap:` wraps the JSON response, commonly `"options"`.

### Trusted scope and order inputs

`scope:` and `order:` are endpoint-side relation helpers, not request-parameter sanitizers. Keep them on trusted relations, named model scopes, constants, or allowlisted values that the host app has already decided are safe.

For example, prefer a controller-owned allowlist when the UI lets a user choose sort order:

```ruby
SORT_ORDERS = {
  "name" => { name: :asc },
  "recent" => { created_at: :desc }
}.freeze

rfk_search_with(
  model: Customer,
  value: :id,
  label: :name,
  search: [:name, :email],
  scope: -> { current_account.customers.active },
  order: -> { SORT_ORDERS.fetch(params[:sort].to_s, SORT_ORDERS.fetch("name")) },
  wrap: "options"
)
```

Do not pass arbitrary request params directly into `order:` or use `scope:` to expose a relation the current user has not already been allowed to search. `assign:`, `authorize:`, and `before_save:` on create endpoints follow the same boundary: they are hooks for host-app policy and assignment logic, while authentication, authorization, tenant scoping, validation, and query execution decisions stay in the host app.

### Blank query policy

By default, `rfk_search_with` allows a blank query and returns the limited initial option list from the scoped relation. This keeps existing remote selects and comboboxes compatible with preload-style option lists.

Use `minimum_query_length:` when the endpoint itself should return no options until the incoming query is long enough:

```ruby
rfk_search_with(
  model: Customer,
  value: :id,
  label: :name,
  search: [:name, :email],
  minimum_query_length: 1,
  wrap: "options"
)
```

When the query is shorter than the endpoint minimum, the helper returns an empty options payload and preserves the configured `wrap:` shape, such as `{ "options": [] }`. It does not change authorization, tenant scoping, query parsing, Ransack integration, or Tom Select request lifecycle behavior.

FormBuilder's field-level `min_length:` is a browser-side loading hint for the bundled Tom Select controller. `minimum_query_length:` is the server endpoint policy for direct requests, custom Tom Select configs, or host apps that do not want blank queries to expose initial options. Use both when the UI and endpoint should enforce the same minimum.

Choose the blank-query behavior deliberately:

| Policy | FormBuilder option | Endpoint option | Blank or too-short request result |
| --- | --- | --- | --- |
| Allow a scoped initial option list | omit `min_length:` or keep it at `0` | omit `minimum_query_length:` or keep it at `0` | Returns the limited scoped relation in the configured `wrap:` shape. |
| Block empty or too-short server requests | set `min_length:` to the same threshold for the browser hint | set `minimum_query_length:` to the server threshold | Returns the empty wrapped collection, such as `{ "options": [] }`. |

For an endpoint that may show initial suggestions on focus, keep both sides permissive and rely on the host app's trusted scope and limit:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  open_on_focus: true,
  preload: true %>
```

```ruby
rfk_search_with(
  model: Customer,
  value: :id,
  label: :name,
  search: [:name, :email],
  scope: -> { current_account.customers.active },
  limit: 10,
  wrap: "options"
)
```

For an endpoint that should not expose options until the user types enough text, align the browser hint with the endpoint policy:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  min_length: 2 %>
```

```ruby
rfk_search_with(
  model: Customer,
  value: :id,
  label: :name,
  search: [:name, :email],
  scope: -> { current_account.customers.active },
  minimum_query_length: 2,
  wrap: "options"
)
```

The second setup still only shapes when options are returned. The host app remains responsible for authorization, tenant scoping, query parsing, search execution, and deciding whether blank queries should be allowed for each endpoint.

### Rich option fields

Use these to support rich Tom Select rendering.

- `description:` method/callable used for a secondary line.
- `badge:` method/callable used for a badge.
- `description_field:` output JSON key for the description.
- `badge_field:` output JSON key for the badge.

### Remote option label fallback

Remote search, selected preload, and create-on-the-fly options should include the configured `label_field:` whenever the endpoint knows a display label. If an option is missing that field, or the value is `null`, `undefined`, or an empty string in the browser, the Tom Select renderer falls back to the configured `value_field:` for the visible label. Explicit label values such as `0` or `false` are still displayed as labels.

This fallback is display-only. It does not change the submitted value, option payload, endpoint response shape, authorization boundary, or request lifecycle.

## `rfk_find_with`

Defines a selected-option lookup action, defaulting to `show`.

Use it with FormBuilder's `selected_url:` when the form has saved IDs but not display labels.

```ruby
rfk_find_with(
  action: :selected,
  model: Customer,
  value: :id,
  label: :name,
  description: :email,
  badge: :status,
  value_field: "id",
  label_field: "name",
  description_field: "email",
  badge_field: "status",
  id_param: :id,
  ids_param: :ids,
  scope: -> { current_account.customers },
  order: { name: :asc },
  preserve_order: true,
  wrap: "option"
)
```

Accepted request params:

- `id` for one value.
- `ids` for multiple values.
- comma-separated `ids`, such as `1,2,3`.
- Rails array params such as `ids[]=1&ids[]=2`, once Rails has parsed them into an Array value for `params[:ids]`.

The same string and Array handling applies when you use a custom `ids_param:`. Raw repeated query keys are only covered when the host app's request stack normalizes them to the configured param as an Array.

When a field customizes selected preload request names, keep the FormBuilder option and endpoint option in sync. Read the alignment as two lanes so the single-value and multiple-value request keys do not blur together:

- Single selected value:
  - FormBuilder option: `selected_param: "customer_id"`.
  - Outgoing selected preload param: `customer_id`.
  - Controller helper option: `rfk_find_with id_param: :customer_id`.
- Multiple selected values:
  - FormBuilder option: `selected_multiple_param: "customer_ids"`.
  - Outgoing selected preload param: `customer_ids`.
  - Controller helper option: `rfk_find_with ids_param: :customer_ids`.

```erb
<%= f.rfk_combobox :customer_id,
  selected_url: selected_customers_path(format: :json),
  selected: @order.customer_id,
  selected_param: "customer_id" %>
```

```ruby
rfk_find_with(
  action: :selected,
  model: Customer,
  value: :id,
  label: :name,
  id_param: :customer_id
)
```

For multiple selected values, `selected_multiple_param:` changes the request key only; the value can still be comma-separated, such as `customer_ids=1,2,3`, and `rfk_find_with ids_param:` reads that key.

Without an explicit `order:`, multiple selected preload responses follow the normalized incoming selected IDs by default, such as `ids=3,1,2` or parsed Rails array params. Rails Fields Kit fetches the scoped records normally, skips missing IDs, and sorts the returned records in Ruby by the configured `value:` attribute; repeated incoming IDs do not by themselves duplicate otherwise unique relation records. A custom `value_field:` only changes the output key; it does not change which record attribute is used for this ordering. This avoids database-specific ordering SQL and does not change authorization, scoping, or query execution.

Supplying `order:` makes the relation order the response-order source of truth. Add `preserve_order: true` only when the relation still needs `order:` while the final selected preload payload must return to incoming ID order. Use one of those final payload policies per endpoint when possible: `order:` for relation-owned ordering, or incoming order (the default without `order:`, and explicit with `preserve_order: true`) for saved-value display order.

Tom Select registers and restores selected items in the endpoint response order. The `selected-load` event keeps `detail.options` in that response order and `detail.values` in the original requested order, so host code can distinguish the hydrated option sequence from the saved value request. A custom selected preload endpoint must therefore return options in its intended visible restore order; `rfk_find_with` provides the policies above without changing client-side item order.

The response can be a single option, a wrapped option, an array of options, or a wrapped collection depending on the request. See [Output shape](#output-shape) for the supported collection wrappers.

## `rfk_create_with`

Defines a create-on-the-fly action, defaulting to `create`.

```ruby
rfk_create_with(
  action: :create,
  model: Customer,
  value: :id,
  label: :name,
  create_attribute: :name,
  create_param: "name",
  permitted_attributes: [:source],
  assign: ->(_customer) { { account_id: current_account.id } },
  authorize: ->(customer) { policy(customer).create? },
  before_save: :normalize_customer,
  value_field: "id",
  label_field: "name",
  description: :email,
  badge: :status,
  description_field: "email",
  badge_field: "status",
  wrap: "option"
)
```

### Create options

- `action:` action method to define. Defaults to `:create`.
- `create_attribute:` model attribute to set from the incoming text.
- `create_param:` request parameter name. Defaults to `text`.
- `permitted_attributes:` additional request parameter names to merge into the new record through `params.permit(...)`. Use it only for attributes the host app has decided are safe to accept from the create request.
- `assign:` extra attributes assigned before validation. Supports hash, method name, or callable.
- `authorize:` returns whether the create is allowed. Supports method name or callable. Returns `403` when false.
- `before_save:` hook called before `save`. Supports method name or callable. Returns `422` when false.
- `wrap:` wraps the JSON response, commonly `"option"`.

### Create request contract

When a FormBuilder field has `create_url:`, the Tom Select controller sends create-on-the-fly input as a JSON `POST` request to that URL. The request includes these headers:

- `Accept: application/json`
- `Content-Type: application/json`
- `X-CSRF-Token` when the page has a Rails `<meta name="csrf-token">` tag

The JSON body merges fixed `create_params:` values first, then writes the user's input under `create_param:`. With this field:

```erb
<%= f.rfk_combobox :customer_id,
  create_url: customers_path,
  create_param: "name",
  create_params: { source: "quick_create" } %>
```

Rails Fields Kit posts a body shaped like this:

```json
{ "source": "quick_create", "name": "New Customer" }
```

The endpoint-side `rfk_create_with create_param:` option must read the same key that the field sends. If the endpoint should persist additional incoming fields, list only those safe attribute names in `permitted_attributes:`:

```ruby
rfk_create_with(
  action: :create,
  model: Customer,
  value: :id,
  label: :name,
  create_attribute: :name,
  create_param: "name",
  permitted_attributes: [:source],
  assign: ->(_customer) { { account_id: current_account.id } }
)
```

`permitted_attributes:` is a strong-params allowlist for extra request fields that should become model attributes. It is separate from `create_params:`, which only shapes the outgoing request body from the rendered field, and separate from `assign:`, which applies server-owned attributes or policy-derived values before validation.

`create_params:` is only request shaping. Treat incoming fixed values as hints or context from the rendered page; keep tenant scoping, authentication, authorization, CSRF policy, model validation, and persisted assignment decisions in the host app controller/model layer. Prefer `assign:`, `authorize:`, `before_save:`, model validations, or ordinary controller policy for server-side enforcement. Do not rely on `permitted_attributes:` for tenant IDs, authorization decisions, ownership, or other values that must come from trusted server-side state.

Use the standard RESTful `POST /customers` action when create-on-the-fly should share the host app's ordinary resource create path. Use a dedicated collection `POST` action when the option creation flow needs a narrower authorization policy, assignment rule, or response shape than the normal resource create action.

## Fixed request params and scoping

FormBuilder options such as `query_params:`, `selected_query_params:`, and `create_params:` are request-shaping helpers. They add fixed values to the outgoing remote search, selected preload, or create request, but they do not move authorization, tenant scoping, validation, or assignment policy into Rails Fields Kit.

Use fixed params for contextual values that the endpoint still verifies with server-side state. For example, an app may render `query_params: { account_id: current_account.id }` so the request carries an account hint, while the controller still scopes through a trusted relation such as `scope: -> { current_account.customers }` instead of trusting the incoming `params[:account_id]` by itself.

Array values on `query_params:` and `selected_query_params:` stay in the URL query lane. Rails Fields Kit appends one entry per value, so a field like this:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  query_params: { account_id: current_account.id, status: ["active", "priority"] },
  selected_query_params: { account_id: current_account.id, status: ["active", "priority"] } %>
```

sends fixed scope as repeated query entries such as `status=active&status=priority` on remote search and selected preload requests. The endpoint should still reduce those values to an allowlisted, trusted relation, for example by intersecting `Array(params[:status])` with the statuses the current user may search before applying the relation scope. Do not treat the repeated query entries as authorization, tenant ownership, query execution, or Ransack parsing policy.

The same boundary applies to create-on-the-fly fields: `create_params:` adds fixed JSON fields to the request body, but `rfk_create_with` should still use `assign:`, `authorize:`, `before_save:`, model validations, or ordinary controller policy to decide what can be persisted. Use `permitted_attributes:` only when the endpoint intentionally accepts additional request fields as model attributes after Rails strong-params filtering; it is not a substitute for server-side tenant scoping or authorization.

## `rfk_token_suggestions_with`

Defines a lightweight token suggestion action, defaulting to `index`. Use it with `rfk_token_search` when suggestions are static, generated from controller context, or not tied to a single Active Record search relation.

```ruby
rfk_token_suggestions_with(
  action: :index,
  suggestions: [
    "status:open",
    ["Assigned to me", "assignee:me"],
    { token: "priority:high", label: "High priority", description: "Urgent items", badge: "operator" }
  ],
  value_field: "value",
  label_field: "text",
  query_param: "q",
  limit: 20,
  wrap: "options"
)
```

`suggestions:` accepts:

- an array of strings
- an array of `[label, value]` pairs
- hashes using keys such as `value`, `text`, `label`, `token`, `description`, and `badge`
- a method name that receives the current query
- a callable evaluated in the controller instance with the current query

Example with controller context:

```ruby
rfk_token_suggestions_with(
  action: :search_tokens,
  suggestions: ->(query) {
    [
      { token: "status:#{query}", label: "Status #{query}", badge: "operator" },
      { token: "assignee:me", label: "Assigned to me" }
    ]
  },
  value_field: "token",
  label_field: "label",
  badge_field: "kind",
  wrap: "options"
)
```

The helper filters normalized suggestions by the incoming query before applying `limit:`. It only returns suggestion option JSON; parsing and applying submitted token search text remains the host application's responsibility.

## Output shape

By default, options are returned as plain objects.

```json
{ "value": 1, "text": "Acme Corp" }
```

Custom output keys are supported:

```ruby
value_field: "id",
label_field: "name",
description_field: "email",
badge_field: "status"
```

```json
{
  "id": 1,
  "name": "Acme Corp",
  "email": "hello@acme.example",
  "status": "active"
}
```

Remote search and selected preload can return option collections as a raw array or as a wrapped collection. Both `options` and `results` are supported collection wrapper keys:

```json
{ "options": [ { "id": 1, "name": "Acme Corp" } ] }
```

```json
{ "results": [ { "id": 1, "name": "Acme Corp" } ] }
```

Selected preload can also return a single option directly or wrapped under `option`:

```json
{ "option": { "id": 1, "name": "Acme Corp" } }
```

`results` is only a collection wrapper for remote search and selected preload. Create-on-the-fly responses use a single option object or the `option` wrapper; Rails Fields Kit does not treat `results` as pagination metadata or an arbitrary response adapter contract.

## Suggested routes

The common editable combobox setup can keep create-on-the-fly on the standard RESTful `POST /customers` route while adding only selected lookup and token suggestions as collection `GET` actions:

```ruby
resources :customers do
  collection do
    get :selected
    get :search_tokens
  end
end
```

This route set gives the controller helpers separate endpoint roles:

- `GET /customers` for remote search when `rfk_search_with action: :index` is used with `url: customers_path(format: :json)`.
- `GET /customers/selected` for selected preload when `rfk_find_with action: :selected` is used with `selected_url: selected_customers_path(format: :json)`.
- `GET /customers/search_tokens` for token suggestions when `rfk_token_suggestions_with action: :search_tokens` is used with a token suggestion URL.
- `POST /customers` for create-on-the-fly when `rfk_create_with action: :create` is used with `create_url: customers_path`.

If the host app should not share its ordinary resource create action with create-on-the-fly, add a dedicated collection `POST` route and point both `action:` and `create_url:` at that route instead:

```ruby
resources :customers do
  collection do
    get :selected
    get :search_tokens
    post :create_option
  end
end
```

```ruby
rfk_create_with action: :create_option, model: Customer, value: :id, label: :name, create_attribute: :name
```

Then map actions as needed:

```ruby
class CustomersController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_search_with action: :index, model: Customer, value: :id, label: :name, search: [:name]
  rfk_find_with action: :selected, model: Customer, value: :id, label: :name
  rfk_create_with action: :create, model: Customer, value: :id, label: :name, create_attribute: :name
  rfk_token_suggestions_with action: :search_tokens, suggestions: ["status:open", "status:closed"]
end
```
