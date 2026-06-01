# Rails Fields Kit

Rails Fields Kit is a Rails form helper kit for fields that are still awkward with native HTML inputs alone: searchable selects, editable comboboxes, tag inputs, autocomplete, token search inputs, create-on-the-fly fields, native wrapper helpers, and table-oriented metadata helpers.

Tom Select-powered helpers remain the center of the gem for searchable selections and editable combobox workflows, while native wrappers and table metadata helpers round out the current public surface without taking over host-app search, authorization, or table persistence.

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

By default, the install generator creates:

- `config/initializers/rails_fields_kit.rb`
- `doc/rails_fields_kit_setup.md`

Use the generated `doc/rails_fields_kit_setup.md` in your host app as a short checklist and place for app-specific notes. If your app keeps setup notes elsewhere, run `rails generate rails_fields_kit:install --skip-setup-notes` to skip only that generated docs artifact while still creating the initializer. The maintained setup walkthrough and source of truth for setup examples stays in this repository at [`doc/setup.md`](doc/setup.md).

Rails Fields Kit ships Rails helpers, a Rails engine, a Stimulus controller, and controller-side helpers. It does not install Tom Select or choose a JavaScript bundling strategy for your app.

For the current direction and integration priorities, see the repository roadmap: <https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/ROADMAP.md>.
For repo positioning and responsibility boundaries, see the repository [Product profile](https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/Product%20Profile.md).
For repo-specific working guidance, see the repository [AGENTS](https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/AGENTS.md).

## Docs map

| If you want to... | Start here |
| --- | --- |
| Set up a host app | [`doc/setup.md`](doc/setup.md) |
| Check supported Ruby / Rails and repository JavaScript boundaries | [`doc/support_boundary.md`](doc/support_boundary.md) |
| Choose a helper or migrate from `collection_select` | [`doc/field_helpers.md`](doc/field_helpers.md), [`doc/select_migration.md`](doc/select_migration.md) |
| See or compare rendered UI states quickly | [`doc/visual_references.md`](doc/visual_references.md) for the visual reference family, including Tom Select, text override copy, native helper, table metadata, and saved-search token states |
| Review stable public API and package-root JavaScript exports | [`doc/public_api.md`](doc/public_api.md) |
| Build remote search, selected preload, create, or token suggestion endpoints | [`doc/controller_helpers.md`](doc/controller_helpers.md), [`doc/token_suggestions.md`](doc/token_suggestions.md), [`doc/ransack_suggestions.md`](doc/ransack_suggestions.md) |
| Handle Stimulus events or request-failure surfaces | [`doc/events.md`](doc/events.md) |
| Configure initializer defaults and field-level override precedence | [`doc/configuration.md`](doc/configuration.md) |
| Work with optional table metadata | [`doc/table_adapters.md`](doc/table_adapters.md) |
| Run local checks or release verification | [`doc/development.md`](doc/development.md), [`doc/release.md`](doc/release.md), [`doc/sample_app_checklist.md`](doc/sample_app_checklist.md), [`doc/sample_app_results.md`](doc/sample_app_results.md), [`doc/final_release_checklist.md`](doc/final_release_checklist.md), [`doc/selected_preload_release_gate.md`](doc/selected_preload_release_gate.md), [`doc/release_notes_0_1_1.md`](doc/release_notes_0_1_1.md), [`doc/release_notes_0_1_0.md`](doc/release_notes_0_1_0.md) |

## Choosing a helper

- Use `rfk_select` when you already have a server-rendered collection and want the submitted param shape to stay the same as an ordinary Rails select.
- Use `rfk_combobox` when options come from remote search, selected preload, or create-on-the-fly endpoints and the submitted value should still be a selected ID or value.
- Use `rfk_autocomplete` when the submitted value itself is free text and suggestions are only there to help typing.
- Use `rfk_token_search` when the input should accept structured token text such as `status:open assignee:matsuo keyword`; Rails Fields Kit can suggest tokens, but the host app still parses and executes the query.
- Use `rfk_multi_select` for ordinary multiple selected values, and `rfk_tags` when the UI should feel like tag entry or create-on-the-fly tag creation.
- Use `rfk_grouped_select` for `<optgroup>` collections and `rfk_enum_select` for Rails enum attributes.
- Use the native wrapper helpers such as `rfk_text_field`, `rfk_money_field`, `rfk_phone_field`, and `rfk_search_field` when a native browser input is enough and you only want consistent labels, hints, validation errors, prefixes, suffixes, and accessibility wiring.

For a side-by-side chooser and helper-specific examples, see [`doc/field_helpers.md`](doc/field_helpers.md). For rendered native wrapper states, see [`doc/native_field_visual_reference.html`](doc/native_field_visual_reference.html).

## JavaScript setup

Use [`doc/setup.md`](doc/setup.md) as the maintained setup walkthrough. This README keeps the two common JavaScript routes separate so host apps can follow the route that matches their existing toolchain.

### Bundler or Vite route

Install Tom Select with the JavaScript package manager your app already uses:

```bash
yarn add tom-select
# or
npm install tom-select
# or
pnpm add tom-select
```

Register the Rails Fields Kit Stimulus controller on the Stimulus application your app already boots:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

If your app starts Stimulus from `app/frontend/entrypoints/application.js` or another Vite entrypoint, register the controller on that same application instead:

```js
import { Application } from "@hotwired/stimulus"
import { TomSelectController } from "rails_fields_kit"

const application = Application.start()
application.register("rails-fields-kit--tom-select", TomSelectController)
```

If the host app already started Stimulus elsewhere, reuse that application instead of calling `Application.start()` again.

Rails Fields Kit relies on Stimulus `connect()` for initialization and reconnect. In Turbo-enabled apps, replacing or revisiting a server-rendered form should not require a separate host-app `turbo:load` reinitializer for normal `rfk_*` fields.

Direct import is also supported:

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

For importmap, keep Tom Select on the host app's normal pinning flow and pin the Rails Fields Kit entrypoints explicitly. When `config/importmap.rb` already exists, the install generator can append the Rails Fields Kit pins without taking over Tom Select or other importmap policy:

```bash
rails generate rails_fields_kit:install --importmap
```

The opt-in generator path adds the two Rails Fields Kit pins below when they are not already present. If the app does not have `config/importmap.rb`, add the pins manually instead:

```ruby
# config/importmap.rb
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

The package root also exposes read-only rendered-field contract helpers, including `nativeFieldAccessibilityContract(element)` for native wrapper accessibility wiring. Import those helpers from `rails_fields_kit` only when host-app scripts need to inspect already-rendered labels, hints, errors, and wrapper elements; controller registration, validation messages, focus management, and visible feedback remain separate host-app responsibilities. Use [`public_api.md#javascript-exports`](public_api.md#javascript-exports) as the current source of truth for the helper list and return shape.

## 4. Load Tom Select CSS

Use the stylesheet pipeline or bundler already used by the application.

```js
import "tom-select/dist/css/tom-select.css"
```

Rails Fields Kit only edits importmap setup when `--importmap` is passed and `config/importmap.rb` exists. Other JavaScript setup remains a host-app responsibility.

## 5. Use a helper

```erb
<%= form_with model: @project do |f| %>
  <%= f.rfk_select :category_id,
    collection: Category.order(:name),
    collection_value_method: :id,
    collection_label_method: :name %>
<% end %>
```

For a placeholder, set `prompt:`. For initial selection, pass `selected:`.

To customize visible helper copy without changing every call site, use initializer defaults:

```ruby
# config/initializers/rails_fields_kit.rb
RailsFieldsKit.configure do |config|
  config.default_texts.no_results = "No matching customers"
  config.default_texts.loading = "Loading customers..."
  config.default_texts.create = "Create %{input}"
  config.default_texts.create_loading = "Creating %{input}..."
  config.default_texts.create_error = "Could not create %{input}"
end
```

To override one field, pass `texts:`:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  create_url: customers_path,
  texts: {
    no_results: "No customers match this search",
    create_error: "Could not create this customer"
  } %>
```

For a representative request-failure lane, enable `error_surface: true` and subscribe to the documented failure hooks:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customer_path(@order, format: :json),
  error_surface: true,
  html: {
    data: {
      action: "rails-fields-kit--tom-select:load-error->customers#loadFailed rails-fields-kit--tom-select:selected-load-error->customers#selectedLoadFailed rails-fields-kit--tom-select:create-error->customers#createFailed"
    }
  } %>
```

The helper renders an empty placeholder next to the field, and request-failure events include that element as `event.detail.surface`. The gem still does not choose the message copy or retry behavior.

For a representative selected preload lane, keep `selected:` and `selected_url:` on the same field and subscribe to the selected preload hooks explicitly:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  selected: @order.customer_id,
  error_surface: true,
  html: {
    data: {
      action: "rails-fields-kit--tom-select:selected-load->customers#selectedLoaded rails-fields-kit--tom-select:selected-load-error->customers#selectedLoadFailed"
    }
  } %>
```

Use this lane when an edit form starts from a saved ID and the host app wants the displayed label restored before the user begins searching.

- `selected:` keeps the existing saved value on the field while Tom Select reconnects.
- `selected_url:` points to the selected-option lookup endpoint, commonly an `rfk_find_with` action documented in [`controller_helpers.md`](doc/controller_helpers.md).
- `selected-load` tells the host app that the label restore completed and exposes the fetched option payloads.
- `selected-load-error` gives the host app a dedicated fallback hook when label restore fails. If `error_surface: true` is enabled, the failure event also exposes `event.detail.surface`.

Keep the visible fallback copy and any retry behavior in the host app. Rails Fields Kit only provides the selected preload request, event hooks, and the opt-in placeholder boundary. See [`events.md`](doc/events.md) for the event payloads.

For a representative create-on-the-fly failure lane, keep `create_url:` and `error_surface: true` on the same field and subscribe to the dedicated create hooks explicitly:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  create_url: customers_path,
  error_surface: true,
  html: {
    data: {
      action: "rails-fields-kit--tom-select:create->customers#created rails-fields-kit--tom-select:create-error->customers#createFailed"
    }
  } %>
```

Use `create` when the host app needs a success hook before ordinary selection events continue, and use `create-error` when the host app needs field-adjacent fallback copy or retry UI for failed inline creation. If `error_surface: true` is enabled, the failure event exposes `event.detail.surface`; keep the actual message and retry behavior in the host app. See [`events.md`](doc/events.md) for the event payloads and [`field_helpers.md`](doc/field_helpers.md) for the broader helper example inventory.

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

The default `index` / `show` / `create` action names keep the shortest setup path. When the host app already uses route names such as `selected` or `search_tokens`, map the helpers to those action names directly instead of adding adapter actions around them.

```ruby
resources :customers, only: [] do
  collection do
    get :search
    get :selected
    post :create_customer
  end
end

class CustomersController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_search_with action: :search, model: Customer, value: :id, label: :name, search: [:name, :email]
  rfk_find_with action: :selected, model: Customer, value: :id, label: :name
  rfk_create_with action: :create_customer, model: Customer, value: :id, label: :name, create_attribute: :name
end
```

Keep the detailed option reference in [`controller_helpers.md`](doc/controller_helpers.md). This setup walkthrough only needs the minimal reminder that custom `action:` names are part of the current public surface.

## 7. Listen to events when needed

See [`events.md`](doc/events.md) for the Stimulus events emitted by the Tom Select controller.

Remote search and selected preload have dedicated success and failure events. Create-on-the-fly success also has a dedicated `rails-fields-kit--tom-select:create` hook before the normal `item-add` / `change` interaction events continue, while `create-error` remains the dedicated failure hook. When `error_surface: true` is enabled, request-failure events also expose `event.detail.surface` so the host app can render inline error UI without replacing the controller.

Visible success or error UI remains a host-app responsibility.

Before release, verify the intended placeholder, loading, no-results, and create-error copy in a sample app and record it in [`sample_app_checklist.md`](doc/sample_app_checklist.md) and [`sample_app_results.md`](doc/sample_app_results.md).

### Multiple selects and tags

Use `rfk_multi_select` for ordinary multiple selects and `rfk_tags` for tag-style inputs. Both render array-style parameter names and Rails' hidden blank input by default, so clearing all selected values still submits an empty value.
