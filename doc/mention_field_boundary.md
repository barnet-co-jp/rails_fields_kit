# Mention field boundary

Rails Fields Kit does not currently provide a textarea mention helper for `@user` or `#tag` style interactions.

This note keeps the #367 feature gate separate from the current public helper family. It is a proposal boundary, not an implemented API contract.

## Current helper lanes

Use the existing helpers when they match the submitted value shape:

| Need | Current lane | Boundary |
| --- | --- | --- |
| Free-text input with remote suggestions | `rfk_autocomplete` | The submitted value stays plain text. Choosing a suggestion helps fill the text, but Rails Fields Kit does not attach mention metadata. |
| Structured query text with token suggestions | `rfk_token_search` | The host app still parses and executes submitted search text. Use this for search syntax such as `status:open keyword`, not inline textarea mentions. |
| Tag-style multiple values | `rfk_tags` | The submitted value is a tag list or selected IDs/values. Use this when the field is the tag editor itself, not when tags appear inside longer prose. |
| Ordinary textarea content | `rfk_text_area` | The textarea remains native. Autosize, parsing, mention overlay UI, and persisted mention metadata stay with the host app. |

These lanes let applications ship many nearby workflows without introducing a dedicated mention overlay surface.

## Visual and evidence lane decision

Keep mention-field review in this boundary document until a helper contract is accepted. Do not add `rfk_mention_field`, mention overlay screenshots, or mention-specific cards to the visual reference family as current Rails Fields Kit evidence.

Use [`mention_field_boundary_sample_evidence.html`](mention_field_boundary_sample_evidence.html) only as proposal-only review evidence when a design reviewer needs to compare adjacent helper responsibilities before the helper exists. The artifact is intentionally kept out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md` so it cannot be mistaken for current public API.

A standalone visual lane would be easy to misread as an implemented textarea mention helper because it would need to show overlay positioning, suggestion rows, highlighted tokens, hidden metadata, or authorization-aware results. Those are exactly the decisions that remain future feature work and host-app responsibility today.

For current review, compare nearby helper lanes instead:

- use `rfk_autocomplete` when the field stores plain text selected from suggestions
- use `rfk_token_search` when the field stores structured search text
- use `rfk_tags` when the field stores a tag list or selected IDs/values
- use `rfk_text_area` when the field stores ordinary prose and the host app owns any mention parsing

If a future PR needs visual evidence before the helper is accepted, mark the artifact as proposal-only in its title, body copy, and PR description; keep it out of `visual_references.md`, `visual_reference_index.html`, release evidence, and `public_api.md` until the helper lands.

## Future mention field decisions

A future mention helper should be split into a separate feature issue before implementation. That issue should decide at least:

- whether the first representative mention type is `@user`, `#tag`, or a narrower host-app-defined token
- whether submitted data remains textarea text only, or whether a hidden metadata field becomes part of the public contract
- whether suggestions can reuse `rfk_search_with` / `rfk_token_suggestions_with`, or need a separate endpoint shape
- whether Tom Select is appropriate for the interaction, or a textarea overlay controller is required
- how keyboard navigation, caret positioning, and screen-reader announcement are verified

The safest first slice is a text-only textarea mention proposal, not a runtime helper. Treat the representative mention as a host-app-defined entity token. Documentation may use `@user` and `#tag` as examples, but Rails Fields Kit should not imply that it owns a user model, tag taxonomy, mention authorization, or notification workflow.

For that first slice, keep submitted data as textarea text only. Hidden mention metadata, selected entity IDs, persisted mention links, and mention-specific serialization should be follow-up feature gates because they define storage and application semantics that the gem cannot safely guess.

Suggestion endpoints should also stay comparative in the first slice. Document whether an application can adapt existing `rfk_search_with` or `rfk_token_suggestions_with` endpoints for suggestion rows, but do not introduce a mention-specific response shape until a later issue proves that the existing endpoint lanes are insufficient.

Tom Select should not be assumed to fit textarea mentions. It works well for select, tag, and token-search controls, but inline textarea mentions need caret-relative overlay positioning, text-range replacement, keyboard focus coordination, and screen-reader announcement. Those interaction details should be split into future design and implementation issues before any `rfk_mention_field` helper is accepted.

Before runtime implementation, split follow-up work along these boundaries:

- overlay design and browser evidence for caret positioning, keyboard navigation, and screen-reader announcement
- submitted metadata contract, if the text-only textarea value is not enough
- suggestion endpoint shape, only if existing remote suggestion helpers cannot express the needed rows
- visual proposal evidence, kept out of current public API and release evidence until the helper lands

## Host app responsibilities

Until such a helper is accepted, host apps own:

- parsing textarea content into mention tokens
- deciding which users, tags, or entities are mentionable for the current user
- authorization and scoping for suggestion endpoints
- persistence of mention links or hidden metadata
- notification, preview, highlighting, and audit behavior
- any textarea overlay library, styling, and browser evidence

Rails Fields Kit can still provide adjacent native textarea wrappers and remote suggestion helpers, but it should not imply that mention parsing or persistence is handled by the gem.

## Non-goals for #367

The #367 first slice should not add:

- `rfk_mention_field` or another new FormBuilder helper
- a JavaScript textarea overlay controller
- hidden metadata serialization
- mention parsing or query execution
- authorization, notification, persistence, or audit policy

The goal is to keep the roadmap readable: mention fields remain a useful future candidate, while the current public API stays limited to the helpers listed in `public_api.md`.
