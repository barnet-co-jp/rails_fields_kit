# Rails Fields Kit

Rails form helpers for searchable selects, comboboxes, tag inputs, autocomplete, token search, native wrapper helpers, and table metadata — powered by Tom Select.

## Quick start

```ruby
# Gemfile
gem "rails_fields_kit"
```

```bash
bundle install
rails generate rails_fields_kit:install
yarn add tom-select  # or npm/pnpm
```

Register the Stimulus controller and load CSS:

```js
import { application } from "controllers/application"
import { TomSelectController } from "rails_fields_kit"
import "tom-select/dist/css/tom-select.css"

application.register("rails-fields-kit--tom-select", TomSelectController)
```

Render your first field:

```erb
<%= form_with model: @order do |f| %>
  <%= f.rfk_select :customer_id,
    collection: @customers,
    collection_value_method: :id,
    collection_label_method: :name,
    include_blank: "Select a customer" %>
<% end %>
```

That's it. The submitted params stay the same shape as an ordinary Rails select.

## Choosing a helper

Before reading the individual helper APIs, read the [`Quick Guide`](doc/quick_guide.md). It starts from the final data/search semantics, explains why `rfk_lookup` is often the first candidate for business inputs with an optional master link, and provides a decision tree for choosing between lookup, combobox, autocomplete, select, and native fields.

| Need | Helper |
| --- | --- |
| Server-rendered select | `rfk_select` |
| Remote search / selected preload / create-on-the-fly that submits a selected ID/value | `rfk_combobox` |
| Free-text autocomplete | `rfk_autocomplete` |
| Free text plus an optional selected master ID | `rfk_lookup` |
| Structured token search (`status:open keyword`) | `rfk_token_search` |
| Multiple selection | `rfk_multi_select` |
| Tag-style entry | `rfk_tags` |
| Grouped `<optgroup>` | `rfk_grouped_select` |
| Rails enum attribute | `rfk_enum_select` |
| Table filters / cell editors from metadata | `rfk_table_filters` / `rfk_table_cell_editors` |
| Native input with shared wrapper/hint/error/accessibility | `rfk_text_field`, `rfk_text_area`, `rfk_password_field`, `rfk_money_field`, etc. |

For filters where a selected candidate must use exact ID matching while manual input must remain text for LIKE matching, use `rfk_lookup` so the text and selected ID remain separate. Do not repurpose `value_field:` as a display-label field to encode both meanings in one submitted value.

For free-text fields that need Tom Select's create-option precedence, create-on-blur, or post-selection query clearing behavior, use the explicit `add_precedence:`, `create_on_blur:`, and `clear_after_select:` pass-throughs. See [`doc/free_text_behavior.md`](doc/free_text_behavior.md).

See [`doc/field_helpers.md`](doc/field_helpers.md) for the full reference and [`doc/host_app_integration.md`](doc/host_app_integration.md) for host-app and AI/agent integration rules.

## Remote endpoints

```ruby
class CustomersController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_search_with(
    action: :index,
    model: Customer,
    value: :id,
    label: :name,
    search: [:name, :email],
    wrap: "options"
  )

  rfk_find_with(
    action: :selected,
    model: Customer,
    value: :id,
    label: :name,
    wrap: "option"
  )

  rfk_create_with(
    action: :create,
    model: Customer,
    value: :id,
    label: :name,
    params: [:name]
  )
end
```

See [`doc/controller_helpers.md`](doc/controller_helpers.md) for all options.

## Configuration

```ruby
# config/initializers/rails_fields_kit.rb
RailsFieldsKit.configure do |config|
  config.wrapper_class = "rfk-field"
  config.label_class = nil
  config.hint_class = "rfk-hint"
  config.error_class = "rfk-error"
end
```

See [`doc/configuration.md`](doc/configuration.md) for all defaults and [`doc/enum_select.md`](doc/enum_select.md) for the configurable enum I18n key path.

## JavaScript setup

### Bundler / Vite

For Vite, alias the gem's JavaScript path:

```js
// vite.config.js
import { execSync } from "node:child_process"

const gemRoot = execSync("bundle show rails_fields_kit", { encoding: "utf-8" }).trim()

export default {
  resolve: {
    alias: {
      "rails_fields_kit": `${gemRoot}/app/javascript/rails_fields_kit/index.js`,
      "rails_fields_kit/tom_select_controller": `${gemRoot}/app/javascript/rails_fields_kit/tom_select_controller.js`,
    }
  }
}
```

### Importmap

```bash
rails generate rails_fields_kit:install --importmap
```

Or add pins manually:

```ruby
# config/importmap.rb
pin "tom-select"
pin "rails_fields_kit", to: "rails_fields_kit/index.js"
pin "rails_fields_kit/tom_select_controller", to: "rails_fields_kit/tom_select_controller.js"
```

## Events

Tom Select lifecycle events are forwarded as Stimulus events:

- `rails-fields-kit--tom-select:load` / `load-error`
- `rails-fields-kit--tom-select:selected-load` / `selected-load-error`
- `rails-fields-kit--tom-select:create` / `create-error`
- `rails-fields-kit--tom-select:change` / `clear`

See [`doc/events.md`](doc/events.md) for payloads and details.

## Documentation

For a host application, prefer the documentation packaged with its installed gem. Run `bundle show rails_fields_kit` and read the files from that directory so the docs match the resolved version. If browsing the private GitHub repository instead, use the exact release tag or commit rather than assuming `main` matches the host app.

| Topic | Link |
| --- | --- |
| Quick Guide / helper decision tree | [`doc/quick_guide.md`](doc/quick_guide.md) |
| Host-app integration contract | [`doc/host_app_integration.md`](doc/host_app_integration.md) |
| Setup walkthrough | [`doc/setup.md`](doc/setup.md) |
| Field helper reference | [`doc/field_helpers.md`](doc/field_helpers.md) |
| Free-text Tom Select behavior | [`doc/free_text_behavior.md`](doc/free_text_behavior.md) |
| Controller helper reference | [`doc/controller_helpers.md`](doc/controller_helpers.md) |
| Configuration | [`doc/configuration.md`](doc/configuration.md) |
| Public API & JS exports | [`doc/public_api.md`](doc/public_api.md) |
| Events | [`doc/events.md`](doc/events.md) |
| Select migration guide | [`doc/select_migration.md`](doc/select_migration.md) |
| Token suggestions | [`doc/token_suggestions.md`](doc/token_suggestions.md) |
| Table metadata adapters | [`doc/table_adapters.md`](doc/table_adapters.md) |
| Styling boundary | [`doc/styling_boundary.md`](doc/styling_boundary.md) |
| Turbo reconnect | [`doc/tom_select_turbo_lifecycle.md`](doc/tom_select_turbo_lifecycle.md) |
| Support boundary | [`doc/support_boundary.md`](doc/support_boundary.md) |

## Setup doctor

After installation, check your setup:

```bash
rails rails_fields_kit:doctor
```

The doctor reports initializer presence, importmap pins, and Stimulus registration signals. It does not install Tom Select or choose your bundling strategy.

## License

MIT. See [LICENSE.txt](LICENSE.txt).
