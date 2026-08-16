# Rails Fields Kit Ransack Suggestions

`RailsFieldsKit::RansackSuggestions.build` creates token suggestion option JSON for `rfk_token_search` inputs that are intended to produce Ransack-compatible search parameters.

This helper does not require the `ransack` gem and does not call `Model.ransack`. It only helps the UI expose allowed fields, predicates, values, operators, and saved searches. The host application remains responsible for parsing the submitted token text, mapping it into `params[:q]`, authorization, scoping, and result pagination.

If you are deciding how token suggestions, Ransack-oriented suggestions, table metadata, and future registry proposals relate to each other, start with [`shared_metadata_navigation.md`](shared_metadata_navigation.md).

## Basic usage

```ruby
class OrderSearchTokensController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_token_suggestions_with(
    action: :index,
    suggestions: ->(_query) {
      RailsFieldsKit::RansackSuggestions.build(
        fields: {
          name: :name_cont,
          email: :email_cont,
          status: {
            label: "Status",
            predicate: :status_eq,
            values: %w[open closed]
          },
          created_after: {
            label: "Created after",
            predicate: :created_at_gteq,
            values: [
              { value: "today", label: "Today" },
              { value: "this_week", label: "This week" }
            ]
          }
        },
        saved_searches: [
          { token: "saved:mine", label: "Mine" }
        ]
      )
    },
    wrap: "options"
  )
end
```

Use the endpoint from a token search field:

```erb
<%= f.rfk_token_search :query,
  url: order_search_tokens_path(format: :json),
  value_field: "value",
  label_field: "text",
  option_description_field: "description",
  option_badge_field: "badge" %>
```

## Field mapping

Simple mapping:

```ruby
RailsFieldsKit::RansackSuggestions.build(
  fields: {
    name: :name_cont,
    email: :email_cont
  }
)
```

This emits tokens such as `name:` and `email:` with metadata:

```json
{
  "value": "name:",
  "text": "Name",
  "description": "Ransack predicate name_cont",
  "badge": "ransack",
  "ransack_predicate": "name_cont",
  "ransack_field": "name"
}
```

Richer mapping:

```ruby
RailsFieldsKit::RansackSuggestions.build(
  fields: {
    status: {
      label: "Status",
      predicate: :status_eq,
      values: %w[open closed]
    }
  }
)
```

This emits both the field token and value tokens such as `status:open`. Value suggestions include `ransack_value` metadata in addition to `ransack_predicate` and `ransack_field`.

## Predicate aliases

Field metadata can use several equivalent keys for the Ransack predicate:

```ruby
RailsFieldsKit::RansackSuggestions.build(
  fields: {
    customer: { ransack_predicate: :customer_name_cont },
    email: { ransack: :email_cont },
    code: { param: :code_eq }
  }
)
```

The recognized predicate keys are:

- `predicate`
- `ransack_predicate`
- `ransack`
- `param`

## Value metadata

Structured value metadata is preserved in generated suggestions:

```ruby
RailsFieldsKit::RansackSuggestions.build(
  fields: {
    created_after: {
      predicate: :created_at_gteq,
      values: [
        {
          value: "today",
          label: "Today",
          description: "Created today",
          range: "day"
        }
      ]
    }
  }
)
```

Custom metadata such as `range` is copied onto the generated value option. Generated suggestions are independent from the original field/value hashes, so applications can decorate or rewrite suggestion payloads without mutating the source configuration.

## Operators and saved searches

By default, the builder includes `OR` and `not()` operator suggestions. Pass `operators: []` to disable them or pass your own list.

```ruby
RailsFieldsKit::RansackSuggestions.build(
  fields: { name: :name_cont },
  operators: ["OR", "not()"],
  saved_searches: [
    { token: "saved:mine", label: "Mine" }
  ]
)
```

## Custom output fields

The builder uses the same option field defaults as Rails Fields Kit:

- value field: `RailsFieldsKit.configuration.default_value_field`, default `"value"`
- label field: `RailsFieldsKit.configuration.default_label_field`, default `"text"`
- description field: `RailsFieldsKit.configuration.default_option_description_field` or `"description"`
- badge field: `RailsFieldsKit.configuration.default_option_badge_field` or `"badge"`

Override them when your Tom Select field uses custom keys:

```ruby
RailsFieldsKit::RansackSuggestions.build(
  fields: { name: :name_cont },
  value_field: "token",
  label_field: "label",
  description_field: "help",
  badge_field: "kind"
)
```

## Shared metadata source pattern

When a host app keeps one allowed field/operator source for token search, Ransack suggestions, and table filter metadata, derive the Ransack builder input from that source instead of introducing a Rails Fields Kit registry object.

For the current/proposal boundary and the shortest reading order across token suggestions, Ransack suggestions, table metadata, and roadmap material, see [`shared_metadata_navigation.md`](shared_metadata_navigation.md).

```ruby
ORDER_SEARCH_FIELDS = {
  status: {
    label: "Status",
    values: %w[open closed],
    ransack_predicate: :status_eq
  },
  assignee: {
    label: "Assignee",
    ransack_predicate: :assignee_name_cont
  }
}.freeze

ransack_fields = ORDER_SEARCH_FIELDS.transform_values do |config|
  {
    label: config.fetch(:label),
    predicate: config.fetch(:ransack_predicate),
    values: config[:values]
  }.compact
end

RailsFieldsKit::RansackSuggestions.build(fields: ransack_fields)
```

The same `ransack_fields` map can also be passed to `RailsFieldsKit::TableFilterInput.ransack_filter` when table metadata should advertise the same allowed predicates. The host app still decides whether submitted tokens become `params[:q]`, which predicates are allowed for the current user, and how Ransack is executed.

## Table filter metadata boundary

`RailsFieldsKit::TableFilterInput.ransack_filter` is the current table-oriented Ransack path. It produces token-search table metadata with `adapter: :ransack`, `param_name`, and `fields` in the options hash, then `RailsFieldsKit::TableRenderer` passes those options to the existing `rfk_token_search` helper.

That means the adapter metadata is descriptive. Rails Fields Kit does not add a direct `rfk_table_filters(..., adapter: :ransack)` helper option today, does not parse the submitted query string, and does not call Ransack. If a table integration needs to build `params[:q]`, it should read the metadata or use its own host-app parser and keep authorization, scoping, pagination, and relation execution outside Rails Fields Kit.

When the metadata is rendered through `rfk_table_filters(columns)`, `RailsFieldsKit::TableMetadata.render_filters`, or `RailsFieldsKit::TableRenderer.render_filter`, host-app JavaScript can read the rendered field with the package-root helper:

```js
import { readRenderedTableFilterMetadata } from "rails_fields_kit"

const metadata = readRenderedTableFilterMetadata(queryField)
// => { adapter: "ransack", paramName: "q", fields: { name: "name_cont" } }
```

Use that rendered metadata as a parser input or QA check, not as an execution engine. The host app still owns token parsing, current-user filtering, `params[:q]` construction, and the final Ransack call.

For the table filter metadata view, see [`table_adapters.md`](table_adapters.md#token-search-filter-metadata). For the general token suggestion view of the same metadata source, see [`token_suggestions.md`](token_suggestions.md#shared-metadata-source-pattern).

## Responsibility boundary

Rails Fields Kit intentionally stops at suggestion metadata. A typical application still needs to:

- parse the submitted token search text
- decide which fields and predicates are allowed
- transform the parsed tokens into `params[:q]`
- call `Model.ransack(params[:q])` or an equivalent search object
- scope, authorize, paginate, and render results

This keeps Ransack optional and avoids making Rails Fields Kit a query engine.

## Copyable host-app parser example

Keep the suggestion metadata and the parser whitelist aligned from the same allowed field list. The builder helps the UI advertise supported tokens; the host app still chooses which submitted tokens become `params[:q]`.

```ruby
class OrderTokenQuery
  ALLOWED_FIELDS = {
    "name" => :name_cont,
    "email" => :email_cont,
    "status" => :status_eq
  }.freeze

  def initialize(raw_query)
    @raw_query = raw_query.to_s
  end

  def to_ransack_params
    @raw_query.split(/\s+/).each_with_object({}) do |token, params|
      field, value = token.split(":", 2)
      next if value.blank?

      predicate = ALLOWED_FIELDS[field]
      next unless predicate

      params[predicate] = value
    end
  end
end
```

When the token search was rendered from `TableFilterInput.ransack_filter`, the host app can build the same whitelist from rendered metadata instead of duplicating the map in JavaScript:

```js
import { readRenderedTableFilterMetadata } from "rails_fields_kit"

const metadata = readRenderedTableFilterMetadata(document.querySelector("[name='query']"))

if (metadata?.adapter === "ransack") {
  const allowedFields = metadata.fields
  const paramName = metadata.paramName || "q"

  // Send the submitted token string plus the allowlist to a host-app parser.
  // Rails Fields Kit does not parse the token string or call Ransack here.
  submitSearch({ paramName, allowedFields })
}
```

Use that parser in the host app's controller or search object:

```ruby
def index
  token_query = OrderTokenQuery.new(params[:query])
  @q = Order.ransack(token_query.to_ransack_params)
  @orders = @q.result
end
```

This example is intentionally small. It only handles simple `field:value` tokens and leaves operators such as `OR`, `not()`, saved searches, duplicate-field merge rules, and free-text fallback semantics to the host application.

The suggestion payload can still expose richer metadata like `ransack_predicate`, `ransack_field`, and `ransack_value`, but the parser remains the place where the host app decides which tokens to honor.
