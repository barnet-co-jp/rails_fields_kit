# Field helper reviewer routes

Use this note as a narrow companion to the field helper quick chooser. The chooser in [`field_helpers.md`](field_helpers.md#quick-chooser) remains the source of truth for picking a helper. This page only helps a design reviewer choose the nearest static visual reference lane after the helper family is chosen.

## Route by helper family

| Helper family | Start from | Visual review lane |
| --- | --- | --- |
| Collection-backed select helpers | `rfk_select`, `rfk_multi_select`, `rfk_grouped_select`, `rfk_enum_select` | Use [`visual_references.md`](visual_references.md) to pick the Tom Select core reference. For grouped choices, inspect the grouped select lane before remote or token lanes. |
| Remote suggestion helpers | `rfk_combobox`, `rfk_autocomplete` | Start with the Tom Select core reference, then use request-failure or selected-preload lanes only when the review question is about endpoint feedback or label restore. |
| Token search helpers | `rfk_token_search` | Use the token search saved-search reference when the question is token density, saved-search suggestions, delimiter visibility, or wrapped token text. Query parsing and execution remain host-app owned. |
| Tag-style helpers | `rfk_tags` | Use the Tom Select tags lane when the question is selected item readability, remove affordance, or create-on-the-fly visual state. Final tag policy remains host-app owned. |
| Native wrapper helpers | `rfk_text_field`, `rfk_text_area`, `rfk_password_field`, `rfk_money_field`, `rfk_phone_field`, `rfk_search_field`, and sibling native wrappers | Use the native field visual reference for wrapper, label, hint, affix, validation, accessibility, browser semantics, metadata, and constraint attributes. |
| Table metadata helpers | `rfk_table_filters`, `rfk_table_cell_editors` | Use the table metadata visual reference for filter/editor rendering, group wrapper boundaries, and shared metadata source review. Table persistence and query execution stay outside Rails Fields Kit. |

## Guardrails

- Keep README as the first reader route, not a full helper inventory.
- Keep [`field_helpers.md`](field_helpers.md) as the helper chooser and example source.
- Keep [`visual_references.md`](visual_references.md) as the maintained visual reference map.
- Do not copy the JavaScript export list or public API inventory into this note.
- Do not treat visual references as production CSS approval or runtime behavior tests.

## When the route is unclear

Choose the lane by the question being reviewed:

- Helper choice or migration shape: use [`field_helpers.md`](field_helpers.md).
- Rendered state or design scanability: use [`visual_references.md`](visual_references.md).
- Public API or package-root JavaScript helpers: use [`public_api.md`](public_api.md#javascript-exports).
- Release or sample-app evidence for package-root helpers: use [`package_root_helper_release_evidence.md`](package_root_helper_release_evidence.md).

This separation keeps the quick chooser short while still giving reviewers a direct path from helper family to visual evidence.
