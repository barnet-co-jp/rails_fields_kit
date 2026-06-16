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

## Future mention field decisions

A future mention helper should be split into a separate feature issue before implementation. That issue should decide at least:

- whether the first representative mention type is `@user`, `#tag`, or a narrower host-app-defined token
- whether submitted data remains textarea text only, or whether a hidden metadata field becomes part of the public contract
- whether suggestions can reuse `rfk_search_with` / `rfk_token_suggestions_with`, or need a separate endpoint shape
- whether Tom Select is appropriate for the interaction, or a textarea overlay controller is required
- how keyboard navigation, caret positioning, and screen-reader announcement are verified

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
