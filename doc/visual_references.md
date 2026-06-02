# Visual References

Use these static HTML references as quick QA and design-review entrypoints for Rails Fields Kit's representative rendered states. They are documentation artifacts only; production helper markup, runtime behavior, and host-app query or persistence responsibilities stay in the code and topic docs.

Start from [`visual_reference_index.html`](visual_reference_index.html) when you want a one-screen reviewer entrypoint for the full family. Use its artifact links when you know the exact file, its helper-family picker when the reference set has grown and you need to choose by surface area, or its task picker when you know the reviewer job, such as release verification, design or copy review, request-failure feedback, or table integration boundary checks. Use this Markdown map when you need the maintained source-of-truth list and scope notes.

## Reference map

| Reference | Use it to review | Primary release or design question |
| --- | --- | --- |
| [`visual_reference_index.html`](visual_reference_index.html) | One-screen index for choosing the right static visual reference by artifact, helper family, or reviewer task | Can release and design reviewers scan the current artifact family before opening an individual reference? |
| [`tom_select_visual_reference.html`](tom_select_visual_reference.html) | Tom Select-backed select, combobox, autocomplete, tags, token search, preload, create, and error states | Do the core Tom Select-backed states remain readable across normal and narrow viewports? |
| [`tom_select_request_failure_visual_reference.html`](tom_select_request_failure_visual_reference.html) | Focused `error_surface: true` request-failure states and operation/status metadata for Tom Select-backed helpers | Can reviewers inspect hidden, revealed, restore-failure, create-failure, custom-wrapper, and metadata feedback without treating retry UI or request lifecycle behavior as built in? |
| [`tom_select_text_override_visual_reference.html`](tom_select_text_override_visual_reference.html) | Configured `no_results_text`, `loading_text`, and `create_text` copy states | Can reviewers inspect text override copy without confusing it with locale ownership or request behavior? |
| [`native_field_visual_reference.html`](native_field_visual_reference.html) | Native helper wrapper, label, hint, prefix, suffix, required marker, readonly, disabled, validation, and narrow viewport stress states | Do native helper states remain legible, including long-label and affix-heavy narrow lanes, while staying separate from Tom Select-backed behavior? |
| [`configuration_wrapper_class_visual_reference.html`](configuration_wrapper_class_visual_reference.html) | Initializer-driven wrapper, label, hint, error, control, prefix, and suffix class examples | Can reviewers see that configured classes are host-app pass-through, not bundled CSS framework support or helper behavior changes? |
| [`table_metadata_visual_reference.html`](table_metadata_visual_reference.html) | Table metadata filter and cell editor lanes, including responsibility boundaries | Can reviewers scan metadata-driven filter/editor examples without treating table persistence or query execution as Rails Fields Kit responsibilities? |
| [`token_search_saved_search_visual_reference.html`](token_search_saved_search_visual_reference.html) | Saved-search token suggestions beside field and value completions, plus delimiter and multi-token wrapping states | Can reviewers distinguish saved search suggestions and wrapped token text without treating token parsing, search execution, or authorization as Rails Fields Kit responsibilities? |

## How to use this family

- For release verification, start from [`final_release_checklist.md`](final_release_checklist.md) and record manual evidence in [`sample_app_results.md`](sample_app_results.md) or the release PR comment when a release or PR changes the one-screen index or a visual reference artifact.
- For design review, start with [`visual_reference_index.html`](visual_reference_index.html) when you need to pick a lane. Use the helper-family picker for Tom Select-backed controls, native field wrappers, or table/token bridge questions, then keep comments tied to the lane it represents.
- For native helper wrapper review, use [`native_field_visual_reference.html`](native_field_visual_reference.html) to check label, hint, affix, required marker, validation, noneditable, accessibility, generated-id, and narrow viewport stress lanes without treating the static artifact as production CSS or runtime behavior.
- For initializer-driven class review, use [`configuration_wrapper_class_visual_reference.html`](configuration_wrapper_class_visual_reference.html) to compare default `rfk-*` classes with host-app classes while keeping CSS framework ownership and production styling in the host app.
- For request-failure feedback, use the index task picker or [`tom_select_request_failure_visual_reference.html`](tom_select_request_failure_visual_reference.html) to review the `error_surface: true` slot and operation/status metadata while keeping retry copy, reveal timing, and request lifecycle behavior with the host app.
- For table integration boundary checks, use the index family picker or task picker to choose between metadata-driven filters/editors and saved-search token suggestion states.
- For token suggestion behavior, delimiter visibility, and saved-search option shape, use [`token_suggestions.md`](token_suggestions.md) as the source of truth and treat the saved-search visual reference as a static review artifact.
- If a new visual reference is added, update this map, the HTML index, and the README docs map after the reference lands on `main`.
- Do not use this index to document proposal-only helper names or unmerged feature lanes as current public API.
