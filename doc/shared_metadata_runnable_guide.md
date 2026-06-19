# Shared metadata runnable guide

Use this guide when you want one host-app-owned metadata source to feed the current token suggestion, Ransack suggestion, and table filter metadata surfaces without introducing a Rails Fields Kit registry.

The example is intentionally copyable into a Rails app, console, or small docs smoke. Replace the URL string with your app route helper in real controller/view code.

## One app-owned source

```ruby
ORDER_SEARCH_FIELDS = {
  status: {
    label: "Status",
    values: %w[open closed pending],
    ransack_predicate: :status_eq
  },
  assignee: {
    label: "Assignee",
    ransack_predicate: :assignee_name_cont
  },
  created_after: {
    label: "Created after",
    values: ["today", "this_week"],
    ransack_predicate: :created_at_gteq
  }
}.freeze

ORDER_SEARCH_OPERATORS = ["OR", "not()"].freeze
```

This constant belongs to the host application. It can live beside an application search object, controller concern, or sample app fixture. Rails Fields Kit receives only the derived hashes shown below.

## General token suggestion view

```ruby
token_fields = ORDER_SEARCH_FIELDS.transform_values do |config|
  config.slice(:label, :values)
end

RailsFieldsKit::TokenSuggestions.build(
  fields: token_fields,
  operators: ORDER_SEARCH_OPERATORS
)
```

Use this view for `rfk_token_search` endpoints that should expose ordinary field, value, and operator suggestions.

## Ransack suggestion view

```ruby
ransack_fields = ORDER_SEARCH_FIELDS.transform_values do |config|
  {
    label: config.fetch(:label),
    predicate: config.fetch(:ransack_predicate),
    values: config[:values]
  }.compact
end

RailsFieldsKit::RansackSuggestions.build(
  fields: ransack_fields,
  operators: ORDER_SEARCH_OPERATORS
)
```

Use this view when the same allowed field list should advertise Ransack-oriented predicate metadata. The helper only builds suggestion option JSON; it does not call Ransack.

## Table filter metadata view

```ruby
RailsFieldsKit::TableFilterInput.ransack_filter(
  :query,
  fields: ransack_fields,
  url: "/orders/search_tokens.json",
  param_name: :q
)
```

Use this view when table metadata should carry the same Ransack-oriented fields into `rfk_table_filters(columns)` rendering.

## Responsibility boundary

Rails Fields Kit owns the current public helper surfaces used in this guide:

- `RailsFieldsKit::TokenSuggestions.build`
- `RailsFieldsKit::RansackSuggestions.build`
- `RailsFieldsKit::TableFilterInput.ransack_filter`

The host application still owns:

- where the shared field/operator source is stored
- current-user filtering for allowed fields and operators
- submitted token parsing
- `params[:q]` construction
- Ransack execution or any other query backend
- authorization, scoping, pagination, and user-visible feedback

Do not treat this guide as a registry API. It does not add a Rails Fields Kit-owned field/operator registry, helper-level Ransack adapter DSL, token parser, authorization policy, or table preference persistence contract.

## Sample evidence note

For a narrow PR, link to this guide or paste a short PR comment showing that the same app-owned source feeds the three derived views above. For a release candidate, record the same evidence in `doc/sample_app_results.md` only if the release claim depends on the shared-source pattern itself.
