# Rails Fields Kit Setup

This guide is the maintained setup walkthrough for Rails Fields Kit.

Use the generated `doc/rails_fields_kit_setup.md` in your host app as a short checklist and place for app-specific notes. Host apps that keep setup notes elsewhere can run the install generator with `--skip-setup-notes`; that skips only the generated docs artifact while this guide remains the maintained source of truth. When the setup flow changes, update this file first and keep the generated note focused on linking back here.

Before reading the JavaScript examples, choose the route that matches the host app's existing toolchain:

- Bundler / Vite route: install Tom Select with the app's package manager, register the Rails Fields Kit Stimulus controller on the Stimulus application the app already boots, and add a bundler alias when the gem's `app/javascript` entrypoints are not resolved automatically.
- Importmap route: keep Tom Select on the host app's normal pinning flow, add the Rails Fields Kit pins with the opt-in generator or manually, and register the same Stimulus controller from the file where the app already boots Stimulus.

Both routes use the same controller identifier and helper markup. Rails Fields Kit does not choose the JavaScript policy for the host app; it only documents the package entrypoints and, for importmap users, provides an opt-in generator path for its own pins. If Stimulus is already started elsewhere, reuse that application instead of calling `Application.start()` again.

## 1. Add the gem

```ruby
gem "rails_fields_kit"
```

Then run:

```bash
bundle install
rails generate rails_fields_kit:install
```

By default, the generator creates:

- `config/initializers/rails_fields_kit.rb`
- `doc/rails_fields_kit_setup.md`

Treat `doc/rails_fields_kit_setup.md` as a host-app checklist. This `doc/setup.md` file is the detailed setup reference and source of truth for examples.

If the host app does not keep generated docs artifacts in `doc/`, skip only the setup notes:

```bash
rails generate rails_fields_kit:install --skip-setup-notes
```

That path still creates `config/initializers/rails_fields_kit.rb`; use this guide for the maintained setup examples.

After installation, run the read-only setup doctor when you want a quick visibility check:

```bash
rails rails_fields_kit:doctor
```

The doctor reports whether the initializer exists and, when `config/importmap.rb` exists, whether the Rails Fields Kit importmap pins are present and point at the documented entrypoints. It also reports the generated `doc/rails_fields_kit_setup.md` note as `[OK]` when present or `[MANUAL]` when absent. The absent-note result is not a hard failure because `--skip-setup-notes` and app-specific setup notes are valid routes; the doctor does not create the note, inspect its contents, or judge its quality. The output starts with a status legend: fix `[MISSING]` lines first for the detected setup route, then review `[MANUAL]` lines as host-app JavaScript toolchain checks rather than automatic failures. Missing pins, unexpected targets, and pins without explicit targets are reported as read-only diagnostics; the doctor does not rewrite `config/importmap.rb`, choose a Tom Select pin source, validate bundler aliases, or decide the host app's non-importmap policy. The doctor can also report a representative Stimulus registration signal when it finds `rails-fields-kit--tom-select` or `TomSelectController` in a candidate entrypoint. Treat `[OK] Stimulus registration` as advisory source visibility only; it does not prove the app's final Stimulus boot policy. When that signal is absent, `[MANUAL] Stimulus registration` is host-app follow-up, not a hard failure. Tom Select package install, CSS import, bundler aliases, and any remaining Stimulus boot-file confirmation stay host-app responsibilities because Rails Fields Kit cannot safely infer every JavaScript toolchain.

When release checks, host-app CI, or generator smoke tests need structured setup visibility, use the Ruby API route in [`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md). That guide documents `RailsFieldsKit::SetupDoctor.new.run(io:, format: :json)` as the machine-readable path without changing the text CLI output or promising a separate CLI `--json` contract.

## 2. Install Tom Select

Rails Fields Kit provides Rails helpers and a Stimulus controller, but it does not install Tom Select or choose a JavaScript bundling strategy.

Install Tom Select with the JavaScript toolchain already used by the application:

```bash
yarn add tom-select
# or
npm install tom-select
# or
pnpm add tom-select
```

Rails Fields Kit intentionally does not publish or enforce a Tom Select package version range, pin source, CDN choice, or plugin asset policy. Keep those decisions with the host application's package manager or importmap conventions, and record any app-specific version or plugin choices in the host app's own setup notes. The examples in this guide show the package name and Rails Fields Kit wiring only; they are not a replacement for the host app's normal JavaScript dependency review.

## 3. Register the Stimulus controller

For the default `stimulus-rails` layout, register the controller on the shared application from `controllers/application`:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

For Vite or `app/frontend/entrypoints/application.js`, register the controller on the application that the host app already boots from that entrypoint:

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
    { find: /^rails_fields_kit\/native_field_accessibility_contract$/, replacement: gemJavaScriptPath("native_field_accessibility_contract.js") },
    { find: /^rails_fields_kit\/native_field_constraint_contract$/, replacement: gemJavaScriptPath("native_field_constraint_contract.js") },
    { find: /^rails_fields_kit\/read_rendered_error_surface$/, replacement: gemJavaScriptPath("read_rendered_error_surface.js") },
    { find: /^rails_fields_kit\/tom_select_controller$/, replacement: gemJavaScriptPath("tom_select_controller.js") },
    { find: /^rails_fields_kit\/tom_select_plugin_contract$/, replacement: gemJavaScriptPath("tom_select_plugin_contract.js") },
    { find: /^rails_fields_kit\/tom_select_text_override_contract$/, replacement: gemJavaScriptPath("tom_select_text_override_contract.js") },
  ],
}
```

Keep the package-root alias for normal controller registration and rendered-field contract helper imports. Add the direct controller or helper subpath aliases only when the host app intentionally imports those files directly; this mirrors the setup doctor and importmap source of truth without making this setup guide a full helper inventory.

For importmap, keep Tom Select on the host app's normal pinning flow and pin the Rails Fields Kit entrypoints explicitly. When `config/importmap.rb` already exists, the install generator can append the Rails Fields Kit pins without taking over Tom Select or other importmap policy:

```bash
rails generate rails_fields_kit:install --importmap
```

The opt-in generator path adds the Rails Fields Kit pins below when they are not already present. It leaves an existing named pin unchanged when its target is unexpected or omitted, warns with the documented target, and asks you to update that target manually before running the setup doctor again. If the app does not have `config/importmap.rb`, add the pins manually instead:

```ruby
# config/importmap.rb
pin "tom-select"
pin "rails_fields_kit", to: "rails_fields_kit/index.js"
pin "rails_fields_kit/native_field_accessibility_contract", to: "rails_fields_kit/native_field_accessibility_contract.js"
pin "rails_fields_kit/native_field_constraint_contract", to: "rails_fields_kit/native_field_constraint_contract.js"
pin "rails_fields_kit/read_rendered_error_surface", to: "rails_fields_kit/read_rendered_error_surface.js"
pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
pin "rails_fields_kit/tom_select_plugin_contract", to: "rails_fields_kit/tom_select_plugin_contract.js"
pin "rails_fields_kit/tom_select_text_override_contract", to: "rails_fields_kit/tom_select_text_override_contract.js"
```

Then register the controller from the file where the host app already boots Stimulus:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

The package-root pin remains the normal route for controller registration and rendered-field contract helpers. The direct helper subpath pins mirror the generator and setup doctor source of truth for host apps that intentionally import those helper files directly; they do not change helper behavior or turn this guide into a helper inventory.

`rails_fields_kit/index.js` re-exports the same controller as `rails_fields_kit/tom_select_controller`, so both documented import paths stay available after pinning. Rails Fields Kit still leaves the Tom Select pin source, package version, plugin pins, and any additional importmap conventions to the host app.

The package root also exposes read-only rendered-field contract helpers, including `nativeFieldAccessibilityContract(element)` for native wrapper accessibility wiring, `nativeFieldConstraintContract(element)` for rendered native constraint attributes, `readRenderedErrorSurface(element)` for opt-in request-failure placeholders, and `tomSelectPluginContract(element)` for effective plugin state. Import those helpers from `rails_fields_kit` only when host-app scripts need to inspect already-rendered labels, hints, errors, wrapper elements, native attributes such as `maxlength`, `minlength`, `pattern`, `autocomplete`, and `inputmode`, request-failure placeholder wiring, or plugin lists; controller registration, browser validation behavior or messages, masking, formatting, normalization, focus management, visible feedback, plugin asset loading, and clear affordance styling remain separate host-app responsibilities. Use [`public_api.md#javascript-exports`](public_api.md#javascript-exports) as the current source of truth for the helper list and return shape.

The direct helper subpath examples in this setup guide are intentionally limited to the helper files that `package.json` exposes as direct entrypoints today. Do not extend the alias or importmap examples by copying every package-root helper name from the public API table; prefer package-root imports for the broader rendered-field contract helper family unless a host app deliberately pins one of the documented direct helper files.

### Troubleshoot unresolved imports

When a build error, browser console error, or importmap resolution error says a Rails Fields Kit import cannot be resolved, first identify which documented path is failing instead of changing every setup step at once:

- If `import { TomSelectController } from "rails_fields_kit"` or a package-root contract helper import fails, check the bundler alias or importmap pin for `rails_fields_kit` and confirm it points at `rails_fields_kit/index.js`.
- If `import TomSelectController from "rails_fields_kit/tom_select_controller"` fails, check the separate alias or pin for `rails_fields_kit/tom_select_controller` and confirm it points at `rails_fields_kit/tom_select_controller.js`.
- If a direct helper subpath import such as `rails_fields_kit/native_field_accessibility_contract`, `rails_fields_kit/native_field_constraint_contract`, `rails_fields_kit/read_rendered_error_surface`, `rails_fields_kit/tom_select_plugin_contract`, or `rails_fields_kit/tom_select_text_override_contract` fails, check the matching alias or importmap pin and confirm it points at the same documented subpath file.
- If both imports resolve but the field is not enhanced, check that the host app registered `rails-fields-kit--tom-select` on the Stimulus application it actually boots, and avoid starting a second Stimulus application just for Rails Fields Kit.
- If the controller connects but Tom Select is missing or unstyled, check the host app's `tom-select` package or pin and CSS import separately. Changing the Rails Fields Kit import path does not install Tom Select, load Tom Select CSS, or choose plugin assets.

The setup doctor can report importmap pin visibility, but bundler aliases, Tom Select package installation, CSS imports, and Stimulus boot-file choices remain host-app checks. Keep app-specific Vite, importmap, or package-manager notes in the generated host-app setup note rather than replacing these documented public entrypoints with private asset paths.

## 4. Load Tom Select CSS

Use the stylesheet pipeline or bundler already used by the application.

```js
import "tom-select/dist/css/tom-select.css"
```

If the host app enables Tom Select plugins or theme packages that need additional styles or assets, load those through the same host-app pipeline. Rails Fields Kit does not choose plugin asset policy or bundle plugin-specific CSS for the app.

Rails Fields Kit only edits importmap setup when `--importmap` is passed and `config/importmap.rb` exists. Other JavaScript setup remains a host-app responsibility.

## 5. Add a searchable combobox

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
    option_description_field: "email",
    option_badge_field: "status",
    placeholder: "Search or create a customer" %>
<% end %>
```

For a static collection that already works with `collection_select`, migrating to `rfk_select` is usually a form-helper-only change. Keep the same attribute name and normal Rails select options such as `include_blank:` or `prompt:` and let the registered Stimulus controller enhance the rendered select in place.

```erb
<%= f.rfk_select :company_id,
  collection: @companies,
  collection_value_method: :id,
  collection_label_method: :name,
  include_blank: "Select a company" %>
```

That migration keeps the ordinary submitted param and selected-value redisplay behavior, so host-app controller code and extra Turbo/Vite reinitializers usually do not need to change just for this helper swap.

If the host app wants a stable placeholder for inline error UI, opt in with `error_surface: true`:

```erb
<%= f.rfk_combobox :customer_id,
  url: customers_path(format: :json),
  selected_url: selected_customers_path(format: :json),
  error_surface: true,
  html: {
    data: {
      action: "rails-fields-kit--tom-select:load-error->customers#error rails-fields-kit--tom-select:selected-load-error->customers#error rails-fields-kit--tom-select:create-error->customers#error"
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
- `selected_url:` points to the selected-option lookup endpoint, commonly an `rfk_find_with` action documented in [`controller_helpers.md`](controller_helpers.md).
- `selected-load` tells the host app that the label restore completed and exposes the fetched option payloads.
- `selected-load-error` gives the host app a dedicated fallback hook when label restore fails. If `error_surface: true` is enabled, the failure event also exposes `event.detail.surface`.

Keep the visible fallback copy and any retry behavior in the host app. Rails Fields Kit only provides the selected preload request, event hooks, and the opt-in placeholder boundary. See [`events.md`](events.md) for the event payloads.

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

Use `create` when the host app needs a success hook before ordinary selection events continue, and use `create-error` when the host app needs field-adjacent fallback copy or retry UI for failed inline creation. If `error_surface: true` is enabled, the failure event exposes `event.detail.surface`; keep the actual message and retry behavior in the host app. See [`events.md`](events.md) for the event payloads and [`field_helpers.md`](field_helpers.md) for the broader helper example inventory.

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

Remote fields can use FormBuilder `min_length:` as a browser-side loading hint. Use `rfk_search_with minimum_query_length:` when the endpoint itself should return empty options for blank or too-short direct requests, custom Tom Select configs, or other callers that bypass the bundled browser hint.

Keep the detailed option reference in [`controller_helpers.md`](controller_helpers.md). This setup walkthrough only needs the minimal reminder that custom `action:` names and endpoint-side query minimums are part of the current public surface.

## 7. Listen to events when needed

See [`events.md`](events.md) for the Stimulus events emitted by the Tom Select controller.

Remote search and selected preload have dedicated success and failure events. Create-on-the-fly success also has a dedicated `rails-fields-kit--tom-select:create` hook before the normal `item-add` / `change` interaction events continue, while `create-error` remains the dedicated failure hook. When `error_surface: true` is enabled, request-failure events also expose `event.detail.surface` so the host app can render inline error UI without replacing the controller.

Visible success or error UI remains a host-app responsibility.

Before release, verify the intended placeholder, loading, no-results, and create-error copy in a sample app and record it in [`sample_app_checklist.md`](sample_app_checklist.md) and [`sample_app_results.md`](sample_app_results.md).
