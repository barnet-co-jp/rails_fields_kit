# Rails Fields Kit

Rails Fields Kit is a Rails form helper kit for fields that are still awkward with native HTML inputs alone: searchable selects, editable comboboxes, tag inputs, autocomplete, token search inputs, and create-on-the-fly fields.

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

For the current direction and integration priorities, see [Roadmap](ROADMAP.md).
For optional table integration metadata, see [Table adapter metadata](doc/table_adapters.md). This lets table-oriented gems read Rails Fields Kit filter/editor metadata through `to_table_filter` and `to_table_cell_editor` without taking a hard dependency.
See [`doc/setup.md`](doc/setup.md) for a complete setup walkthrough.
See [`doc/public_api.md`](doc/public_api.md) for the intended stable API surface.
See [`doc/field_helpers.md`](doc/field_helpers.md) for the FormBuilder helper reference.
See [`doc/controller_helpers.md`](doc/controller_helpers.md) for the controller helper reference.
See [`doc/configuration.md`](doc/configuration.md) for initializer options.
See [`doc/events.md`](doc/events.md) for Stimulus events dispatched by the Tom Select controller.
See [`doc/development.md`](doc/development.md) for local development checks.
See [`doc/sample_app_checklist.md`](doc/sample_app_checklist.md) and [`doc/sample_app_results.md`](doc/sample_app_results.md) for sample app verification.
See [`doc/final_release_checklist.md`](doc/final_release_checklist.md) for the final release checklist.
See [`doc/release_notes_0_1_0.md`](doc/release_notes_0_1_0.md) for the 0.1.0 release notes draft.

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
    selected_url: selected_customers_path(format: :json),
    create_url: customers_path,
    selected: @order.customer_id,
    value_field: "id",
    label_field: "name",
    search_field: "name,email",
    query_param: "q",
    selected_param: "id",
    selected_multiple_param: "ids",
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
    query_params: { account_id: current_account.id },
    selected_query_params: { account_id: current_account.id },
    create_params: { account_id: current_account.id },
    placeholder: "Search or create a customer" %>
<% end %>
```

`selected:` preloads the current option for edit forms before remote search runs. It accepts a record, a `{ value:, text: }` hash, a `{ id:, name: }` hash, an ID value, or an array of any of those for multiple fields.

When `selected_url:` is provided, Rails Fields Kit can load missing selected option labels from the server after Tom Select connects. This is useful when the form only has stored IDs and not the display labels. For one value it sends `selected_param`, default `id`; for multiple values it sends `selected_multiple_param`, default `ids`.

Selected preload dispatches these Stimulus events:

- `rails-fields-kit--tom-select:selected-load`
- `rails-fields-kit--tom-select:selected-load-error`

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

The selected preload endpoint can return one option, a wrapped option, an array, or a wrapped array:

```json
{ "option": { "id": 1, "name": "Example Customer" } }
```

The create endpoint should return the created option object:

```json
{ "id": 2, "name": "New Customer" }
```

When the create endpoint returns a non-2xx response, Rails Fields Kit does not add a fallback free-text option. It dispatches a `rails-fields-kit--tom-select:create-error` event with the failed input and error payload so your application can show a validation message.

### Token search

Use `rfk_token_search` when you want a search box for structured phrases such as `status:open assignee:matsuo keyword`, while keeping query parsing and result filtering in your application or search object.

```erb
<%= form_with url: orders_path, method: :get do |f| %>
  <%= f.rfk_token_search :query,
    url: search_token_suggestions_path(format: :json),
    placeholder: "status:open keyword",
    max_items: 20,
    load_throttle: 250,
    query_params: { context: "orders" } %>
<% end %>
```

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

### Multiple selects and tags

Use `rfk_multi_select` for ordinary multiple selects and `rfk_tags` for tag-style inputs. Both render array-style parameter names and Rails' hidden blank input by default, so clearing all selected values still submits an empty value.