# Package-root helper release evidence

Use this focused evidence guide when a release or narrow PR needs sample-app proof for read-only package-root helper exports. Record the final pass/fail evidence in `doc/sample_app_results.md`, a release PR comment, or a scoped PR comment; this page only defines the representative checks.

Use `doc/public_api.md#javascript-exports` as the source of truth for the current package-root helper list, helper names, and documented return-shape boundaries. This guide should not duplicate every helper's full return shape; it helps reviewers choose representative import and rendered-field inspection lanes for the helpers that are actually in release or PR scope.

These checks cover helper import and rendered-field inspection. They do not make Rails Fields Kit responsible for request execution, endpoint authorization, retry UI, locale policy, visible copy, or host-app fallback behavior.

## Guard family map

Package-root helper evidence is intentionally split across a small docs and smoke family instead of a machine-readable public API manifest. For the current RFK surface, this keeps the helper contract readable without adopting TreeView's manifest model or a cross-gem schema before the package-root helper family needs it.

| Guard | Owns | Does not own |
| --- | --- | --- |
| `doc/public_api.md#javascript-exports` | Current package-root export names, helper kind, import examples, and documented return-shape / responsibility boundaries. | Release pass/fail notes, sample-app screenshots, downstream host-app smoke, or proposal/open-PR helper names. |
| `scripts/check_package_exports.mjs` via `npm run check:js` | Importability and callable smoke for the current exports derived from the public API table, plus targeted helper smokes when a generic callable check is not enough to protect the documented boundary. | Runtime request execution, endpoint authorization, visible feedback, or sample-app release evidence. |
| This guide and `doc/sample_app_results.md` | Which current helpers need representative release or PR evidence, where that evidence was checked, and which host-app responsibilities were intentionally left out of scope. | The canonical helper list or a full mirror of every helper return shape. |
| `spec/package_contents_spec.rb` and package inventory docs | Packaged docs, generated setup notes, visual references, and entrypoint visibility staying reachable from the maintained docs family. | Package-root helper return-shape decisions or helper-specific runtime behavior. |

When adding or changing a package-root helper, update the public API table first, keep the package export smoke aligned with that table, then choose whether this guide or a scoped PR comment needs representative sample-app evidence. If a helper is still only proposed or present on an open branch, do not list it here as current release evidence.

## Shared setup

Use a sample Rails app that already passes the JavaScript setup lane from `doc/sample_app_checklist.md`:

- Tom Select is installed through the host app package manager or importmap setup.
- `TomSelectController` resolves from `rails_fields_kit`.
- `rails_fields_kit/tom_select_controller` resolves when the direct controller entrypoint is part of the check.
- The sample app registers the controller on its existing Stimulus application.
- Tom Select CSS is loaded by the host app.

When recording evidence, include the branch or commit SHA, the sample app JavaScript setup route, the helper import statement, and the representative field or DOM selector used for the check.

## Choosing helper lanes

For each release or narrow PR, choose only the package-root helper lanes that are in scope for that change. Record skipped helpers as out of scope rather than as failures. When a helper is newly added or its public return shape changes, confirm the public API table first, then record sample-app evidence for the representative rendered field used by that helper.

Use existing helper-specific sections below when they match the scoped helper. For other current helpers listed in `doc/public_api.md#javascript-exports`, record the same minimal evidence shape:

- package-root import resolves from `rails_fields_kit`
- the helper returns the documented plain-object contract for a representative Rails Fields Kit-rendered field
- a comparable non-target or unsupported element returns `null` when that is the documented boundary
- request execution, visible copy, locale policy, mutation, validation, and retry behavior remain outside the helper evidence lane unless another release checklist section explicitly covers them

## Placement checklist for new or changed helpers

Use this checklist before adding or changing package-root helper docs. It keeps the helper list centralized while making the review and release evidence easy to find.

- Start from `doc/public_api.md#javascript-exports` when the helper name, kind, import pattern, or return-shape boundary changes. That table remains the reader-facing source of truth for current exports.
- Keep `scripts/check_package_exports.mjs` and the `npm run check:js` package export smoke aligned when the public API table gains, renames, or removes a package-root export. Add helper-specific smoke only when the generic import and callable checks are not enough to protect the documented boundary.
- Keep README examples representative. The README should link to `doc/public_api.md#javascript-exports` for the full helper list and should not become an exhaustive helper inventory.
- Use this guide only for release or sample-app evidence lanes. Add a helper-specific section when repeatable evidence is useful; otherwise a scoped PR comment or `doc/sample_app_results.md` note is enough.
- Use `doc/visual_references.md` and `doc/visual_reference_index.html` as task or family routes, not as another copy of the current helper inventory. Link to the relevant rendered-state artifact when visual review is in scope.
- Keep individual topic docs responsible for the domain boundary, such as selected preload, request params, text overrides, plugin state, native accessibility, or password-field non-goals. This guide should point to those boundaries rather than restating full examples.
- Do not document open-PR helper names, proposal names, or roadmap-only helpers as current release evidence. Wait until the helper lands on `main` and appears in the public API table.
- If the change needs runtime behavior, a new helper export, a return-shape decision, or a package metadata guard, split that work into the appropriate feature or quality track. This page should stay docs-only.

## When to add a helper-specific section

Add a dedicated section to this guide only when a current public helper needs repeatable release evidence beyond the generic shape above. Good reasons include:

- the helper was added to `doc/public_api.md#javascript-exports` and is part of the release or PR scope
- the helper's documented return shape changed and reviewers need a stable sample-app evidence note
- repeated release reviews need the same representative field, non-target boundary, or host-app responsibility wording
- the helper needs evidence in `doc/sample_app_results.md` or a release PR comment that is easy to compare across releases

Do not add helper-specific sections for open PR helpers, proposal names, or roadmap-only helpers. If a helper exists only on an open branch, leave this guide pointed at the current public API table and add the section only after the helper lands on `main` and belongs to the release or narrow PR scope.

When adding a helper-specific section, keep the section narrow:

- name the helper exactly as documented in `doc/public_api.md#javascript-exports`
- describe representative import and rendered-field inspection, not every field variant
- link or point back to `doc/public_api.md` for the full helper list and return-shape source of truth
- keep request execution, visible feedback, locale policy, mutation, validation, authorization, and retry behavior outside this guide unless another release checklist section explicitly owns that behavior
- avoid mirroring release notes, changelog entries, or sample app results; record final evidence in those files or comments instead

## Selected preload config reader

Use this lane when `readRenderedSelectedPreloadConfig(element)` is in release scope.

Representative import:

```js
import { readRenderedSelectedPreloadConfig } from "rails_fields_kit"
```

Check a rendered Tom Select-backed field that uses `selected_url:`:

- `readRenderedSelectedPreloadConfig(fieldElement)` returns a plain object.
- The result includes the documented `selectedUrl` value for the field.
- The result includes `selectedParam` and `selectedMultipleParam`, including any custom param names used by the representative field.
- The result includes `selectedQueryParams` when the field renders fixed selected preload query params.
- A comparable Rails Fields Kit field without `selected_url:` returns `null`.
- The evidence stays limited to rendered config inspection; selected preload request execution is covered by the selected preload lane in `doc/sample_app_results.md`.

Suggested evidence note:

```text
readRenderedSelectedPreloadConfig: PASS on <field selector>. selectedUrl / selectedParam / selectedMultipleParam / selectedQueryParams matched rendered config; comparable no-selected-url field returned null. Request execution and fallback UI were checked separately or left out of scope.
```

## Tom Select interaction config reader

Use this lane when `readRenderedTomSelectInteractionConfig(element)` is in release scope.

Representative import:

```js
import { readRenderedTomSelectInteractionConfig } from "rails_fields_kit"
```

Check a rendered Tom Select-backed field that customizes interaction configuration:

- `readRenderedTomSelectInteractionConfig(fieldElement)` returns a plain object for a Rails Fields Kit Tom Select field.
- The result exposes representative rendered values such as `maxOptions`, `maxItems`, `loadThrottle`, `delimiter`, `dropdownParent`, `preload`, `openOnFocus`, `closeAfterSelect`, `hideSelected`, and `persist` according to the field under review.
- Numeric values remain numeric-or-null, string values remain string-or-null, and boolean values remain boolean-or-null except `persist`, which follows the documented boolean default.
- A default or minimally configured field reports the documented null/default boundaries instead of inventing app policy.
- A comparable non-Tom Select or unrelated element returns `null`.
- The evidence stays read-only; Tom Select initialization, request execution, modal / drawer / portal layout, z-index policy, interaction policy, and production CSS remain outside this helper evidence lane.

Suggested evidence note:

```text
readRenderedTomSelectInteractionConfig: PASS on <field selector>. maxOptions / maxItems / loadThrottle / delimiter / dropdownParent / preload / openOnFocus / closeAfterSelect / hideSelected / persist matched rendered interaction config; default and unrelated-element boundaries matched the public API docs. Tom Select initialization, request execution, modal layout, z-index policy, interaction policy, and production CSS remained out of scope.
```

## Option payload mapping reader

Use this lane when `readRenderedOptionPayloadMapping(element)` is in release scope.

Representative import:

```js
import { readRenderedOptionPayloadMapping } from "rails_fields_kit"
```

Check a rendered Tom Select-backed field that customizes option payload fields:

- `readRenderedOptionPayloadMapping(fieldElement)` returns a plain object for a Rails Fields Kit Tom Select field.
- The result exposes the documented `valueField`, `labelField`, split `searchFields`, `optionDescriptionField`, and `optionBadgeField` values for the representative field.
- A default-mapping field reports the documented fallback values.
- A comparable non-Tom Select or unrelated element returns `null`.
- The evidence stays read-only; endpoint execution, response validation, option rendering HTML, authorization, mutation, and visible feedback remain outside this helper evidence lane.

Suggested evidence note:

```text
readRenderedOptionPayloadMapping: PASS on <field selector>. valueField / labelField / searchFields / optionDescriptionField / optionBadgeField matched rendered config; default and unrelated-element boundaries matched the public API docs. Endpoint execution, response validation, option rendering HTML, authorization, mutation, and visible feedback remained out of scope.
```

## Table filter metadata reader

Use this lane when `readRenderedTableFilterMetadata(element)` is in release scope.

Representative import:

```js
import { readRenderedTableFilterMetadata } from "rails_fields_kit"
```

Check a rendered table filter metadata lane, such as a token-search or Ransack-oriented filter field produced from Rails Fields Kit table metadata:

- `readRenderedTableFilterMetadata(fieldElement)` returns a plain object only for an element that carries the rendered table filter metadata attributes.
- The result exposes the documented `adapter`, `paramName`, and `fields` values for the representative table filter field.
- The `fields` value is treated as rendered metadata, not as a query parser, execution plan, authorization policy, or table persistence contract.
- A comparable Rails Fields Kit field without table filter metadata, or an unrelated element, returns `null`.
- The evidence stays read-only; Ransack execution, token parsing, table query behavior, filter persistence, endpoint behavior, and visible feedback remain outside this helper evidence lane.

Suggested evidence note:

```text
readRenderedTableFilterMetadata: PASS on <field selector>. adapter / paramName / fields matched the rendered table filter metadata for the representative field; no-metadata and unrelated elements returned null. Ransack execution, token parsing, table query behavior, filter persistence, endpoint behavior, and visible feedback remained out of scope.
```

## Text override contract reader

Use this lane when `tomSelectTextOverrideContract(element)` is in release scope.

Representative import:

```js
import { tomSelectTextOverrideContract } from "rails_fields_kit"
```

Check a rendered Tom Select-backed field with text override options:

- `tomSelectTextOverrideContract(fieldElement)` returns a plain object for a Rails Fields Kit field.
- The result exposes the documented `noResultsText`, `loadingText`, and `createText` values for the representative field.
- A fallback or default field confirms the helper can read the rendered fallback contract without requiring a visual-reference-only page.
- A non-Rails Fields Kit element returns `null`.
- The evidence stays read-only; visible copy quality, locale resolution, and final user-facing wording remain host-app or product review responsibilities.

Suggested evidence note:

```text
tomSelectTextOverrideContract: PASS on <field selector>. noResultsText / loadingText / createText matched rendered field values; fallback field was readable; unrelated element returned null. Visible copy and locale policy remain host-app review items.
```

## Tom Select plugin contract reader

Use this lane when `tomSelectPluginContract(element)` is in release scope.

Representative import:

```js
import { tomSelectPluginContract } from "rails_fields_kit"
```

The package-root import remains the normal release evidence route. When a narrow PR or release specifically includes the direct helper subpath from `doc/public_api.md#javascript-exports`, add a second import check in the same helper lane rather than creating a separate release gate:

```js
import tomSelectPluginContractFromSubpath from "rails_fields_kit/tom_select_plugin_contract"
```

That direct-subpath check should only confirm that the same representative field reaches the same read-only helper route. Record it in the helper row in `doc/sample_app_results.md` or in a scoped PR comment, and do not expand the evidence into plugin assets, clear/remove styling, selection mutation, Tom Select lifecycle, or browser visual approval.

Check one rendered Tom Select-backed field that uses `allow_clear: true` and, when the release scope includes explicit plugin overrides, one comparable field that renders `plugins:` explicitly:

- `tomSelectPluginContract(fieldElement)` returns a plain object for a Rails Fields Kit Tom Select field.
- The result exposes the documented `plugins` array for the representative field.
- A field with `allow_clear: true` reports `clear_button` in the documented `plugins` array and sets the documented `hasClearButton` flag.
- A field with explicit `plugins:` reports the rendered effective plugin list and derived `hasClearButton` / `hasRemoveButton` flags without treating the host app's plugin choices as Rails Fields Kit-owned behavior.
- A comparable non-Tom Select or unrelated element returns `null`.
- If the direct helper subpath is in scope, the direct import resolves and returns the same documented read-only result for the representative field.
- The evidence stays read-only; plugin asset installation, clear/remove affordance styling, selection mutation, empty-state copy, Tom Select plugin objects, and Tom Select instance lifecycle remain outside this helper evidence lane.

Suggested evidence note:

```text
tomSelectPluginContract: PASS on <field selector>. Package-root import returned the documented plugins / hasClearButton / hasRemoveButton contract; direct subpath import returned the same read-only result when that route was in scope; unrelated element returned null. Plugin assets, styling, mutation, empty-state copy, and Tom Select plugin lifecycle remained host-app or Tom Select responsibilities.
```

## Tom Select selection contract reader

Use this lane when `tomSelectSelectionContract(element)` is in release scope.

Representative import:

```js
import { tomSelectSelectionContract } from "rails_fields_kit"
```

Check an initialized rendered Tom Select-backed field after the controller has connected:

- `tomSelectSelectionContract(fieldElement)` returns a plain object for an initialized Rails Fields Kit Tom Select field.
- The result exposes the documented `values` array using the current selection shape shared with forwarded interaction events.
- A single-value field, multiple-value field, or cleared field should match the representative release scope rather than exhaustively testing every Tom Select mode.
- A comparable uninitialized, non-Tom Select, or unrelated element returns `null`.
- The evidence stays read-only; selection mutation, hidden field generation, event dispatch, validation feedback, request execution, and Tom Select instance lifecycle remain outside this helper evidence lane.

Suggested evidence note:

```text
tomSelectSelectionContract: PASS on <field selector>. values matched the initialized field's current selection; unrelated or uninitialized element returned null. Selection mutation, hidden fields, events, validation feedback, and request execution remained out of scope.
```

## Tom Select request contract reader

Use this lane when `tomSelectRequestContract(element)` is in release scope.

Representative import:

```js
import { tomSelectRequestContract } from "rails_fields_kit"
```

Check rendered Tom Select-backed fields that cover remote search, selected preload, and create-on-the-fly request configuration when those lanes are in the PR or release scope:

- `tomSelectRequestContract(fieldElement)` returns a plain object for a Rails Fields Kit Tom Select field.
- The result exposes the documented remote search, selected preload, and create endpoint flags and URLs for the representative fields.
- The result exposes the documented request param names, `minLength`, and `errorSurfaceId` values rendered for the field.
- A comparable Tom Select-backed field without optional request lanes reports the documented default values.
- A comparable non-Tom Select or unrelated element returns `null`.
- The evidence stays read-only; request execution, query parsing, authorization, retry UI, visible feedback, fixed params parsing, and Tom Select controller lifecycle remain outside this helper evidence lane.

Suggested evidence note:

```text
tomSelectRequestContract: PASS on <field selector>. remote search / selected preload / create endpoint flags and URLs, param names, minLength, and errorSurfaceId matched the rendered field contract; default/no-request and unrelated elements returned the documented boundaries. Request execution, authorization, retry UI, visible feedback, fixed params parsing, and controller lifecycle remained out of scope.
```

## Error surface reader

Use this lane when `readRenderedErrorSurface(element)` is in release scope.

Representative import:

```js
import { readRenderedErrorSurface } from "rails_fields_kit"
```

The package-root import remains the normal release evidence route. When a narrow PR or release specifically includes the direct helper subpath from `doc/public_api.md#javascript-exports`, add a second import check in this same helper lane rather than creating a separate release gate:

```js
import readRenderedErrorSurfaceFromSubpath from "rails_fields_kit/read_rendered_error_surface"
```

That direct-subpath check should only confirm that the same representative opt-in field reaches the same read-only helper route. Record it in the helper row in `doc/sample_app_results.md` or in a scoped PR comment, and do not expand the evidence into request execution, visible feedback copy, retry UI, event payload redesign, or host-app fallback rendering.

Check a rendered Tom Select-backed field that opts into `error_surface:`:

- `readRenderedErrorSurface(fieldElement)` returns the rendered placeholder element for a Rails Fields Kit field with an `errorSurfaceId` value.
- The returned element id matches the documented `errorSurfaceId` surfaced through `tomSelectRequestContract(element)` for the same field.
- A comparable Rails Fields Kit field without `error_surface:` returns `null`.
- A field whose rendered placeholder is missing returns `null` rather than creating or mutating visible feedback.
- If the direct helper subpath is in scope, the direct import resolves and returns the same documented read-only result for the representative field.
- The evidence stays read-only; request execution, retry UI, visible copy, validation policy, authorization, mutation, and fallback rendering remain host-app responsibilities.

Suggested evidence note:

```text
readRenderedErrorSurface: PASS on <field selector>. Package-root import returned the rendered opt-in placeholder matching the field errorSurfaceId; direct subpath import returned the same read-only result when that route was in scope; no-surface and missing-placeholder cases returned null. Request execution, retry UI, visible copy, validation policy, authorization, mutation, and fallback rendering remained out of scope.
```

## Native accessibility contract reader

Use this lane when `nativeFieldAccessibilityContract(element)` is in release scope.

Representative import:

```js
import { nativeFieldAccessibilityContract } from "rails_fields_kit"
```

Check a representative Rails Fields Kit-rendered native helper field, such as `rfk_text_field` or `rfk_money_field`, with the shared wrapper and accessibility wiring enabled:

- `nativeFieldAccessibilityContract(fieldElement)` returns a plain object for the rendered native input.
- The result confirms the documented label, hint, error, wrapper, and `describedByIds` wiring for the representative field.
- A comparable unsupported element or non-native Rails Fields Kit target returns `null` when that is the documented boundary.
- The evidence stays read-only; the helper only inspects rendered wiring and does not mutate labels, ids, focus behavior, validation messages, wrapper classes, or visible fallback UI.
- Host apps still own focus management, validation policy, user-facing validation copy, browser validation behavior, and any accessibility review beyond the rendered contract inspection.

Suggested evidence note:

```text
nativeFieldAccessibilityContract: PASS on <field selector>. label / hint / error / wrapper / describedByIds matched the rendered native helper contract; unsupported element returned null. Focus management, validation policy, and visible copy remained host-app review items.
```

## Native constraint contract reader

Use this lane when `nativeFieldConstraintContract(element)` is in release scope.

Representative import: use the package-root helper named `nativeFieldConstraintContract` from `rails_fields_kit`, matching the import pattern documented in `doc/public_api.md#javascript-exports`.

Check a representative Rails Fields Kit-rendered native helper field, such as `rfk_text_field`, `rfk_search_field`, or `rfk_text_area`, with ordinary native constraint attributes rendered:

- `nativeFieldConstraintContract(fieldElement)` returns a plain object for the rendered native input, select, or textarea.
- The result confirms representative string-or-null attribute reads for `maxLength`, `minLength`, `pattern`, `autocomplete`, and `inputMode` according to the field under review.
- A comparable field without one of those attributes returns `null` for the absent attribute instead of normalizing or inventing a default.
- A comparable unsupported element or non-native Rails Fields Kit target returns `null` when that is the documented boundary.
- The evidence stays read-only; the helper only inspects rendered HTML attributes and does not mutate attributes, run validation, normalize numeric limits, apply masking or formatting, decide autocomplete policy, or create visible feedback.
- Host apps still own browser validation messages, validation policy, masking, formatting, normalization, autocomplete policy, and any user-facing copy around constraint failures.

Suggested evidence note:

```text
nativeFieldConstraintContract: PASS on <field selector>. maxLength / minLength / pattern / autocomplete / inputMode matched the rendered native helper attributes with absent values returning null; unsupported element returned null. Validation messages, masking, formatting, normalization, autocomplete policy, and visible copy remained host-app responsibilities.
```

## Evidence placement

For release candidates, record the checked helper lanes in `doc/sample_app_results.md` under JavaScript setup checks and the relevant behavior lane. For narrow PRs, a PR comment is enough when it includes:

- helper name
- branch or commit SHA
- sample app setup route, such as esbuild, jsbundling-rails, or importmap
- representative field selector or description
- pass/fail result
- any intentionally deferred host-app responsibility boundary

Do not copy this whole guide into release notes. Link to this page or summarize only the checked helper lanes.
