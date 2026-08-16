# Rails Fields Kit Token Suggestions

`RailsFieldsKit::TokenSuggestions.build` creates option JSON for `rfk_token_search` suggestion endpoints. It helps applications offer operator, field, predicate, value, and saved-search suggestions without moving query parsing or search execution into Rails Fields Kit.

For a static visual reference of how saved-search suggestions read beside field and value completions, see [`token_search_saved_search_visual_reference.html`](token_search_saved_search_visual_reference.html).

When recording release or PR evidence for saved-search token suggestions, use [`saved_search_token_suggestion_evidence.md`](saved_search_token_suggestion_evidence.md) with the token suggestion lane in [`sample_app_results.md`](sample_app_results.md). Keep the evidence to suggestion option JSON such as token value, label, badge, and description instead of turning it into a saved-search selector or execution contract.

If you are deciding how token suggestions, Ransack-oriented suggestions, table metadata, and future registry proposals relate to each other, start with [`shared_metadata_navigation.md`](shared_metadata_navigation.md).

## Basic usage

```ruby
class OrderSearchTokensController < ApplicationController
  include RailsFieldsKit::Searchable

  rfk_token_suggestions_with(
    action: :index,
    suggestions: ->(_query) {
      RailsFieldsKit::TokenSuggestions.build(
        operators: ["OR", "not()"],
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

Use the endpoint from a token search field:

```erb
<%= f.rfk_token_search :query,
  url: order_search_tokens_path(format: :json),
  value_field: "value",
  label_field: "text",
  option_description_field: "description",
  option_badge_field: "badge" %>
```

## Inputs

### Operators

```ruby
RailsFieldsKit::TokenSuggestions.build(
  operators: ["OR", "not()", { token: "AND", label: "And" }]
)
```

Operator suggestions receive a default `badge` of `"operator"` and a default description of `"Search operator"`.

### Fields

Simple field list:

```ruby
RailsFieldsKit::TokenSuggestions.build(fields: [:status, :assignee])
```

Field configuration with value suggestions:

```ruby
RailsFieldsKit::TokenSuggestions.build(
  fields: {
    status: {
      label: "Status",
      description: "Workflow status",
      values: ["open", "closed"]
    }
  }
)
```

This yields a field token such as `status:` and value tokens such as `status:open` and `status:closed`.

### Predicates

Predicates are useful for date ranges or other field-specific values:

```ruby
RailsFieldsKit::TokenSuggestions.build(
  predicates: {
    created: ["today", "this_week"]
  }
)
```

This yields tokens such as `created:today` and `created:this_week`.

### Saved searches

```ruby
RailsFieldsKit::TokenSuggestions.build(
  saved_searches: [
    { token: "saved:mine", label: "Mine", description: "My saved search" }
  ]
)
```

Saved searches receive a default `badge` of `"saved"` when not specified. The visual reference keeps saved searches close to the same token suggestion option shape, while making the `saved` badge easy to distinguish from field and value completions.

Saved-search suggestions are the current public surface for this workflow. Rails Fields Kit renders them as token suggestion options for `rfk_token_search`; it does not currently provide an independent saved search selector helper, a submitted saved-search ID contract, persistence, query execution, authorization, or sharing policy. Keep those concerns in the host application, and split a follow-up feature issue before introducing a dedicated selector helper or changing the submitted value shape.

## Output fields

The builder uses Rails Fields Kit configuration defaults for option fields:

- value field: `RailsFieldsKit.configuration.default_value_field`, default `"value"`
- label field: `RailsFieldsKit.configuration.default_label_field`, default `"text"`
- description field: `RailsFieldsKit.configuration.default_option_description_field` or `"description"`
- badge field: `RailsFieldsKit.configuration.default_option_badge_field` or `"badge"`

Override them per call when your token endpoint uses custom JSON keys:

```ruby
RailsFieldsKit::TokenSuggestions.build(
  fields: [:status],
  value_field: "token",
  label_field: "label",
  description_field: "help",
  badge_field: "kind"
)
```

## Query matching

`rfk_token_suggestions_with` filters suggestions after each suggestion has been normalized into the rendered option payload. A non-empty query is compared case-insensitively against every rendered option value, not only the value and label fields.

With default field names, the following values can therefore match the endpoint query:

- `value` and `text`
- `description`
- `badge`
- any additional metadata values preserved on a hash suggestion

The same rule applies when `value_field:`, `label_field:`, `description_field:`, or `badge_field:` use custom output names: the final rendered payload values are searched. For example, a custom `kind: "saved-search"` badge or `help: "Weekly saved queue"` description can make that option match even when the token itself does not contain the query text.

Use `match_fields:` when the endpoint should only match specific rendered option keys while keeping the same suggestion payload. The option is an allowlist of rendered field names, so it should use the same names that appear in the final JSON payload:

```ruby
rfk_token_suggestions_with(
  suggestions: ->(_query) { RailsFieldsKit::TokenSuggestions.build(fields: ORDER_SEARCH_FIELDS) },
  match_fields: %w[value text]
)
```

For custom output keys, use those rendered keys instead:

```ruby
rfk_token_suggestions_with(
  suggestions: TOKEN_SUGGESTIONS,
  value_field: "token",
  label_field: "label",
  description_field: "help",
  badge_field: "kind",
  match_fields: %w[token label]
)
```

When `match_fields:` is omitted or `nil`, Rails Fields Kit keeps the existing all-rendered-values matching behavior. Unknown or missing match fields simply do not contribute a match. Empty query strings still return all suggestions before `limit:` is applied.

This is intentional current behavior for suggestion filtering. Saved-search suggestions with `badge: "saved"`, descriptive helper text, or host-app metadata may appear because those values match the query. Keep sensitive values out of suggestion metadata. Use `match_fields:` or pre-filter/omit fields in the host application when only token or label matching should be exposed.

## Shared metadata source pattern

Applications can keep their own field and operator metadata in one place, then pass derived views of that source into the current builders. This is the first feature-gate direction for field/operator suggestion registries: a docs pattern that avoids adding a public Rails Fields Kit registry object.

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

RailsFieldsKit::TokenSuggestions.build(
  fields: ORDER_SEARCH_FIELDS.transform_values { |config|
    config.slice(:label, :values)
  },
  operators: ["OR", "not()"]
)
```

Use this pattern when the host app wants one allowed field list to feed token suggestions, Ransack-oriented suggestions, and table filter metadata. Rails Fields Kit still receives ordinary `fields:`, `operators:`, and `predicates:` arguments; it does not own the registry, enforce authorization, or parse submitted tokens.

For the Ransack-specific view of the same metadata source, see [`ransack_suggestions.md`](ransack_suggestions.md#shared-metadata-source-pattern). For the table filter metadata view, see [`table_adapters.md`](table_adapters.md#shared-metadata-source-pattern).

## Responsibility boundary

`TokenSuggestions.build` only produces suggestion option JSON. The submitted search text still belongs to the host application, search object, Ransack integration, or another dedicated search layer. Rails Fields Kit does not parse arbitrary token expressions into SQL or decide model-specific search semantics.
