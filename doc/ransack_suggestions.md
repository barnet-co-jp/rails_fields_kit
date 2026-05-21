# Rails Fields Kit Ransack Suggestions

`RailsFieldsKit::RansackSuggestions.build` creates token suggestion option JSON for `rfk_token_search` inputs that are intended to produce Ransack-compatible search parameters.

This helper does not require the `ransack` gem and does not call `Model.ransack`. It only helps the UI expose allowed fields, predicates, values, operators, and saved searches. The host application remains responsible for parsing the submitted token text, mapping it into `params[:q]`, authorization, scoping, and result pagination.

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

## Responsibility boundary

Rails Fields Kit intentionally stops at suggestion metadata. A typical application still needs to:

- parse the submitted token search text
- decide which fields and predicates are allowed
- transform the parsed tokens into `params[:q]`
- call `Model.ransack(params[:q])` or an equivalent search object
- scope, authorize, paginate, and render results

This keeps Ransack optional and avoids making Rails Fields Kit a query engine.