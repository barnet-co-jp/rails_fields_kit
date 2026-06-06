# Native field accessibility contract release gate

Use this focused release-gate lane when a release or pull request touches native helper wrapper, accessibility wiring, or package-root JavaScript export verification.

This check is sample-app evidence, not a new runtime contract. Keep it aligned with `doc/public_api.md#javascript-exports`, `doc/field_helpers.md`, `doc/sample_app_checklist.md`, and `doc/sample_app_results.md`.

## Scope

Verify the current package-root helper export:

```js
import { nativeFieldAccessibilityContract } from "rails_fields_kit"
```

The helper reads rendered native helper wiring only. It must not mutate IDs, ARIA attributes, validation copy, focus behavior, or visible feedback. Rails Fields Kit owns the wrapper / automatic accessibility wiring only when the helper lane opts into it; the host app continues to own validation copy, business semantics, and final visual styling.

## Representative sample-app check

Create or reuse one representative native helper field such as `rfk_text_field` or `rfk_money_field` with `wrapper: true`, a label, hint, and validation-error state.

Record evidence for these checks in `doc/sample_app_results.md` or the release PR comment:

- [ ] the sample app resolves `nativeFieldAccessibilityContract` from `rails_fields_kit`, not from an app-private source path
- [ ] the representative wrapped native field returns a non-null contract object
- [ ] `contract.describedByIds` includes the rendered hint and validation-error IDs when those elements are present
- [ ] `contract.hintElement` points at the rendered hint element, when a hint is present
- [ ] `contract.errorElement` points at the rendered validation-error element, when an error is present
- [ ] `contract.wrapperElement` points at the generated native helper wrapper element
- [ ] a comparable element that is not a Rails Fields Kit native helper field returns `null`
- [ ] a comparable `accessibility: false` native helper field clearly drops the automatic accessibility wiring while keeping wrapper rendering behavior scoped to the documented opt-out lane

## Non-goals

Do not use this lane to change native helper markup, add browser automation, introduce screenshot approval, or turn host-app validation / focus / business semantics into Rails Fields Kit responsibilities.
