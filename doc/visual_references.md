# Visual References

Use these static HTML references as quick QA and design-review entrypoints for Rails Fields Kit's representative rendered states. They are documentation artifacts only; production helper markup, runtime behavior, and host-app query or persistence responsibilities stay in the code and topic docs.

Start from [`visual_reference_index.html`](visual_reference_index.html) when you want a one-screen reviewer entrypoint for the full family. Use its artifact links when you know the exact file, its helper-family picker when the reference set has grown and you need to choose by surface area, or its task picker when you know the reviewer job. The task picker is grouped around release verification, design/copy review, request-failure feedback, and table/token boundary checks so reviewers can choose the shortest landed artifact without treating the index as a proposal list. Use this Markdown map when you need the maintained source-of-truth list and scope notes.

For narrow viewport review of the reference family itself, start from [`visual_reference_index.html`](visual_reference_index.html) and confirm the task picker, family cards, tags, artifact links, and contract-reader routes remain readable before opening an individual artifact.

For README first field quickstart follow-up, use the Tom Select core reference's idle server-rendered collection lane as the `rfk_select` review route. That lane represents an endpoint-free select with documented options; remote `rfk_combobox`, selected preload restore/failure, token search, and create-on-the-fly states stay in their separate Tom Select lanes.

For selected preload restore or failure review, use the Tom Select core reference's `Selected Preload` and `Selected Preload Failure` lanes before moving to the broader request-failure reference. Treat those lanes as static label restoration evidence; retry UI, endpoint error handling, and lifecycle timing remain host-app responsibilities.

For Tom Select keyboard / focus review, use the Tom Select core reference's focus review lane. It statically compares focused control chrome, active dropdown option, and selected item focus/readability while leaving actual keyboard mechanics to Tom Select and the host app runtime.

For `rfk_grouped_select` visual review, use the Tom Select core reference's `Grouped Select` lane. That lane represents a collection-backed grouped choice surface with visible optgroup headings; disabled option metadata, remote grouped search, and endpoint behavior stay outside the static visual reference.

For `rfk_enum_select` explicit-source or remote option label-fallback review, use [`tom_select_source_fallback_review.html`](tom_select_source_fallback_review.html) as a focused companion to the Tom Select core reference. It compares model enum source vs explicit `enum:` source and normal remote labels vs value fallback without changing FormBuilder behavior, renderer markup, request lifecycle, or endpoint validation.

For package-root contract reader review, use [`public_api.md#javascript-exports`](public_api.md#javascript-exports) as the source of truth for the current landed helper list and return-shape boundary. Then use the visual reference index to choose the closest rendered-state lane: Tom Select text override copy, native helper accessibility wiring, or request-failure feedback. The visual reference family should point reviewers to those lanes without copying the JavaScript export inventory or naming proposal-only helpers as current API.

For shared metadata source pattern review, use [`shared_metadata_navigation.md`](shared_metadata_navigation.md) as the source of truth for the host-app-owned pattern and inspect the table metadata reference's shared source lane only as a rendered-state overview. Keep future registry APIs, helper-level adapter DSLs, token parsing, Ransack execution, authorization, and table persistence outside the visual reference.

For table group wrapper review, use [`table_group_html.md`](table_group_html.md) as the source of truth for the `group_html:` helper boundary and inspect the table metadata reference's group wrapper lane for the visual difference between group-level attributes and per-field `wrapper_html:`. Keep layout framework choices, table persistence, query execution, and authorization outside the static artifact.

For native helper accessibility-contract follow-up, use the native helper reference as the visual lane and the release checklist or sample app evidence log as the recording lane. Keep those two artifacts linked by the checked helper state and viewport instead of duplicating helper markup or runtime contract details in this map.

For setup doctor output review, use [`setup_doctor_output_review.md`](setup_doctor_output_review.md) as the release-evidence lane for CLI diagnostic readability. Keep it separate from the field UI visual references: it reviews `[OK]`, `[MISSING]`, `[MANUAL]`, and target-mismatch scanability without changing setup doctor runtime behavior or output wording.

For `rfk_text_area` multiline review, use the native helper reference's multiline textarea lane. It keeps long textarea content, long hint copy, and validation copy in the same native wrapper surface while leaving autosize, production CSS, browser validation, and helper markup behavior out of scope.

For native browser semantics review, use the native helper reference's `Browser semantics` lane to distinguish browser-provided search, email, URL, telephone, money, and percent metadata from Rails Fields Kit formatting or validation behavior.

For native constraint attribute review, use the native helper reference's constraint boundary lane. It keeps `maxlength`, `pattern`, `inputmode`, and `autocomplete` visible as ordinary native attributes while leaving browser validation copy, masking, formatting, normalization, and autocomplete policy with the host app.

For uppercase visual-reference microcopy such as tags, metadata chips, and optgroup labels, review readable spacing across the family before widening letter spacing. Keep the static artifacts product-neutral and favor unexpanded letter spacing when the copy is already short, dense, and scan-oriented.

## Reference map

| Reference | Use it to review | Primary release or design question |
| --- | --- | --- |
| [`visual_reference_index.html`](visual_reference_index.html) | One-screen index for choosing the right static visual reference by artifact, helper family, reviewer task, contract-reader review route, or narrow viewport readability check | Can release and design reviewers scan the current artifact family before opening an individual reference, while keeping `public_api.md#javascript-exports` as the package-root export source of truth and keeping task/family labels readable at narrow widths? |
| [`tom_select_visual_reference.html`](tom_select_visual_reference.html) | Tom Select-backed select, grouped select, combobox, autocomplete, tags, token search, preload restore/failure, create, error, keyboard focus, active option, and selected item focus states, including the endpoint-free `rfk_select` first field lane and `rfk_grouped_select` optgroup-preserving lane | Do the core Tom Select-backed states remain readable across normal and narrow viewports, and can reviewers distinguish server-rendered collection selects, selected preload feedback, grouped choices, focus/active states, and remote search lanes? |
| [`tom_select_source_fallback_review.html`](tom_select_source_fallback_review.html) | Focused companion lane for explicit `enum:` source and remote option label fallback display review | Can reviewers compare model enum source vs explicit enum source, and label-present vs value-fallback remote options, without treating this artifact as runtime behavior or endpoint policy? |
| [`tom_select_request_failure_visual_reference.html`](tom_select_request_failure_visual_reference.html) | Focused `error_surface: true` request-failure states and operation/status metadata for Tom Select-backed helpers | Can reviewers inspect hidden, revealed, restore-failure, create-failure, custom-wrapper, and metadata feedback without treating retry UI or request lifecycle behavior as built in? |
| [`tom_select_error_surface_contract_visual_reference.html`](tom_select_error_surface_contract_visual_reference.html) | Focused `error_surface: true` live-region contract states and wrapper customization boundaries | Can reviewers inspect the hidden-by-default live region, host-app-visible feedback, and custom wrapper attribute lane without treating retry UI, visible copy, or request lifecycle behavior as built in? |
| [`tom_select_text_override_visual_reference.html`](tom_select_text_override_visual_reference.html) | Configured `no_results_text`, `loading_text`, and `create_text` copy states | Can reviewers inspect text override copy without confusing it with locale ownership or request behavior? |
| [`native_field_visual_reference.html`](native_field_visual_reference.html) | Native helper wrapper, label, hint, prefix, suffix, required marker, readonly, disabled, validation, multiline textarea, accessibility contract, browser semantics, metadata and constraint attributes, and narrow viewport stress states | Do native helper states remain legible, including long-label, affix-heavy, multiline textarea, accessibility-contract, search/email/URL semantics, and metadata/constraint boundary lanes, while staying separate from Tom Select-backed behavior and giving release reviewers a concrete lane to record? |
| [`native_accessibility_contract_visual_reference.html`](native_accessibility_contract_visual_reference.html) | Focused native helper accessibility contract reader lanes for wrapper, label, hint, error, and `aria-describedby` wiring | Can reviewers inspect the current rendered accessibility contract without treating future return-shape proposals, id generation, validation messages, or focus management as current public behavior? |
| [`configuration_wrapper_class_visual_reference.html`](configuration_wrapper_class_visual_reference.html) | Initializer-driven wrapper, label, hint, error, control, prefix, and suffix class examples, including a narrow viewport review lane | Can reviewers see that configured classes are host-app pass-through, not bundled CSS framework support or helper behavior changes, while long labels, affixes, hints, and errors remain readable at narrow widths? |
| [`table_metadata_visual_reference.html`](table_metadata_visual_reference.html) | Table metadata filter and cell editor lanes, including shared metadata source, `group_html:` wrapper boundaries, and responsibility boundaries | Can reviewers scan metadata-driven filter/editor examples, the host-app-owned shared source pattern, and group-level versus field-level wrapper boundaries without treating table persistence, query execution, layout framework choices, or future registry APIs as Rails Fields Kit responsibilities? |
| [`token_search_saved_search_visual_reference.html`](token_search_saved_search_visual_reference.html) | Saved-search token suggestions beside field and value completions, plus delimiter and multi-token wrapping states | Can reviewers distinguish saved search suggestions and wrapped token text without treating token parsing, search execution, or authorization as Rails Fields Kit responsibilities? |

## How to use this family

- For release verification, start from [`final_release_checklist.md`](final_release_checklist.md) and record manual evidence in [`sample_app_results.md`](sample_app_results.md) or the release PR comment when a release or PR changes the one-screen index or a visual reference artifact.
- For visual reference index readability, open [`visual_reference_index.html`](visual_reference_index.html) at desktop and narrow widths and confirm task picker cards, family cards, tags, artifact links, contract-reader links, and review-lane links remain readable before using it as the release or design-review entrypoint.
- For setup doctor output review, use [`setup_doctor_output_review.md`](setup_doctor_output_review.md) when the release or PR changes setup diagnostics or setup evidence. Treat it as a CLI diagnostic evidence lane, not a field UI visual reference or a source of runtime wording changes.
- For package-root contract reader review, first open [`public_api.md#javascript-exports`](public_api.md#javascript-exports) to confirm the current landed export and boundary, then use [`visual_reference_index.html`](visual_reference_index.html)'s contract-reader task to jump to the relevant rendered-state artifact.
- For shared metadata source pattern review, open [`shared_metadata_navigation.md`](shared_metadata_navigation.md) for the source-of-truth pattern, then inspect [`table_metadata_visual_reference.html`](table_metadata_visual_reference.html)'s shared source lane to confirm the visual boundary stays focused on derived current APIs rather than future registries or query execution.
- For table group wrapper review, open [`table_group_html.md`](table_group_html.md) for the helper boundary, then inspect [`table_metadata_visual_reference.html`](table_metadata_visual_reference.html)'s group wrapper lane to confirm group label, helper label, hint copy, group-level attributes, and field-level `wrapper_html:` stay readable and separate at desktop and narrow widths.
- For README first field quickstart review, open [`tom_select_visual_reference.html`](tom_select_visual_reference.html) and inspect the idle `rfk_select` / server-rendered collection lane before looking at remote combobox, preload, token search, or create-on-the-fly states.
- For selected preload restore or failure review, open [`tom_select_visual_reference.html`](tom_select_visual_reference.html) and inspect the `Selected Preload` and `Selected Preload Failure` lanes. Use the focused request-failure reference only when the review needs operation/status metadata or the `error_surface: true` slot.
- For Tom Select keyboard / focus review, open [`tom_select_visual_reference.html`](tom_select_visual_reference.html) and inspect the focus review lane in desktop and narrow viewport. It is a static readability check for focus ring, active option, selected item focus, label, hint, badge, and description density; it is not a runtime keyboard-behavior test.
- For grouped select review, open [`tom_select_visual_reference.html`](tom_select_visual_reference.html) and inspect the `Grouped Select` lane for optgroup heading readability, representative option labels, and the collection-backed boundary before looking at remote search or create-on-the-fly lanes.
- For explicit enum source and label fallback review, open [`tom_select_source_fallback_review.html`](tom_select_source_fallback_review.html) after checking [`enum_select.md`](enum_select.md) and [`controller_helpers.md#remote-option-label-fallback`](controller_helpers.md#remote-option-label-fallback). The artifact is a static visibility check for submitted-key source and display-only fallback, not a new API or endpoint behavior spec.
- For design review, start with [`visual_reference_index.html`](visual_reference_index.html) when you need to pick a lane. Use the helper-family picker for Tom Select-backed controls, native field wrappers, or table/token bridge questions, and use the task picker when the PR is primarily about release evidence, copy review, request-failure feedback, contract-reader review, or table/token ownership boundaries.
- For uppercase microcopy review, inspect tags, metadata chips, optgroup labels, and similar short labels at desktop and narrow widths. Avoid widened letter spacing unless it clearly improves scanning without making dense labels harder to read.
- For native helper accessibility-contract review, open [`native_field_visual_reference.html`](native_field_visual_reference.html), check the relevant wrapper / label / hint / error / generated-id lane in desktop and narrow viewport, then record the same lane name and viewport in [`sample_app_results.md`](sample_app_results.md) or the release PR comment.
- For native helper browser-semantics review, open [`native_field_visual_reference.html`](native_field_visual_reference.html) and inspect the Browser semantics lane for search, email, URL, telephone, money, and percent metadata boundaries before treating any formatting, validation, masking, or autocomplete behavior as helper-owned.
- For native helper wrapper review, use [`native_field_visual_reference.html`](native_field_visual_reference.html) to check label, hint, affix, required marker, validation, multiline textarea, noneditable, accessibility, browser semantics, generated-id, metadata and constraint attributes, and narrow viewport stress lanes without treating the static artifact as production CSS or runtime behavior.
- For native constraint attribute review, use [`native_field_visual_reference.html`](native_field_visual_reference.html) to verify that `maxlength`, `pattern`, `inputmode`, and `autocomplete` remain ordinary native attributes. Browser validation copy, masking, formatting, normalization, and autocomplete policy stay host-app responsibilities.
- For initializer-driven class review, use [`configuration_wrapper_class_visual_reference.html`](configuration_wrapper_class_visual_reference.html) during release or design review when the change touches configured wrapper, label, hint, error, control, prefix, or suffix classes. Check the default, host-app, validation, and narrow viewport lanes; record the lane and viewport in [`sample_app_results.md`](sample_app_results.md)'s visual reference render matrix or in the release PR comment, and keep the evidence focused on class pass-through rather than helper behavior or bundled CSS framework support.
- For request-failure feedback, use the index task picker or [`tom_select_request_failure_visual_reference.html`](tom_select_request_failure_visual_reference.html) to review the `error_surface: true` slot and operation/status metadata while keeping retry copy, reveal timing, and request lifecycle behavior with the host app.
- For table integration boundary checks, use the index family picker or task picker to choose between metadata-driven filters/editors, group wrapper boundaries, shared metadata source pattern, and saved-search token suggestion states.
- For token suggestion behavior, delimiter visibility, and saved-search option shape, use [`token_suggestions.md`](token_suggestions.md) as the source of truth and treat the saved-search visual reference as a static review artifact.
- If a new visual reference is added, update this map, the HTML index, and the README docs map after the reference lands on `main`.
- Do not use this index to document proposal-only helper names or unmerged feature lanes as current public API.

## Recording browser evidence

Use the evidence location that matches the scope of the visual change.

- Record release-wide or release-critical checks in [`sample_app_results.md`](sample_app_results.md), using the Visual reference render checks matrix when the changed artifact is part of release readiness.
- Record a small PR-level check in the PR comment when the change is a narrow static-docs update and the release evidence log is not being refreshed yet.
- Keep individual artifact screenshot, browser rendering, or redesign follow-ups in their own issue or PR instead of expanding this map into an approval workflow.

For each visual-reference evidence note, include at least the artifact, viewport, lane or state, responsibility boundary, result, and any blocker. If the run is connector-only and no browser screenshot is available, say what was checked instead, such as source review, CI, or a static render, and name the remaining human or browser-capable check rather than treating CI green as visual approval.

Use this short PR comment template when a visual reference change still needs browser-capable review:

```markdown
Visual reference evidence handoff

- Artifact: `doc/...html`
- Viewports: desktop ..., narrow ...
- Lane/state: ...
- Checked in this PR: source review / static render / CI / docs link review ...
- Not checked here: browser screenshot / real browser desktop / real browser narrow ...
- Remaining browser-capable check: ...
- Responsibility boundary: runtime behavior / production CSS / host-app copy remains out of scope
- Result or blocker: ...
```

Use the template to make the remaining review concrete. Do not paste it as a release approval when the browser pass was not actually run.
