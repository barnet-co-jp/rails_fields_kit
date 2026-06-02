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

## Non-goals

This navigation page does not add a registry API, token parser, Ransack execution path, authorization policy, table preference persistence contract, or visual reference artifact. It only keeps the current docs easier to scan without changing runtime behavior.
