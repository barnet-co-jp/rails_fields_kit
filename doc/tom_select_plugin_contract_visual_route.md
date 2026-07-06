# Tom Select plugin contract visual route

Use this note when a review asks how `tomSelectPluginContract(element)` relates to the Tom Select clear / remove visual references. It is a static docs route only; it does not change runtime JavaScript behavior, package exports, plugin behavior, or the visual artifact itself.

## Source of truth

Start from [`public_api.md#javascript-exports`](public_api.md#javascript-exports). The public API table is the source of truth for the current helper name, return shape, and responsibility boundary.

For `tomSelectPluginContract(element)`, the public contract is read-only:

- it reads the rendered effective plugin list
- it reports `hasClearButton` and `hasRemoveButton`
- it returns `null` when the element is not a matching Rails Fields Kit field
- it does not install plugin assets, expose Tom Select plugin objects, mutate selections, style controls, or own empty-state behavior

## Nearest visual lane

Use [`tom_select_plugin_clearable_review.html`](tom_select_plugin_clearable_review.html) only as the nearest landed visual lane for clear / remove affordance context. That artifact helps reviewers compare:

- a single-select whole-field clear affordance
- multi-item remove buttons
- visible boundaries around plugin assets, styling, event payloads, selection mutation, and Tom Select lifecycle behavior

Do not treat the clearable review artifact as the JavaScript contract-reader inventory. It is not the source of truth for helper names, return shapes, direct helper subpaths, package metadata, or TypeScript declarations.

## Review route

1. Confirm the current export and return-shape boundary in [`public_api.md#javascript-exports`](public_api.md#javascript-exports).
2. If the review needs rendered affordance context, open [`tom_select_plugin_clearable_review.html`](tom_select_plugin_clearable_review.html).
3. Keep plugin assets, styling approval, selection mutation, Tom Select lifecycle behavior, and browser visual approval out of the contract-reader decision unless a separate issue explicitly asks for them.

## Why this stays out of the index inventory

[`visual_reference_index.html`](visual_reference_index.html) should keep routing reviewers by task and nearest landed lane. It should not copy the full package-root helper inventory or list proposal-only helper names. This note keeps the `tomSelectPluginContract(element)` route discoverable without turning the one-screen index into a JavaScript API mirror.
