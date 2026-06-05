# Shared metadata pattern navigation

Use this page when you need one allowed field/operator list to feed token suggestions, Ransack-oriented suggestions, and table filter metadata, but you are not sure which document defines the current contract.

## Recommended reading order

1. Start with [`token_suggestions.md`](token_suggestions.md#shared-metadata-source-pattern) when the host app wants general token, field, predicate, value, operator, or saved-search suggestion JSON.
2. Continue to [`ransack_suggestions.md`](ransack_suggestions.md#shared-metadata-source-pattern) when the same source needs a Ransack-specific view for suggestion metadata.
3. Use [`table_adapters.md`](table_adapters.md#token-search-filter-metadata) when a table integration only needs to carry field metadata into Rails Fields Kit table filter rendering.
4. Check [`public_api.md`](public_api.md) for the stable 0.1.x API inventory before depending on a helper, package export, Stimulus value, event, or metadata object.
5. Treat [`../ROADMAP.md`](../ROADMAP.md) as future direction unless the same behavior is also documented in `public_api.md` or a current feature doc.

## Boundary summary

- Current public API: `TokenSuggestions.build`, `RansackSuggestions.build`, `TableFilterInput.ransack_filter`, table metadata objects, renderer helpers, documented FormBuilder helpers, package-root JavaScript exports, Stimulus values, and events listed in `public_api.md`.
- Host-app pattern: keeping one app-owned metadata source and passing derived hashes into the current builders. Rails Fields Kit receives ordinary arguments; it does not own the source registry.
- Future proposal: helper-level adapter DSLs or a Rails Fields Kit-owned field/operator registry shown in `ROADMAP.md` before they are accepted and added to the public API docs.

## Host-app owned example

Keep the shared source in the application, then derive the view each current Rails Fields Kit surface needs.

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

# General token suggestions for `rfk_token_search` endpoints.
token_fields = ORDER_SEARCH_FIELDS.transform_values do |config|
  config.slice(:label, :values)
end

RailsFieldsKit::TokenSuggestions.build(
  fields: token_fields,
  operators: ["OR", "not()"]
)

# Ransack-oriented suggestions for the same allowed field list.
ransack_fields = ORDER_SEARCH_FIELDS.transform_values do |config|
  {
    label: config.fetch(:label),
    predicate: config.fetch(:ransack_predicate),
    values: config[:values]
  }.compact
end

RailsFieldsKit::RansackSuggestions.build(fields: ransack_fields)

# Table metadata can advertise the same Ransack-oriented fields.
RailsFieldsKit::TableFilterInput.ransack_filter(
  :query,
  fields: ransack_fields,
  url: search_tokens_path(format: :json),
  param_name: :q
)
```

This pattern only centralizes suggestion and metadata inputs. The host application still owns current-user filtering, submitted token parsing, `params[:q]` construction, authorization, Active Record relation construction, Ransack execution, pagination, and user-visible feedback.

Do not treat this example as a registry API. There is no Rails Fields Kit-owned field/operator registry, helper-level Ransack adapter DSL, or query execution path in the current 0.1.x public API.

## Non-goals

This navigation page does not add a registry API, token parser, Ransack execution path, authorization policy, table preference persistence contract, or visual reference artifact. It only keeps the current docs easier to scan without changing runtime behavior.
