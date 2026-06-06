# Package-root helper release evidence

Use this focused evidence guide when a release or narrow PR needs sample-app proof for read-only package-root helper exports. Record the final pass/fail evidence in `doc/sample_app_results.md`, a release PR comment, or a scoped PR comment; this page only defines the representative checks.

These checks cover helper import and rendered-field inspection. They do not make Rails Fields Kit responsible for request execution, endpoint authorization, retry UI, locale policy, visible copy, or host-app fallback behavior.

## Shared setup

Use a sample Rails app that already passes the JavaScript setup lane from `doc/sample_app_checklist.md`:

- Tom Select is installed through the host app package manager or importmap setup.
- `TomSelectController` resolves from `rails_fields_kit`.
- `rails_fields_kit/tom_select_controller` resolves when the direct controller entrypoint is part of the check.
- The sample app registers the controller on its existing Stimulus application.
- Tom Select CSS is loaded by the host app.

When recording evidence, include the branch or commit SHA, the sample app JavaScript setup route, the helper import statement, and the representative field or DOM selector used for the check.

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

## Evidence placement

For release candidates, record the checked helper lanes in `doc/sample_app_results.md` under JavaScript setup checks and the relevant behavior lane. For narrow PRs, a PR comment is enough when it includes:

- helper name
- branch or commit SHA
- sample app setup route, such as esbuild, jsbundling-rails, or importmap
- representative field selector or description
- pass/fail result
- any intentionally deferred host-app responsibility boundary

Do not copy this whole guide into release notes. Link to this page or summarize only the checked helper lanes.