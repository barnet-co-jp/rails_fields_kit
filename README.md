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

`selected:` preloads the current option for edit forms before remote search runs. It accepts a record, a `{ value:, text: }` hash, a `{ id:, name: }` hash, or an array of any of those for multiple fields.

Remote options can include extra fields for richer rendering:

```json
[
  { "id": 1, "name": "Example Customer", "email": "hello@example.com", "status": "active" }
]
```

Then set `option_description_field:` and `option_badge_field:` to show those fields in Tom Select's dropdown and selected item rendering.

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

### Object collections, grouped selects, and enum selects

Collections can be arrays of pairs, hashes, or model-like objects:

```erb
<%= f.rfk_select :customer_id,
  collection: @customers,
  collection_value_method: :id,
  collection_label_method: :name %>
```

Grouped selects render `<optgroup>` elements:

```erb
<%= f.rfk_grouped_select :customer_id,
  grouped_collection: {
    "Active" => [["Acme Corp", 1]],
    "Archived" => [["Old Corp", 2]]
  } %>
```

Options can be disabled or receive per-option HTML attributes:

```erb
<%= f.rfk_select :status,
  collection: { "Draft" => "draft", "Published" => "published" },
  disabled: ["published"],
  option_html: {
    "draft" => { data: { color: "gray" } }
  } %>
```

Rails enum-like attributes can use `rfk_enum_select`:

```erb
<%= f.rfk_enum_select :status %>
```

It reads `object.class.statuses` by default and uses `human_attribute_name("status.draft")` style labels when available.

### Multiple selects and tags

Use `rfk_multi_select` for ordinary multiple selects and `rfk_tags` for tag-style inputs. Both render array-style parameter names and Rails' hidden blank input by default, so clearing all selected values still submits an empty value.

```erb
<%= f.rfk_multi_select :category_ids,
  collection: Category.order(:name),
  collection_value_method: :id,
  collection_label_method: :name %>

<%= f.rfk_tags :tag_ids,
  url: tags_path(format: :json),
  selected: @post.tags,
  value_method: :id,
  label_method: :name,
  create: true %>
```

If you do not want Rails' hidden blank input, pass `include_hidden: false`:

```erb
<%= f.rfk_multi_select :category_ids,
  collection: @categories,
  include_hidden: false %>
```

### Wrappers, native attributes, and accessibility

When `wrapper: true` is used, Rails Fields Kit renders labels, hints, and errors with stable IDs and connects them to the field using `aria-describedby`. Fields with validation errors also get `aria-invalid="true"`. Wrapped required fields get `aria-required="true"`.

```erb
<%= f.rfk_select :status,
  collection: Order.statuses.keys,
  wrapper: true,
  hint: "Choose the workflow status",
  required: true %>
```

Tom Select-backed helpers pass common native attributes through to the underlying input/select:

```erb
<%= f.rfk_select :status,
  collection: Order.statuses.keys,
  required: true,
  disabled: false,
  autocomplete: "off" %>

<%= f.rfk_autocomplete :keyword,
  url: suggestions_path(format: :json),
  readonly: true %>
```

You can disable accessibility automation for a specific field:

```erb
<%= f.rfk_text_field :name,
  wrapper: true,
  hint: "Internal display name",
  accessibility: false %>
```

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
    description: :email,
    badge: :status,
    description_field: "email",
    badge_field: "status",
    scope: -> { current_account.customers.active },
    order: { name: :asc },
    distinct: true,
    limit: 20,
    wrap: "options"
  )

  rfk_create_with(
    model: Customer,
    value: :id,
    label: :name,
    create_attribute: :name,
    create_param: "name",
    value_field: "id",
    label_field: "name",
    description: :email,
    badge: ->(customer) { customer.status.upcase },
    description_field: "email",
    badge_field: "status",
    assign: ->(_customer) { { account_id: current_account.id } },
    authorize: ->(customer) { policy(customer).create? },
    before_save: :normalize_customer,
    wrap: "option"
  )

  private

  def normalize_customer(customer)
    customer.name = customer.name.strip
    true
  end
end
```

`scope:` can be a relation, a model scope name such as `:active`, or a callable evaluated in the controller instance. `order:` and `distinct:` are applied before `limit:`.

`assign:` can be a hash, method name, or callable that returns attributes to assign before save. `authorize:` can be a method name or callable; returning `false` renders `403 Forbidden`. `before_save:` can be a method name or callable; returning `false` renders `422 Unprocessable Entity` without saving.

`description:` and `badge:` can be method names or callables. They are useful with `option_description_field:` and `option_badge_field:` on the field helper.

`wrap:` is optional. Without it, search returns an array and create returns a single option object. With `wrap: "options"`, search returns `{ "options": [...] }`. With `wrap: "option"`, create returns `{ "option": {...} }`.

`rfk_create_with` renders `422 Unprocessable Entity` with `{ "errors": ... }` when the record is invalid.

### Normal select wrapper

```erb
<%= f.rfk_select :status, collection: Order.statuses.keys, allow_clear: true %>
```

### Autocomplete text field

```erb
<%= f.rfk_autocomplete :keyword,
  url: suggestions_path(format: :json),
  free_text: true %>
```

### Native and business-friendly fields

These helpers use native HTML inputs but share the optional wrapper, label, hint, error, prefix, and suffix behavior:

```erb
<%= f.rfk_text_field :name, wrapper: true, label: "Name" %>
<%= f.rfk_text_area :description, wrapper: true %>
<%= f.rfk_number_field :quantity, min: 1, step: 1 %>
<%= f.rfk_money_field :amount, currency: "JPY", wrapper: true %>
<%= f.rfk_percent_field :tax_rate, wrapper: true %>
<%= f.rfk_email_field :email %>
<%= f.rfk_url_field :website_url %>
<%= f.rfk_phone_field :phone %>
<%= f.rfk_search_field :keyword %>
```

Any wrapped field can use custom affixes:

```erb
<%= f.rfk_text_field :code, prefix: "#", suffix: "required", wrapper: true %>
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
  config.default_max_options = nil
  config.default_preload = nil
  config.default_open_on_focus = nil
  config.default_close_after_select = nil
  config.default_hide_selected = nil
  config.default_persist = nil
  config.default_no_results_text = "No results found"
  config.default_loading_text = "Loading..."
  config.default_create_text = "Add"
  config.default_option_description_field = nil
  config.default_option_badge_field = nil
  config.default_plugins = []

  config.wrapper_class = "rfk-field"
  config.label_class = "rfk-label"
  config.hint_class = "rfk-hint"
  config.error_class = "rfk-error"
  config.field_error_class = "rfk-field--error"
  config.control_class = "rfk-control"
  config.prefix_class = "rfk-prefix"
  config.suffix_class = "rfk-suffix"
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
- light wrappers around native inputs for consistent labels, hints, errors, and affixes

Select-like fields are powered by Tom Select. When Tom Select already supports the behavior directly, Rails Fields Kit acts as a thin Rails wrapper. When Rails integration is the hard part, such as initial value preload or create-on-the-fly records, Rails Fields Kit provides a higher-level field helper.

## Development

```bash
git pull
bundle install
bundle exec rspec
```

CI is intentionally not required during early implementation.
