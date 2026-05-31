# Visual References

Use these static HTML references as quick QA and design-review entrypoints for Rails Fields Kit's representative rendered states. They are documentation artifacts only; production helper markup, runtime behavior, and host-app query or persistence responsibilities stay in the code and topic docs.

Start from [`visual_reference_index.html`](visual_reference_index.html) when you want a one-screen reviewer entrypoint for the full family. Use this Markdown map when you need the maintained source-of-truth list and scope notes.

## Reference map

| Reference | Use it to review | Primary release or design question |
| --- | --- | --- |
| [`visual_reference_index.html`](visual_reference_index.html) | One-screen index for choosing the right static visual reference | Can release and design reviewers scan the current artifact family before opening an individual reference? |
| [`tom_select_visual_reference.html`](tom_select_visual_reference.html) | Tom Select-backed select, combobox, autocomplete, tags, token search, preload, create, and error states | Do the core Tom Select-backed states remain readable across normal and narrow viewports? |
| [`tom_select_text_override_visual_reference.html`](tom_select_text_override_visual_reference.html) | Configured `no_results_text`, `loading_text`, and `create_text` copy states | Can reviewers inspect text override copy without confusing it with locale ownership or request behavior? |
| [`native_field_visual_reference.html`](native_field_visual_reference.html) | Native helper wrapper, label, hint, prefix, suffix, readonly, disabled, and validation states | Do native helper states remain legible while staying separate from Tom Select-backed behavior? |
| [`table_metadata_visual_reference.html`](table_metadata_visual_reference.html) | Table metadata filter and cell editor lanes, including responsibility boundaries | Can reviewers scan metadata-driven filter/editor examples without treating table persistence or query execution as Rails Fields Kit responsibilities? |
| [`token_search_saved_search_visual_reference.html`](token_search_saved_search_visual_reference.html) | Saved-search token suggestions beside field and value completions | Can reviewers distinguish saved search suggestions without treating token parsing, search execution, or authorization as Rails Fields Kit responsibilities? |

## How to use this family

- For release verification, start from [`final_release_checklist.md`](final_release_checklist.md) and record manual evidence in [`sample_app_results.md`](sample_app_results.md) when a release or PR changes a visual reference.
- For design review, start with [`visual_reference_index.html`](visual_reference_index.html) when you need to pick a lane, then use the relevant static HTML file directly and keep comments tied to the lane it represents.
- For token suggestion behavior and saved-search option shape, use [`token_suggestions.md`](token_suggestions.md) as the source of truth and treat the saved-search visual reference as a static review artifact.
- If a new visual reference is added, update this map, the HTML index, and the README docs map after the reference lands on `main`.
- Do not use this index to document proposal-only helper names or unmerged feature lanes as current public API.
