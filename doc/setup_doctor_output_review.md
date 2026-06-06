# Setup Doctor Output Review

Use this focused docs/design artifact when a release or PR changes setup doctor diagnostics, setup evidence, or generated setup notes. This artifact is not production UI and does not define setup doctor runtime behavior. It gives reviewers a stable way to scan representative CLI output states without mixing them into field visual references.

## Scope

- Review the readability of representative setup doctor output states.
- Confirm that `[OK]`, `[MISSING]`, and `[MANUAL]` lines are easy to scan as diagnostic evidence.
- Confirm that importmap target mismatch output is readable after the target-drift diagnostic landed.
- Keep command behavior, wording source, host app setup policy, and auto-fix decisions outside this artifact.

## Release Evidence Handoff

Use this artifact as the review aid for setup doctor evidence, then record the release result in the sample app evidence flow rather than duplicating the full CLI output in every PR.

- Use `doc/sample_app_checklist.md` to decide whether setup doctor evidence belongs in the release baseline or the host-app setup lane.
- Record release-wide results in `doc/sample_app_results.md` under `Setup doctor checks`, including the app setup path: importmap, jsbundling, bundler-managed JavaScript, or another route.
- For a narrow docs or setup-doctor PR, a PR comment is enough when it names the command, setup path, representative `[OK]` / `[MISSING]` / `[MANUAL]` lines, branch or commit, and result.
- Treat `[MANUAL]` lines as host-app responsibility checks. Do not count them as failed automatic checks unless the release issue explicitly changes setup doctor behavior.
- Keep auto-fix behavior, exit-code policy, and host-app setup policy decisions out of release evidence notes unless a separate implementation issue changes them.

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
- When evidence is recorded from a narrow terminal or wrapped Markdown view, the wrapped continuation should still keep `expected target ...` before `but found ...` so reviewers can pair the expected and observed values without re-running the command.
- `no explicit target` should read as a concrete diagnostic, not as an empty or crashed state.
- CSS import and bundler alias checks remain host-app responsibilities unless a future issue explicitly changes the doctor behavior.

## Narrow Evidence Checklist

Use this checklist when recording release or PR evidence:

- [ ] `[OK]`, `[MISSING]`, and `[MANUAL]` labels are visually easy to distinguish in the recorded output.
- [ ] Missing importmap target output includes both expected and observed target values.
- [ ] Narrow-width evidence says whether the output was reviewed in a standard terminal width, a wrapped Markdown/code-block view, or both.
- [ ] Wrapped mismatch lines still make the expected target and observed target relationship readable without changing setup doctor wording.
- [ ] Manual checklist lines are not described as failed automatic checks.
- [ ] Evidence notes say whether the app under review is importmap, jsbundling, bundler-managed JavaScript, or another setup path.
- [ ] Any deferred follow-up is recorded as docs/setup policy work, not as a visual reference failure.

## Non-goals

- Do not change setup doctor runtime behavior or output wording here.
- Do not introduce a terminal UI framework.
- Do not add a browser-based setup checker.
- Do not define host app setup policy, auto-fix behavior, or bundler/importmap ownership.
