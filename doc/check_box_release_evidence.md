# Checkbox Release Evidence

Use this guide when a release candidate or narrow PR needs sample-app evidence for `rfk_check_box` after the focused helper docs and specs have already landed.

`rfk_check_box` is a single native checkbox wrapper. Keep this evidence lane tied to Rails' standard checkbox contract plus Rails Fields Kit wrapper/accessibility wiring. Do not use it to introduce collection checkbox groups, radio buttons, validation UI policy, label placement redesign, or production CSS decisions.

## When To Record Evidence

Record evidence in `sample_app_results.md` when the release candidate depends on checkbox wrapper behavior or when a release PR needs a checkbox-specific native helper lane.

For a narrow docs/spec PR, a PR comment is enough when it names the checked source, branch or commit, and whether this lane was included, deferred, or out of scope.

## Representative Sample App Check

Use one model-backed boolean or enum-like checkbox field and render it with `wrapper: true`.

Confirm the representative field keeps this boundary:

- a hidden unchecked input is still rendered through Rails' ordinary `check_box` contract
- the visible checkbox uses the requested checked and unchecked values, including custom `checked_value:` and `unchecked_value:` when those are in scope
- model-backed checked state renders as checked or unchecked without Rails Fields Kit replacing Rails' state decision
- label, hint, error, wrapper, and generated `aria-describedby` wiring remain readable through an initial render and validation rerender
- `accessibility: false` remains an opt-out from automatic aria wiring only, not from the checkbox submission contract
- ordinary checkbox options such as `disabled:`, `required:`, `data:`, and `id:` still pass through to the input when supplied by the host app

## Evidence Note Template

Use this shape in `sample_app_results.md` or a PR comment:

```markdown
Checkbox release evidence:
- Source: `doc/check_box.md` / `doc/check_box_release_evidence.md`
- Representative field:
- Branch or commit:
- Result: PASS / DEFERRED / OUT OF SCOPE
- Checked: hidden unchecked input, checked/unchecked values, wrapper label/hint/error, validation rerender, accessibility boundary
- Notes: radio buttons, collection groups, validation UI, production CSS, and final copy remain out of scope
```

## Out Of Scope

Keep these surfaces outside this evidence lane unless a separate planned issue explicitly adds them:

- `rfk_radio_button`
- collection checkbox or radio group DSLs
- fieldset / legend builders
- checkbox validation policy or final visible validation copy
- label placement redesign
- visual reference artifacts
- production CSS or design-system approval
