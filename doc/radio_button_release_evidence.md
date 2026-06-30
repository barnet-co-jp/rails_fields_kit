# Radio Button Release Evidence

Use this guide when a release or narrow PR needs representative sample-app evidence for `rfk_radio_button`.

`rfk_radio_button` is a single-control native wrapper around Rails' standard `radio_button` helper. Evidence should prove the wrapper, label, hint, validation, and accessibility wiring around one radio option without turning Rails Fields Kit into a collection radio group or fieldset builder.

## When to Use This Lane

Use this lane when the release or PR changes one of these surfaces:

- `rfk_radio_button` helper behavior or docs
- native wrapper accessibility around radio inputs
- sample-app or release evidence for native wrapper helpers
- release notes that mention radio button wrapper support

For a narrow docs-only or spec-only PR, a PR comment is enough when it names the branch or commit, representative helper call, observed result, and any deferred browser/sample-app check. Use `doc/sample_app_results.md` for release candidates or release-wide evidence.

## Representative Check

Use one model-backed radio pair or small same-method set in a host app form. Keep the sample small enough that the evidence is about the wrapper lane, not an app-specific choice UI.

Record:

- the helper call, including the method and `tag_value`
- a checked state and an unchecked state for the same method
- the submitted value or Rails params shape observed by the host app
- label, hint, validation error, required state, and wrapper rendering when those pieces are in scope
- generated `aria-describedby`, `aria-invalid`, and `aria-required` wiring when accessibility remains enabled
- whether any custom `html:` or `label_html:` options were used

## Boundary Checks

Confirm the evidence stays inside the current helper boundary:

- `tag_value` is ordinary Rails radio value evidence, not a new label/value DSL
- same-name grouping behavior remains Rails standard radio behavior
- collection iteration, fieldset / legend markup, group-level validation UI, and layout policy stay in the host app
- production CSS, final spacing, and browser-specific visual approval stay outside this guide unless a visual reference PR explicitly asks for browser evidence
- authorization, persistence, query semantics, and business-specific state policy remain host-app responsibilities

## Example Evidence Note

```text
Radio button wrapper lane checked on <branch-or-commit>.
Representative helper: f.rfk_radio_button :status, "published", wrapper: true, label: "Published", hint: "Visible after publishing".
Checked / unchecked states rendered with Rails radio names and value-specific ids. Hint and validation error ids fed aria-describedby while accessibility remained enabled.
Same-name grouping stayed Rails-owned; collection groups, fieldsets, legend builders, group validation UI, and production CSS were out of scope.
Result: PASS / SOURCE REVIEW ONLY / DEFERRED <reason>.
```

Use `SOURCE REVIEW ONLY` when the helper call and docs were reviewed without running a sample app. Use `DEFERRED` when browser or sample-app evidence is intentionally handed off to a release reviewer.
