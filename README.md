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

Use the generated `doc/rails_fields_kit_setup.md` in your host app as a short checklist and place for app-specific notes. The maintained setup walkthrough and source of truth for setup examples stays in this repository at [`doc/setup.md`](doc/setup.md).

Rails Fields Kit ships Rails helpers, a Rails engine, a Stimulus controller, and controller-side helpers. It does not install Tom Select or choose a JavaScript bundling strategy for your app.

For the current direction and integration priorities, see the repository roadmap: <https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/ROADMAP.md>.
For repo positioning and responsibility boundaries, see the repository [Product profile](https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/Product%20Profile.md).
For repo-specific working guidance, see the repository [AGENTS](https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/AGENTS.md).

## Docs map

| If you want to... | Start here |
| --- | --- |
| Set up a host app | [`doc/setup.md`](doc/setup.md) |
| Choose a helper or migrate from `collection_select` | [`doc/field_helpers.md`](doc/field_helpers.md), [`doc/select_migration.md`](doc/select_migration.md) |
| See the UI states quickly | [`doc/tom_select_visual_reference.html`](doc/tom_select_visual_reference.html), [`doc/native_field_visual_reference.html`](doc/native_field_visual_reference.html), [`doc/table_metadata_visual_reference.html`](doc/table_metadata_visual_reference.html) |
| Review public API and integration contracts | [`doc/public_api.md`](doc/public_api.md), [`doc/controller_helpers.md`](doc/controller_helpers.md), [`doc/token_suggestions.md`](doc/token_suggestions.md), [`doc/ransack_suggestions.md`](doc/ransack_suggestions.md), [`doc/table_adapters.md`](doc/table_adapters.md), [`doc/events.md`](doc/events.md), [`doc/configuration.md`](doc/configuration.md) |
| Work with optional table metadata | [`doc/table_adapters.md`](doc/table_adapters.md) |
| Run local checks or release verification | [`doc/development.md`](doc/development.md), [`doc/release.md`](doc/release.md), [`doc/sample_app_checklist.md`](doc/sample_app_checklist.md), [`doc/sample_app_results.md`](doc/sample_app_results.md), [`doc/final_release_checklist.md`](doc/final_release_checklist.md), [`doc/release_notes_0_1_1.md`](doc/release_notes_0_1_1.md), [`doc/release_notes_0_1_0.md`](doc/release_notes_0_1_0.md) |

## Choosing a helper

- Use `rfk_select` when you already have a server-rendered collection and want the submitted param shape to stay the same as an ordinary Rails select.
- Use `rfk_combobox` when options come from remote search, selected preload, or create-on-the-fly endpoints and the submitted value should still be a selected ID or value.
- Use `rfk_autocomplete` when the submitted value itself is free text and suggestions are only there to help typing.
- Use `rfk_token_search` when the input should accept structured token text such as `status:open assignee:matsuo keyword`; Rails Fields Kit can suggest tokens, but the host app still parses and executes the query.
- Use `rfk_multi_select` for ordinary multiple selected values, and `rfk_tags` when the UI should feel like tag entry or create-on-the-fly tag creation.
- Use `rfk_grouped_select` for `<optgroup>` collections and `rfk_enum_select` for Rails enum attributes.

For a side-by-side chooser and helper-specific examples, see [`doc/field_helpers.md`](doc/field_helpers.md).

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

If your app starts Stimulus from `app/frontend/entrypoints/application.js` or another Vite entrypoint, register the controller on that existing application instead:

```js
import { Application } from "@hotwired/stimulus"
import { TomSelectController } from "rails_fields_kit"

const application = Application.start()
application.register("rails-fields-kit--tom-select", TomSelectController)
```

If Stimulus is already started elsewhere, reuse that application instead of calling `Application.start()` a second time.

You can also import the controller file directly:

```js
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

For Vite or another JS bundler, the host app also needs to resolve the gem's `app/javascript` files. One option is to alias the documented import paths to the gem contents returned by `bundle show`:

```ts
import { execSync } from "node:child_process"
import { fileURLToPath } from "node:url"

function gemJavaScriptPath(entrypoint: string) {
  const gemRoot = execSync("bundle show rails_fields_kit", { encoding: "utf-8" }).trim()
  return fileURLToPath(new URL(`app/javascript/rails_fields_kit/${entrypoint}`, `file://${gemRoot}/`))
}

resolve: {
  alias: [
    { find: /^rails_fields_kit$/, replacement: gemJavaScriptPath("index.js") },
    { find: /^rails_fields_kit\/tom_select_controller$/, replacement: gemJavaScriptPath("tom_select_controller.js") },
  ],
}
```

Load Tom Select's CSS through your application's stylesheet pipeline or bundler:

```js
import "tom-select/dist/css/tom-select.css"
```

For importmap, keep Tom Select on the host app's normal pinning flow and pin the Rails Fields Kit entrypoints explicitly:

```ruby
# config/importmap.rb
pin "tom-select"
pin "rails_fields_kit", to: "rails_fields_kit/index.js"
pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
```

Then register the controller from the file where your app already boots Stimulus:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

`rails_fields_kit/index.js` re-exports the same controller as the direct `rails_fields_kit/tom_select_controller` entrypoint, so both documented import paths stay available after pinning. Rails Fields Kit still leaves the Tom Select pin source and any additional importmap conventions to the host app.

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

Use `RailsFieldsKit::TokenSuggestions.build` with `rfk_token_suggestions_with` to generate operator, field, predicate, value, and saved-search suggestions for the endpoint.

```ruby
# config/routes.rb
get "search_token_suggestions", to: "search_token_suggestions#index"

class SearchTokenSuggestionsController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_token_suggestions_with(
    action: :index,
    suggestions: ->(_query) {
      RailsFieldsKit::TokenSuggestions.build(
        fields: {
          status: { label: "Status", values: %w[open closed] },
          assignee: "Assignee"
        },
        saved_searches: [
          { token: "saved:mine", label: "Mine", description: "My saved search" }
        ]
      )
    },
    wrap: "options"
  )
end
```

This endpoint only returns suggestion option JSON. Submitted token text still belongs to the host application's parser, search object, or Ransack layer.

For a current Ransack-oriented path, keep the same `rfk_token_search` field and switch the suggestion builder:

```ruby
rfk_token_suggestions_with(
  action: :index,
  suggestions: ->(_query) {
    RailsFieldsKit::RansackSuggestions.build(
      fields: {
        status: :status_eq,
        assignee: :assignee_name_cont
      }
    )
  },
  wrap: "options"
)
```

This remains metadata-first. Rails Fields Kit helps the field advertise allowed tokens, but the host app still parses the submitted text and turns it into `params[:q]` or an equivalent search object input. Helper-level DSL examples such as `rfk_token_search ..., adapter: :ransack` stay in `ROADMAP.md` as future proposals, not current public API. See [`doc/controller_helpers.md`](doc/controller_helpers.md), [`doc/token_suggestions.md`](doc/token_suggestions.md), and [`doc/ransack_suggestions.md`](doc/ransack_suggestions.md) for the maintained reference.

### Table metadata helpers

If a table helper or host app already describes filters and cell editors as column metadata, Rails Fields Kit can render the current public field helpers from that metadata without taking over query execution or persistence.

```ruby
columns = [
  {
    key: :customer_id,
    filter_input: RailsFieldsKit::TableFilterInput.combobox(
      :customer_id,
      url: customers_path(format: :json),
      selected_url: selected_customers_path(format: :json),
      value_field: "id",
      label_field: "name"
    )
  },
  {
    key: :status,
    cell_editor: RailsFieldsKit::TableCellInput.enum_select(:status)
  }
]
```

```erb
<%= form_with model: @table_preferences do |f| %>
  <%= f.rfk_table_filters(columns) %>
  <%= f.rfk_table_cell_editors(columns) %>
<% end %>
```

This keeps the table gem or host app responsible for collecting column definitions, executing queries, and saving preferences. Rails Fields Kit only turns the documented metadata into FormBuilder helper calls. For the full protocol, renderer call specs, and Ransack-oriented metadata notes, see [`doc/table_adapters.md`](doc/table_adapters.md).

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