# Token suggestion blank query policy

`rfk_token_suggestions_with` keeps blank-query initial suggestions enabled by default. A blank request normalizes every configured suggestion, applies any `limit:`, preserves `wrap:`, and returns the resulting option payload. This preserves the existing token-search behavior where the first focus can show operators, fields, saved searches, or other initial suggestions.

Use `minimum_query_length:` when a token suggestion endpoint should return no options until the incoming query is long enough:

```ruby
rfk_token_suggestions_with(
  action: :search_tokens,
  suggestions: ->(_query) { RailsFieldsKit::TokenSuggestions.build(fields: ORDER_SEARCH_FIELDS) },
  minimum_query_length: 1,
  wrap: "options"
)
```

When the query is shorter than the minimum, Rails Fields Kit returns an empty collection and preserves the configured wrapper shape, such as `{ "options": [] }`. When the query meets the minimum, the existing suggestion normalization, `match_fields:`, custom `query_param:`, custom output fields, and `limit:` behavior still apply.

This is an endpoint response policy only. It does not parse submitted token text, execute searches, rank suggestions, change authorization, or alter the bundled Tom Select request lifecycle. Host applications that need field-level browser gating can still pair this endpoint policy with the token search field's client-side options.
