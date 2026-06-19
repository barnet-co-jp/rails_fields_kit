# Saved-search token suggestion evidence

Use this guide when a release or narrow PR needs representative evidence for `RailsFieldsKit::TokenSuggestions.build(saved_searches:)`.

This is a companion to the `Token suggestion and Ransack suggestion metadata checks` section in [`sample_app_results.md`](sample_app_results.md). Record the final result in the release results file for release candidates, or in the PR comment for a focused docs or feature PR.

## Scope

Saved-search suggestions are token suggestion option JSON for `rfk_token_search`. They are not a separate saved-search selector helper, and they do not change the submitted value shape.

Use this guide only when saved-search token suggestions are in release or PR scope. Do not turn it into a full helper inventory or a release-wide mandatory gate.

## Representative check

Use one endpoint backed by `rfk_token_suggestions_with` and `TokenSuggestions.build(saved_searches:)`.

Record:

- The branch, PR, or commit under review.
- The endpoint or route that returned the token suggestion payload.
- One saved-search suggestion token, such as `saved:mine`.
- The rendered value/token field used by the host app, for example `value: "saved:mine"`.
- The rendered label field, for example `text: "Mine"`.
- The rendered badge field, normally `badge: "saved"` when the suggestion did not specify another badge.
- The optional description field, for example `description: "My saved search"`.
- Whether the result was `PASS`, `FAIL`, `SKIPPED`, or `OUT OF SCOPE`.

## Boundary

Keep the evidence limited to suggestion metadata:

- `rfk_token_search` still submits token text, not a saved-search ID contract.
- Rails Fields Kit does not parse the submitted query, execute the saved search, enforce authorization, persist saved searches, or define sharing policy.
- The host app owns parser behavior, search execution, saved-search storage, permissions, and any saved-search management UI.
- If a release or PR proposes an independent saved-search selector helper or a submitted saved-search ID shape, split that into a feature issue instead of recording it as current sample evidence.

## Example evidence note

```text
Saved-search token suggestion evidence: PASS.
Endpoint: /orders/search_tokens.json on PR #123.
Observed option JSON included value "saved:mine", text "Mine", badge "saved", and description "My saved search".
The submitted value remains token text for the host app parser; persistence, execution, authorization, and sharing policy stayed host-app-owned.
```
