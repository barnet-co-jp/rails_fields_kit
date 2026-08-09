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

After generator setup, `rails rails_fields_kit:doctor` can inspect the host app's setup visibility without changing files. It reports initializer and importmap pin presence, reports the generated setup note as `[OK]` when present or `[MANUAL]` when absent, can surface a representative Stimulus registration advisory signal, and leaves Tom Select package install, final Stimulus boot policy, CSS import, and bundler alias confirmation as manual host-app checks. An absent generated note is not a hard failure because `--skip-setup-notes` and app-specific notes are valid routes; the doctor does not create the note or inspect its contents. See [`doc/setup.md`](doc/setup.md) for the maintained doctor boundary.

Rails Fields Kit ships Rails helpers, a Rails engine, a Stimulus controller, and controller-side helpers. It does not install Tom Select or choose a JavaScript bundling strategy for your app.

For the current direction and integration priorities, see the repository roadmap: <https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/ROADMAP.md>.
For repo positioning and responsibility boundaries, see the repository [Product profile](https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/Product%20Profile.md).
For repo-specific working guidance, see the repository [AGENTS](https://github.com/matsuo-haruhito/rails_fields_kit/blob/main/AGENTS.md).

## Docs map

Use this map as a first reader route, not a full documentation inventory. Start with the first column when you are introducing Rails Fields Kit to a host app, then follow the second column only when that topic needs the deeper source-of-truth docs.

| If you want to... | Start here | Then use |
| --- | --- | --- |
| Set up a host app | [`doc/setup.md`](doc/setup.md) | [`doc/support_boundary.md`](doc/support_boundary.md) for supported Ruby / Rails and repository JavaScript boundaries |
| Check setup visibility after install | [`doc/setup.md`](doc/setup.md) for `rails rails_fields_kit:doctor` and its read-only/manual-check boundary | [`doc/setup_doctor.md`](doc/setup_doctor.md) for the read-only report surface, [`doc/setup_doctor_output_review.md`](doc/setup_doctor_output_review.md) for CLI diagnostic evidence review, and [`doc/setup_doctor_machine_readable.md`](doc/setup_doctor_machine_readable.md) for structured JSON payloads |
| Render the first field | [First field quickstart](#first-field-quickstart) | [`doc/field_helpers.md`](doc/field_helpers.md) when choosing the next helper |
| Choose a helper or migrate from `collection_select` | [`doc/field_helpers.md`](doc/field_helpers.md) | Use the quick chooser and focused helper links in [`doc/field_helpers.md`](doc/field_helpers.md), then use [`doc/select_migration.md`](doc/select_migration.md) for the endpoint-free `collection_select` to `rfk_select` migration route; keep proposal-only boundaries in `doc/*_boundary.md` until they become current public API |
| See or compare rendered UI states quickly | [`doc/visual_references.md`](doc/visual_references.md) for the visual reference family, including Tom Select, request-failure and host-feedback lifecycle, text override, native helper, table metadata, and saved-search token states | [`doc/visual_reference_index.html`](doc/visual_reference_index.html) when choosing a visual lane by artifact, family, or reviewer task; use [`doc/visual_reference_browser_evidence.md`](doc/visual_reference_browser_evidence.md) only when a static visual reference PR needs manual desktop/narrow browser-capable evidence beyond CI or source review |
| Review stable public API and package-root JavaScript exports | [`doc/public_api.md`](doc/public_api.md) | [`doc/package_root_helper_release_evidence.md`](doc/package_root_helper_release_evidence.md) when the review is about release or sample-app evidence for a helper lane |
| Build remote search, selected preload, create, or token suggestion endpoints | [`doc/controller_helpers.md`](doc/controller_helpers.md) | [`doc/token_suggestions.md`](doc/token_suggestions.md) and [`doc/ransack_suggestions.md`](doc/ransack_suggestions.md) for token suggestion payloads |
| Scope remote-search query params from other fields | [`doc/dependent_query_params.md`](doc/dependent_query_params.md) | Use `depends_on:` and optional `clear_on_dependency_change:`; endpoint meaning, authorization, and business rules remain host-app responsibilities. |
| Understand shared token, Ransack, and table metadata boundaries | [`doc/shared_metadata_navigation.md`](doc/shared_metadata_navigation.md) | [`doc/table_adapters.md`](doc/table_adapters.md) for the metadata protocol, [`doc/table_direct_helper_boundary.md`](doc/table_direct_helper_boundary.md) for direct FormBuilder safe-join output and lower-level render/call-spec lanes, and [`doc/table_group_html.md`](doc/table_group_html.md) when optional group-level wrapper attributes are in scope |
| Handle Stimulus events, request-failure surfaces, or Turbo reconnect | [`doc/events.md`](doc/events.md) | [`doc/tom_select_turbo_lifecycle.md`](doc/tom_select_turbo_lifecycle.md) for reconnect lifecycle details |
| Configure initializer defaults, styling hooks, and field-level override precedence | [`doc/configuration.md`](doc/configuration.md) | [`doc/configuration_profiles.md`](doc/configuration_profiles.md) for docs-only copyable profile examples, [`doc/default_allow_clear.md`](doc/default_allow_clear.md) for the app-wide clear-button default, and [`doc/styling_boundary.md`](doc/styling_boundary.md) for wrapper classes and host-app CSS ownership |
| Run local checks | [`doc/development.md`](doc/development.md) | GitHub Actions confirmation in the same guide before treating an open PR as review- or release-ready |
| Prepare or verify a release | [`doc/release.md`](doc/release.md) | Use the release guide's pre-release checklist and linked evidence lanes; use [`doc/sample_app_results_route_guide.md`](doc/sample_app_results_route_guide.md) only when choosing whether narrow PR evidence belongs in the full sample-app evidence log or a scoped PR comment. Keep lane-specific sample-app, visual, package-root, and focused autosize evidence details in [`doc/release.md`](doc/release.md), including [`doc/textarea_autosize_release_evidence.md`](doc/textarea_autosize_release_evidence.md), instead of expanding this README map |
| Review release-facing notes | [`CHANGELOG.md`](CHANGELOG.md) for the exhaustive release-history source of truth | [`doc/release_notes_0_1_1.md`](doc/release_notes_0_1_1.md) for the current reviewer-facing / GitHub-release-facing draft summary, and [`doc/release_notes_0_1_0.md`](doc/release_notes_0_1_0.md) for the previous release summary |

## First field quickstart

After the gem install, generator, Tom Select package install, Stimulus controller registration, and Tom Select CSS import are in place, try the first field with a server-rendered collection before adding remote endpoints:

```erb
<%= form_with model: @order do |f| %>
  <%= f.rfk_select :customer_id,
    collection: @customers,
    collection_value_method: :id,
    collection_label_method: :name,
    include_blank: "Select a customer" %>
<% end %>
```

This keeps the submitted params the same shape as an ordinary Rails select while confirming that the Rails helper, Stimulus controller, and Tom Select assets are wired together. Move to `rfk_combobox` only when the host app needs remote search, selected preload, or create-on-the-fly behavior; the host app still owns those endpoints, authorization, scoping, and any result execution. Use [`doc/setup.md`](doc/setup.md) for the full setup walkthrough and [`doc/field_helpers.md`](doc/field_helpers.md) when choosing the next helper.

## Choosing a helper

- Use `rfk_select` when you already have a server-rendered collection and want the submitted param shape to stay the same as an ordinary Rails select.
- Use `rfk_combobox` when options come from remote search, selected preload, or create-on-the-fly endpoints and the submitted value should still be a selected ID or value.
- Use `rfk_autocomplete` when the submitted value itself is free text and suggestions are only there to help typing.
- Use `rfk_lookup` when free text and an optional selected master ID must be submitted separately.
- Use `rfk_token_search` when the input should accept structured token text such as `status:open assignee:matsuo keyword`; Rails Fields Kit can suggest tokens, but the host app still parses and executes the query.
- Use `rfk_multi_select` for ordinary multiple selected values, and `rfk_tags` when the UI should feel like tag entry or create-on-the-fly tag creation.
- Use `rfk_grouped_select` for `<optgroup>` collections and `rfk_enum_select` for Rails enum attributes.
- Use `rfk_table_filters` / `rfk_table_cell_editors` when a table integration already owns column metadata and only needs Rails Fields Kit to render documented filter or editor helpers; keep query execution, persistence, authorization, and renderer policy in the host app or table integration, and use [`doc/table_adapters.md`](doc/table_adapters.md) for the protocol.
- Use the native wrapper helpers when a native browser input is enough and you only want consistent labels, hints, validation errors, prefixes, suffixes, and accessibility wiring. Representative starting points include `rfk_text_field`, `rfk_text_area`, `rfk_money_field`, `rfk_phone_field`, and `rfk_search_field`; keep the exact helper inventory in [`doc/public_api.md`](doc/public_api.md#formbuilder-helpers), then choose the focused guide by job:
  - text and textarea wrappers: start with [`doc/field_helpers.md`](doc/field_helpers.md) and [`doc/textarea_autosize.md`](doc/textarea_autosize.md)
  - password, checkbox, file, or range controls, plus radio controls: use [`doc/password_field.md`](doc/password_field.md), [`doc/check_box.md`](doc/check_box.md), [`doc/radio_button.md`](doc/radio_button.md), [`doc/file_field.md`](doc/file_field.md), or [`doc/range_field.md`](doc/range_field.md)
  - numeric, contact, phone, URL, email, or native search inputs: use [`doc/native_numeric_fields.md`](doc/native_numeric_fields.md) or [`doc/native_contact_fields.md`](doc/native_contact_fields.md)
  - date, time, datetime-local, or color controls: use [`doc/native_date_time_color_fields.md`](doc/native_date_time_color_fields.md)

For `rfk_text_area` autosize, start from [`doc/textarea_autosize.md`](doc/textarea_autosize.md). Autosize measurement, Turbo reconnect sizing, production CSS, and manual resize policy remain host-app-owned enhancements for the current 0.1.x surface.

For collection checkbox or radio groups, keep using ordinary Rails collection helpers or host-app markup today. Rails Fields Kit does not currently provide collection group helpers; use [`doc/collection_group_helpers.md`](doc/collection_group_helpers.md) for the current non-API boundary instead of inferring collection groups from single checkbox/radio wrapper work.

For masked input, title-to-slug, or native datalist directions, Rails Fields Kit does not currently provide `rfk_masked_field`, `rfk_slug_field`, or `rfk_datalist_field`. Use [`doc/masked_input_boundary.md`](doc/masked_input_boundary.md), [`doc/slug_helper_boundary.md`](doc/slug_helper_boundary.md), or [`doc/datalist_boundary.md`](doc/datalist_boundary.md) only when comparing the current native wrapper and Tom Select-backed lanes with those future proposals.

For inline textarea mentions such as `@user` or `#tag`, Rails Fields Kit does not currently provide a public mention helper. Use [`doc/mention_field_boundary.md`](doc/mention_field_boundary.md) when comparing the current `rfk_text_area`, autocomplete, token search, and tag lanes with that future proposal; do not treat `rfk_mention_field` as part of the current public API.

For a side-by-side chooser and helper-specific examples, see [`doc/field_helpers.md`](doc/field_helpers.md). For rendered native wrapper states, see [`doc/native_field_visual_reference.html`](doc/native_field_visual_reference.html).

## JavaScript setup

Use [`doc/setup.md`](doc/setup.md) as the maintained setup walkthrough. This README keeps the two common JavaScript routes separate so host apps can follow the route that matches their existing toolchain.

| If the host app uses... | Start with | Keep details in |
| --- | --- | --- |
| Bundler, Vite, or another JavaScript bundler | Install Tom Select with the app's package manager, register `TomSelectController` from the package root, and add aliases only when the gem entrypoints are not resolved automatically. | [`doc/setup.md`](doc/setup.md) for setup examples and [`doc/public_api.md#javascript-exports`](doc/public_api.md#javascript-exports) for the current export list. |
| Importmap | Let the opt-in generator add Rails Fields Kit pins when possible, or add the documented pins manually, then register the same package-root controller. | [`doc/setup.md`](doc/setup.md) for pin troubleshooting and setup doctor output. |
| Direct controller or helper subpath imports | Use them only when the host app intentionally pins or aliases a specific file. | [`doc/public_api.md#javascript-exports`](doc/public_api.md#javascript-exports) for helper names, return shapes, and responsibility boundaries. |

This README is a route map. Do not treat the representative helper-family table below as the full package-root export inventory; use `doc/public_api.md` when you need exact names, return shapes, or direct helper subpath policy.

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

If your app starts Stimulus from `app/frontend/entrypoints/application.js` or another Vite entrypoint, register the controller on that existing application instead:

```js
import { Application } from "@hotwired/stimulus"
import { TomSelectController } from "rails_fields_kit"

const application = Application.start()
application.register("rails-fields-kit--tom-select", TomSelectController)
```

If Stimulus is already started elsewhere, reuse that application instead of calling `Application.start()` a second time.

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
    { find: /^rails_fields_kit\/tom_select_controller$/, replacement: gemJavaScriptPath("tom_select_controller.js") },
    { find: /^rails_fields_kit\/tom_select_text_override_contract$/, replacement: gemJavaScriptPath("tom_select_text_override_contract.js") },
  ],
}
```

Keep the package-root alias for normal controller registration and rendered-field contract helper imports. Add the direct controller or helper subpath aliases only when the host app intentionally imports those files directly; this mirrors the setup doctor and importmap source of truth without making this README a full helper inventory.

Load Tom Select's CSS through your application's stylesheet pipeline or bundler:

```js
import "tom-select/dist/css/tom-select.css"
```

### Importmap route

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
pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
pin "rails_fields_kit/tom_select_text_override_contract", to: "rails_fields_kit/tom_select_text_override_contract.js"
```

Then register the controller from the file where your app already boots Stimulus:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

The package-root pin remains the normal route for controller registration and rendered-field contract helpers. The direct helper subpath pins mirror the generator and setup doctor source of truth for host apps that intentionally import those helper files directly; they do not change helper behavior or turn this README into a helper inventory.

### Direct imports and package exports

You can import the Stimulus controller from either documented path:

```js
import { TomSelectController } from "rails_fields_kit"
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

Use the package-root import for normal Stimulus registration. Use the direct controller entrypoint when a host app wants to pin or alias only that file.

`rails_fields_kit/index.js` re-exports the same controller as the direct `rails_fields_kit/tom_select_controller` entrypoint, and the package root also exposes read-only rendered-field contract helpers. Use the JavaScript exports section in [`doc/public_api.md`](doc/public_api.md#javascript-exports) as the source of truth for the current helper list, return shapes, and responsibility boundaries.

The table below is a routing aid, not an exhaustive export list. Scan it to choose the nearest helper family, then follow the source-of-truth link when you need the exact current export names or contract details.

| Helper family | Representative task | Representative helper | Source of truth |
| --- | --- | --- | --- |
| Request configuration | Check rendered endpoints, request param names, `minLength`, and error-surface id without executing requests | `tomSelectRequestContract(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Request-failure surface | Resolve the opt-in placeholder that request-failure events can pass back to host-app feedback UI | `readRenderedErrorSurface(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Selection state | Inspect initialized current values without mutating Tom Select, hidden fields, or events | `tomSelectSelectionContract(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Helper kind | Read the rendered Rails Fields Kit helper-lane kind without defining a new taxonomy or mutating Tom Select | `tomSelectFieldKindContract(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Selected preload configuration | Check rendered selected-preload URL, param names, and fixed query params | `readRenderedSelectedPreloadConfig(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Plugin configuration | Read the effective plugin list and derived clear/remove flags without owning plugin assets or styling | `tomSelectPluginContract(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Tom Select copy values | Confirm rendered no-results, loading, and create copy values without taking over locale or visible copy policy | `tomSelectTextOverrideContract(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Native wrapper wiring | Inspect label, described-by, affix, and wrapper elements for native helpers without changing accessibility markup | `nativeFieldAccessibilityContract(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |
| Native constraint attributes | Inspect rendered native `maxlength`, `minlength`, `pattern`, `autocomplete`, and `inputmode` attributes without owning browser validation messages or formatting policy | `nativeFieldConstraintContract(...)` | [`doc/public_api.md`](doc/public_api.md#javascript-exports) |

If the helper family you need is not named in this representative table, do not infer a different import policy from the README. Check [`doc/public_api.md#javascript-exports`](doc/public_api.md#javascript-exports) for the complete current package-root surface and use [`doc/package_root_helper_release_evidence.md`](doc/package_root_helper_release_evidence.md) only when the review is about release or sample-app evidence for a helper lane.

Rails Fields Kit still leaves the Tom Select pin source, bundler aliases, and any additional importmap conventions to the host app.

If either documented import path cannot be resolved, use [`doc/setup.md#troubleshoot-unresolved-imports`](doc/setup.md#troubleshoot-unresolved-imports) to check whether the package-root import or direct controller import is failing before changing bundler aliases, importmap pins, or Stimulus boot files.

Host-app scripts can inspect representative rendered contracts without executing requests or mutating UI state:

```js
import {
  nativeFieldAccessibilityContract,
  nativeFieldConstraintContract,
  readRenderedErrorSurface,
  readRenderedSelectedPreloadConfig,
  tomSelectFieldKindContract,
  tomSelectPluginContract,
  tomSelectRequestContract,
  tomSelectSelectionContract,
  tomSelectTextOverrideContract
} from "rails_fields_kit"

const requestContract = tomSelectRequestContract(tomSelectFieldElement)
const errorSurface = readRenderedErrorSurface(tomSelectFieldElement)
const selectionContract = tomSelectSelectionContract(tomSelectFieldElement)
const fieldKind = tomSelectFieldKindContract(tomSelectFieldElement)
const copyContract = tomSelectTextOverrideContract(tomSelectFieldElement)
const selectedPreloadConfig = readRenderedSelectedPreloadConfig(tomSelectFieldElement)
const pluginContract = tomSelectPluginContract(tomSelectFieldElement)
const nativeAccessibility = nativeFieldAccessibilityContract(nativeFieldElement)
const nativeConstraints = nativeFieldConstraintContract(nativeFieldElement)
```

These helpers return rendered contract or wiring details for host-app inspection only. Endpoint authorization, request execution, helper taxonomy decisions, visible fallback copy, retry UI, plugin assets and styling, selection mutation, validation policy, browser validation messages, formatting, normalization, and focus management remain host-app responsibilities.

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

`selected:` preloads the current option for edit forms before remote search runs. It accepts a record, a `{ value:, text: }` hash, a `{ id:, name: }` hash, an ID value, or an array of any of those for multiple fields. Explicit `0` and `false` values are valid selected values rather than blanks; for hashes, Rails Fields Kit also preserves `0` or `false` labels and only falls through to the alternate `id` / `name` key when the preferred key is `nil`.

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

Remote search and selected preload can also use `{ "results": [...] }` as a collection wrapper; use [`doc/controller_helpers.md#output-shape`](doc/controller_helpers.md#output-shape) as the source of truth for supported response shapes and for the boundary that keeps create-on-the-fly responses, pagination metadata, and arbitrary adapters separate.

Use [`doc/controller_helpers.md`](doc/controller_helpers.md#blank-query-policy) for the endpoint-side `minimum_query_length:` boundary. FormBuilder `min_length:` is the browser-side loading hint; the controller helper option is the server policy for blank or too-short direct requests.

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

This keeps the table gem or host app responsible for collecting column definitions, executing queries, and saving preferences. Rails Fields Kit only turns the documented metadata into FormBuilder helper calls. For the full protocol, renderer call specs, and custom renderer registry boundary, see [`doc/table_adapters.md`](doc/table_adapters.md). For the direct FormBuilder safe-join boundary, optional single outer `group_html:` wrapper, and lower-level render/call-spec lanes, see [`doc/table_direct_helper_boundary.md`](doc/table_direct_helper_boundary.md). For `group_html:` examples and semantic grouping boundaries, see [`doc/table_group_html.md`](doc/table_group_html.md).

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

For explicit `enum:` hashes, keys remain the submitted values and labels stay on the model I18n / humanized-key path. Use [`doc/enum_select.md`](doc/enum_select.md) for that boundary; arbitrary label/value DSLs, remote enum options, and PORO enum adapters are not current public APIs.

### Multiple selects and tags

Use `rfk_multi_select` for ordinary multiple selects and `rfk_tags` for tag-style inputs. Both render array-style parameter names and Rails' hidden blank input by default, so clearing all selected values still submits an empty value.
