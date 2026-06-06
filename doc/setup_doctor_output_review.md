# Setup Doctor Output Review

Use this focused docs/design artifact when a release or PR changes setup doctor diagnostics, setup evidence, or generated setup notes. This artifact is not production UI and does not define setup doctor runtime behavior. It gives reviewers a stable way to scan representative CLI output states without mixing them into field visual references.

## Scope

- Review the readability of representative setup doctor output states.
- Confirm that `[OK]`, `[MISSING]`, and `[MANUAL]` lines are easy to scan as diagnostic evidence.
- Confirm that importmap target mismatch output is readable after the target-drift diagnostic landed.
- Keep command behavior, wording source, host app setup policy, and auto-fix decisions outside this artifact.

## Representative Output States

```text
rails rails_fields_kit:doctor

[OK] initializer found at config/initializers/rails_fields_kit.rb
[OK] importmap pin rails_fields_kit -> rails_fields_kit/index.js
[MISSING] importmap pin rails_fields_kit/tom_select_controller was not found
[MANUAL] confirm Tom Select package installation when using jsbundling or bundler-managed JavaScript
[MANUAL] confirm Stimulus registration in the host app controller index
```

Review notes:

- `[OK]` means the doctor could read the expected setup signal.
- `[MISSING]` means the doctor could not find an expected setup signal for the detected route.
- `[MANUAL]` means the doctor cannot safely verify the host app decision automatically; it is not a hard failure by itself.
- Bundler-only apps can have manual JavaScript checks without implying an importmap failure.

## Importmap Target Mismatch

```text
rails rails_fields_kit:doctor

[MISSING] importmap pin rails_fields_kit expected target rails_fields_kit/index.js but found rails_fields_kit
[MISSING] importmap pin rails_fields_kit/tom_select_controller expected target rails_fields_kit/tom_select_controller.js but found no explicit target
[MANUAL] confirm CSS import path in the host app stylesheet or bundler entrypoint
```

Review notes:

- Target mismatch evidence should show the expected target and the observed target in the same line.
- `no explicit target` should read as a concrete diagnostic, not as an empty or crashed state.
- CSS import and bundler alias checks remain host-app responsibilities unless a future issue explicitly changes the doctor behavior.

## Narrow Evidence Checklist

Use this checklist when recording release or PR evidence:

- [ ] `[OK]`, `[MISSING]`, and `[MANUAL]` labels are visually easy to distinguish in the recorded output.
- [ ] Missing importmap target output includes both expected and observed target values.
- [ ] Manual checklist lines are not described as failed automatic checks.
- [ ] Evidence notes say whether the app under review is importmap, jsbundling, bundler-managed JavaScript, or another setup path.
- [ ] Any deferred follow-up is recorded as docs/setup policy work, not as a visual reference failure.

## Non-goals

- Do not change setup doctor runtime behavior or output wording here.
- Do not introduce a terminal UI framework.
- Do not add a browser-based setup checker.
- Do not define host app setup policy, auto-fix behavior, or bundler/importmap ownership.
