# Shared metadata pattern navigation

Use this page when you need one allowed field/operator list to feed token suggestions, Ransack-oriented suggestions, and table filter metadata, but you are not sure which document defines the current contract.

## Recommended reading order

1. Start with [`token_suggestions.md`](token_suggestions.md#shared-metadata-source-pattern) when the host app wants general token, field, predicate, value, operator, or saved-search suggestion JSON.
2. Continue to [`ransack_suggestions.md`](ransack_suggestions.md#shared-metadata-source-pattern) when the same source needs a Ransack-specific view for suggestion metadata.
3. Use [`table_adapters.md`](table_adapters.md#token-search-filter-metadata) when a table integration only needs to carry field metadata into Rails Fields Kit table filter rendering.
4. Copy [`shared_metadata_runnable_guide.md`](shared_metadata_runnable_guide.md) when a PR or sample app needs a small representative example that derives all three views from one host-app-owned source.
5. Use [`sample_app_results_route_guide.md`](sample_app_results_route_guide.md#rfk_token_search-representative-token-entry) when the review needs sample-app evidence for the `rfk_token_search` helper entry field itself, separate from suggestion metadata.
6. Use [`sample_app_results_route_guide.md`](sample_app_results_route_guide.md#token-and-ransack-suggestion-metadata) when a narrow PR needs a PR comment for token or Ransack suggestion payload evidence without updating the full release evidence log.
7. Check [`public_api.md`](public_api.md) for the stable 0.1.x API inventory before depending on a helper, package export, Stimulus value, event, or metadata object.
8. Treat [`../ROADMAP.md`](../ROADMAP.md) as future direction unless the same behavior is also documented in `public_api.md` or a current feature doc.

## Boundary summary

- Current public API: `TokenSuggestions.build`, `RansackSuggestions.build`, `TableFilterInput.ransack_filter`, table metadata objects, renderer helpers, documented FormBuilder helpers, package-root JavaScript exports, Stimulus values, and events listed in `public_api.md`.
- Host-app pattern: keeping one app-owned metadata source and passing derived hashes into the current builders. Rails Fields Kit receives ordinary arguments; it does not own the source registry.
- Token-search entry field: `rfk_token_search` renders and submits token text for the host app. It is evidence for helper rendering and submitted param shape, not for parsing, search execution, Ransack execution, table behavior, authorization, or saved-search resolution.
- Token and Ransack suggestion metadata: `TokenSuggestions.build`, `RansackSuggestions.build`, and `rfk_token_suggestions_with` evidence can confirm suggestion payloads, field/operator/value metadata, and Ransack-compatible metadata. That evidence is separate from token-entry helper rendering and still does not approve parsing, `params[:q]` construction, query execution, table persistence, authorization, or user-visible search results.
- Future proposal: helper-level adapter DSLs or a Rails Fields Kit-owned field/operator registry shown in `ROADMAP.md` before they are accepted and added to the public API docs.

## Helper-level Ransack DSL proposal gate

Do not implement helper-level Ransack DSL from this page or from the roadmap examples alone. `rfk_token_search ..., adapter: :ransack` and `rfk_table_filters ..., adapter: :ransack` are proposal shapes until a later feature issue accepts a concrete public API and updates `public_api.md`.

If that proposal moves forward, choose one first slice at a time:

- `rfk_token_search ..., adapter: :ransack` would be a token-entry helper surface. It would need a rendered data contract and docs that still leave token parsing, `params[:q]` construction, Ransack execution, authorization, allowed predicate enforcement, and pagination in the host app.
- `rfk_table_filters ..., adapter: :ransack` would be a table rendering convenience surface. It would need to derive from existing table metadata without replacing `TableFilterInput.ransack_filter` or making table preference persistence, query execution, or result navigation Rails Fields Kit responsibilities.

Do not land both helper-level shapes in the same first slice. The current metadata-first pattern already works without the shared metadata Ruby registry proposal (#2219), and a future registry decision should stay separate from any helper-level DSL decision.

## Runnable guide decision

Use the copyable runnable guide when prose examples are not enough evidence for review. The guide shows one ordinary Ruby metadata source, then derives the current public token suggestion, Ransack suggestion, and table filter metadata views from it. It is intentionally a docs/sample fixture pattern, not a Rails Fields Kit-owned registry or query execution path.

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

## Sample app and release evidence lane

Use this lane when a sample app or release PR needs representative evidence that one host-app-owned metadata source can feed all three current surfaces without turning Rails Fields Kit into the owner of search behavior.

Record evidence for the following checks in `doc/sample_app_results.md`, a release PR comment, or the sample app verification notes that accompany the release candidate:

- The same allowed field/operator source is visible in the host app and is not defined inside Rails Fields Kit.
- `TokenSuggestions.build` receives a derived token-oriented view such as labels, token values, and token operators.
- `RansackSuggestions.build` receives a derived Ransack-oriented view such as labels, predicates, and optional values from the same source.
- `TableFilterInput.ransack_filter` receives the same Ransack-oriented fields as table filter metadata.
- The evidence keeps query parsing, `params[:q]` construction, Ransack execution, authorization, relation construction, pagination, and user-visible feedback in the host app boundary.

When the sample app evidence is about the `rfk_token_search` field itself, record that separately with the token-entry lane in `sample_app_results_route_guide.md`. The token-entry lane can confirm helper rendering and submitted token text, while this shared metadata lane confirms suggestion and metadata payloads. Do not combine those results into one approval unless the PR or release intentionally exercised both.

When a narrow PR only clarifies metadata evidence, use the token/Ransack suggestion metadata PR comment shape in `sample_app_results_route_guide.md` instead of filling `sample_app_results.md`. Name whether the checked surface was `TokenSuggestions.build`, `RansackSuggestions.build`, `rfk_token_suggestions_with`, or the shared-source derivation, and keep the token-entry field lane separate unless it was actually exercised.

A compact release note is enough when the sample app already shows token suggestions, Ransack suggestions, and table filter metadata separately. Add a dedicated sample-app row only when the release claim depends on the shared-source adoption pattern itself.

## Non-goals

This navigation page does not add a registry API, token parser, Ransack execution path, authorization policy, table preference persistence contract, or visual reference artifact. It only keeps the current docs easier to scan without changing runtime behavior.
