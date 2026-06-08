# Package-root helper release evidence

Use this focused evidence guide when a release or narrow PR needs sample-app proof for read-only package-root helper exports. Record the final pass/fail evidence in `doc/sample_app_results.md`, a release PR comment, or a scoped PR comment; this page only defines the representative checks.

Use `doc/public_api.md#javascript-exports` as the source of truth for the current package-root helper list, helper names, and documented return-shape boundaries. This guide should not duplicate every helper's full return shape; it helps reviewers choose representative import and rendered-field inspection lanes for the helpers that are actually in release or PR scope.

These checks cover helper import and rendered-field inspection. They do not make Rails Fields Kit responsible for request execution, endpoint authorization, retry UI, locale policy, visible copy, or host-app fallback behavior.

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

Check one rendered Tom Select-backed field that uses `allow_clear: true` and, when the release scope includes explicit plugin overrides, one comparable field that renders `plugins:` explicitly:

- `tomSelectPluginContract(fieldElement)` returns a plain object for a Rails Fields Kit Tom Select field.
- The result exposes the documented `plugins` array for the representative field.
- A field with `allow_clear: true` reports a `clear_button` plugin signal through the documented clearable flag.
- A field with explicit `plugins:` reports the rendered effective plugin list without treating the host app's plugin choices as Rails Fields Kit-owned behavior.
- A comparable non-Tom Select or unrelated element returns `null`.
- The evidence stays read-only; plugin asset installation, clear/remove affordance styling, selection mutation, empty-state copy, Tom Select plugin objects, and Tom Select instance lifecycle remain outside this helper evidence lane.

Suggested evidence note:

```text
tomSelectPluginContract: PASS on <field selector>. plugins matched the rendered effective plugin list; allow_clear field exposed the documented clear_button / clearable signal; unrelated element returned null. Plugin assets, styling, mutation, empty-state copy, and Tom Select plugin lifecycle remained host-app or Tom Select responsibilities.
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

## Evidence placement

For release candidates, record the checked helper lanes in `doc/sample_app_results.md` under JavaScript setup checks and the relevant behavior lane. For narrow PRs, a PR comment is enough when it includes:

- helper name
- branch or commit SHA
- sample app setup route, such as esbuild, jsbundling-rails, or importmap
- representative field selector or description
- pass/fail result
- any intentionally deferred host-app responsibility boundary

Do not copy this whole guide into release notes. Link to this page or summarize only the checked helper lanes.
