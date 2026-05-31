# Rails Fields Kit Controller Helpers

Rails Fields Kit provides `RailsFieldsKit::Searchable` for building JSON endpoints used by remote Tom Select fields.

```ruby
class CustomersController < ApplicationController
  include RailsFieldsKit::Searchable
end
```

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
- `scope:` base relation. Supports relation object, symbol scope, or callable evaluated in the controller instance.
- `order:` order passed to the relation.
- `distinct:` calls `distinct` before ordering/limiting.
- `wrap:` wraps the JSON response, commonly `"options"`.

### Rich option fields

Use these to support rich Tom Select rendering.

- `description:` method/callable used for a secondary line.
- `badge:` method/callable used for a badge.
- `description_field:` output JSON key for the description.
- `badge_field:` output JSON key for the badge.

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
  wrap: "option"
)
```

Accepted request params:

- `id` for one value.
- `ids` for multiple values.
- comma-separated `ids`, such as `1,2,3`.

When a field customizes selected preload request names, keep the FormBuilder option and endpoint option in sync:

| FormBuilder option | Outgoing selected preload param | `rfk_find_with` option |
| --- | --- | --- |
| `selected_param: "customer_id"` | `customer_id` for one value | `id_param: :customer_id` |
| `selected_multiple_param: "customer_ids"` | `customer_ids` for multiple values | `ids_param: :customer_ids` |

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

The response can be a single option or an array of options depending on the request.

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
  create_params: { account_id: current_account.id } %>
```

Rails Fields Kit posts a body shaped like this:

```json
{ "account_id": 123, "name": "New Customer" }
```

The endpoint-side `rfk_create_with create_param:` option must read the same key that the field sends:

```ruby
rfk_create_with(
  action: :create,
  model: Customer,
  value: :id,
  label: :name,
  create_attribute: :name,
  create_param: "name",
  assign: ->(_customer) { { account_id: current_account.id } }
)
```

`create_params:` is only request shaping. Treat incoming fixed values as hints or context from the rendered page; keep tenant scoping, authentication, authorization, CSRF policy, model validation, and persisted assignment decisions in the host app controller/model layer. Prefer `assign:`, `authorize:`, `before_save:`, model validations, or ordinary controller policy for server-side enforcement.

Use the standard RESTful `POST /customers` action when create-on-the-fly should share the host app's ordinary resource create path. Use a dedicated collection `POST` action when the option creation flow needs a narrower authorization policy, assignment rule, or response shape than the normal resource create action.

## Fixed request params and scoping

FormBuilder options such as `query_params:`, `selected_query_params:`, and `create_params:` are request-shaping helpers. They add fixed values to the outgoing remote search, selected preload, or create request, but they do not move authorization, tenant scoping, validation, or assignment policy into Rails Fields Kit.

Use fixed params for contextual values that the endpoint still verifies with server-side state. For example, an app may render `query_params: { account_id: current_account.id }` so the request carries an account hint, while the controller still scopes through a trusted relation such as `scope: -> { current_account.customers }` instead of trusting the incoming `params[:account_id]` by itself.

The same boundary applies to create-on-the-fly fields: `create_params:` adds fixed JSON fields to the request body, but `rfk_create_with` should still use `assign:`, `authorize:`, `before_save:`, model validations, or ordinary controller policy to decide what can be persisted.

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

Wrapped responses are supported:

```json
{ "options": [ { "id": 1, "name": "Acme Corp" } ] }
```

```json
{ "option": { "id": 1, "name": "Acme Corp" } }
```

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