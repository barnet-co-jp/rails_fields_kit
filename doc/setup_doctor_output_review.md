# Setup Doctor Output Review

Use this focused docs/design artifact when a release or PR changes setup doctor diagnostics, setup evidence, or generated setup notes. This artifact is not production UI and does not define setup doctor runtime behavior. It gives reviewers a stable way to scan representative CLI output states without mixing them into field visual references.

## Scope

- Review the readability of representative setup doctor output states.
- Confirm that the status legend explains `[OK]`, `[MISSING]`, and `[MANUAL]` before the user reaches individual checks.
- Confirm that `[OK]`, `[MISSING]`, and `[MANUAL]` lines are easy to scan as diagnostic evidence.
- Confirm that importmap target mismatch output is readable after the target-drift diagnostic landed.
- Confirm that package.json Tom Select dependency evidence reads as advisory visibility, not as host-app package policy.
- Confirm that CSS import evidence distinguishes `[OK] CSS import` as a detected advisory signal from `[MANUAL] CSS import` as a host-app responsibility check.
- Confirm that Stimulus registration evidence distinguishes `[OK] Stimulus registration` as a representative source signal from `[MANUAL] Stimulus registration` as host-app follow-up.
- Confirm narrow or wrapped evidence against the representative states in this artifact before recording a release-wide sample app result.
- Keep command behavior, wording source, host app setup policy, and auto-fix decisions outside this artifact.

## Release Evidence Handoff

Use this artifact as the review aid for setup doctor evidence, then record the release result in the sample app evidence flow rather than duplicating the full CLI output in every PR.

- Use `doc/sample_app_checklist.md` to decide whether setup doctor evidence belongs in the release baseline or the host-app setup lane.
- Record release-wide results in `doc/sample_app_results.md` under `Setup doctor checks`, including the app setup path: importmap, jsbundling, bundler-managed JavaScript, or another route.
- For a narrow docs or setup-doctor PR, a PR comment is enough when it names the command, setup path, representative `[OK]` / `[MISSING]` / `[MANUAL]` lines, branch or commit, viewport or wrapping width, and result.
- Use the representative review states below to decide whether the PR evidence should cover the first-run legend, an advisory-only Tom Select package lane, a Stimulus registration advisory lane, a CSS import advisory lane, an importmap mismatch lane, or all of those states.
- Treat `[MANUAL]` lines as host-app responsibility checks. Do not count them as failed automatic checks unless the release issue explicitly changes setup doctor behavior.
- Treat `[OK] CSS import` as evidence that setup doctor found a representative import signal; it does not mean Rails Fields Kit owns the app stylesheet pipeline, theme choice, or every possible asset path.
- Treat `[OK] Stimulus registration` as evidence that setup doctor found a representative controller registration signal; it does not mean Rails Fields Kit owns the app boot file, `Application.start()` policy, or every possible controller registry.
- Keep auto-fix behavior, exit-code policy, and host-app setup policy decisions out of release evidence notes unless a separate implementation issue changes them.

## Representative Narrow Review States

Use these states when a PR or release asks for narrow terminal, wrapped Markdown, or code-block readability evidence. They are review scenarios, not new setup doctor output variants.

| State | Use it when | Narrow / wrapped evidence should show |
| --- | --- | --- |
| First-run mixed status | The PR changes the setup doctor overview, generated setup notes, or evidence wording | The status legend appears before checks, `[MISSING]` reads as the automatic action item, and `[MANUAL]` reads as host-app follow-up rather than failure. |
| Advisory Tom Select package | The PR touches package dependency visibility, Stimulus registration guidance, or CSS import evidence | The Tom Select package line reads as advisory dependency visibility, and manual Stimulus / CSS checks do not look like failed automatic checks. |
| Stimulus registration advisory | The PR touches Stimulus registration detection, setup visibility, or release evidence for controller registration | `[OK] Stimulus registration` reads as a representative source signal, while `[MANUAL] Stimulus registration` reads as host-app boot policy follow-up rather than a failed automatic check. |
| CSS import advisory | The PR touches CSS import detection, setup visibility, or release evidence for Tom Select stylesheets | `[OK] CSS import` reads as a representative detected import signal, while `[MANUAL] CSS import` reads as host-app stylesheet or bundler-pipeline follow-up rather than a failed automatic check. |
| Importmap target mismatch | The PR changes importmap pin diagnostics or generated setup notes | Each wrapped mismatch keeps its `expected ...` and `found ...` values paired closely enough to review without re-running the command. |

For PR-level evidence, name the state and record the width used, such as `80-column terminal`, `390px Markdown preview`, or `GitHub PR comment code block`. For release-wide evidence, keep the detailed output in the release notes or PR comment and record the summary result in `doc/sample_app_results.md`.

Do not create a new runtime output mode just to satisfy this review. If a state is unreadable after wrapping, record it as a docs/setup policy follow-up unless the issue explicitly asks to change setup doctor wording.

## Representative Output States

`RailsFieldsKit::SetupDoctor#report_lines` formats each check as `[STATUS] Label: message`. Keep examples in that shape so release evidence can be compared with actual terminal output. The status legend is part of the human-readable output and should appear before the check list.

```text
rails rails_fields_kit:doctor

Rails Fields Kit setup doctor

Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.
Next step: fix [MISSING] lines first, then review [MANUAL] lines for this app's JavaScript toolchain.

[OK] Initializer: Found config/initializers/rails_fields_kit.rb.
[OK] Importmap pins: Rails Fields Kit importmap pins are present in config/importmap.rb.
[MANUAL] Tom Select package: Install Tom Select with the JavaScript package manager already used by this app.
[OK] Stimulus registration: Found Rails Fields Kit Stimulus registration signal in app/javascript/controllers/index.js. This is an advisory controller visibility check only; Stimulus boot policy stays with the host app.
[OK] CSS import: Found Tom Select CSS import signal in app/javascript/application.js. This is an advisory stylesheet visibility check only; stylesheet pipeline and theme policy stay with the host app.
[MANUAL] Bundler alias: If this app uses Vite or another bundler, verify that the host toolchain resolves the documented rails_fields_kit and rails_fields_kit/tom_select_controller import paths; this doctor does not inspect or rewrite bundler config.
```

Review notes:

- `[OK]` means the doctor could read the expected setup signal.
- `[MISSING]` means the doctor could not find an expected setup signal for the detected route.
- `[MANUAL]` means the doctor cannot safely verify the host app decision automatically; it is not a hard failure by itself.
- The `Next step` line should make first-run output actionable without adding an auto-fix policy.
- Bundler-only apps can have manual JavaScript checks without implying an importmap failure.
- `[OK] CSS import` only proves a representative stylesheet or JavaScript entrypoint contains a Tom Select CSS import signal. It does not make Rails Fields Kit responsible for stylesheet bundling, theme selection, or production CSS policy.
- `[OK] Stimulus registration` only proves a representative JavaScript entrypoint contains a Rails Fields Kit registration signal. It does not make Rails Fields Kit responsible for the app's Stimulus boot file, controller registry shape, or `Application.start()` policy.

## Tom Select Package Advisory

```text
rails rails_fields_kit:doctor

[OK] Tom Select package: Found tom-select in package.json dependencies. This is an advisory dependency visibility check only; version policy stays with the host app.
[MANUAL] Stimulus registration: Register rails-fields-kit--tom-select on the Stimulus application this app already boots.
[MANUAL] CSS import: Load tom-select/dist/css/tom-select.css from the app stylesheet or bundler entrypoint.
```

Review notes:

- The Tom Select package line only reads `package.json` for `dependencies` or `devDependencies`; it does not choose a package manager, version range, CDN, or importmap source.
- Missing `package.json`, missing `tom-select`, or invalid JSON should remain `[MANUAL]` advisory output, not a command failure.
- Stimulus registration, CSS import, and bundler alias checks remain host-app responsibilities and should continue to read as manual follow-up.

## Stimulus Registration Advisory

Use this state when setup doctor output or release evidence needs to show the difference between a detected representative registration signal and a manual host-app boot check.

Detected representative entrypoint:

```text
rails rails_fields_kit:doctor

[OK] Stimulus registration: Found Rails Fields Kit Stimulus registration signal in app/javascript/controllers/index.js. This is an advisory controller visibility check only; Stimulus boot policy stays with the host app.
```

No representative signal found:

```text
rails rails_fields_kit:doctor

[MANUAL] Stimulus registration: Rails Fields Kit Stimulus registration signal was not found in representative JavaScript entrypoints. Confirm the host app registers rails-fields-kit--tom-select with TomSelectController on the Stimulus application it already boots; setup doctor does not inspect every boot file or decide Application.start policy.
```

Review notes:

- `[OK] Stimulus registration` is a detected advisory state. It is safe evidence that one representative candidate path contains `rails-fields-kit--tom-select` or `TomSelectController`.
- `[MANUAL] Stimulus registration` means setup doctor did not find a representative signal and the host app should confirm its own Stimulus boot path.
- Both states keep controller registration policy, `Application.start()` decisions, custom controller indexes, and full JavaScript graph validation with the host app.
- Do not treat `[MANUAL] Stimulus registration` as a hard failure unless a separate setup or release policy issue explicitly changes the doctor behavior.

## CSS Import Advisory

Use this state when setup doctor output or release evidence needs to show the difference between a detected CSS import signal and a manual host-app stylesheet check.

Detected representative entrypoint:

```text
rails rails_fields_kit:doctor

[OK] CSS import: Found Tom Select CSS import signal in app/javascript/application.js. This is an advisory stylesheet visibility check only; stylesheet pipeline and theme policy stays with the host app.
```

Detected representative stylesheet or theme file:

```text
rails rails_fields_kit:doctor

[OK] CSS import: Found Tom Select CSS import signal in app/assets/stylesheets/application.css. This is an advisory stylesheet visibility check only; stylesheet pipeline and theme policy stays with the host app.
```

No representative signal found:

```text
rails rails_fields_kit:doctor

[MANUAL] CSS import: Tom Select CSS import was not found in representative stylesheet or JavaScript entrypoints. Confirm the host app loads tom-select/dist/css/tom-select.css or a deliberate Tom Select theme through its own stylesheet or bundler pipeline; setup doctor does not inspect every asset path or rewrite style config.
```

Review notes:

- `[OK] CSS import` is a detected advisory state. It is safe evidence that one representative candidate path contains `tom-select/dist/css/tom-select*.css`.
- `[MANUAL] CSS import` means setup doctor did not find a representative signal and the host app should confirm its own stylesheet or bundler pipeline.
- Both states keep CSS install, theme selection, asset ordering, production styling, and full asset graph validation with the host app.
- Do not treat `[MANUAL] CSS import` as a hard failure unless a separate release or setup policy issue explicitly changes the doctor behavior.

## Importmap Target Mismatch

```text
rails rails_fields_kit:doctor

Rails Fields Kit setup doctor

Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.
Next step: fix [MISSING] lines first, then review [MANUAL] lines for this app's JavaScript toolchain.

[OK] Initializer: Found config/initializers/rails_fields_kit.rb.
[MISSING] Importmap pins: Missing Rails Fields Kit importmap pins: rails_fields_kit/tom_select_controller. Rails Fields Kit importmap pins with unexpected targets: rails_fields_kit (expected rails_fields_kit/index.js, found rails_fields_kit), rails_fields_kit/tom_select_controller (expected rails_fields_kit/tom_select_controller.js, found no explicit target).
[MANUAL] Tom Select package: Install Tom Select with the JavaScript package manager already used by this app.
[MANUAL] CSS import: Load tom-select/dist/css/tom-select.css from the app stylesheet or bundler entrypoint.
[MANUAL] Stimulus registration: Rails Fields Kit Stimulus registration signal was not found in representative JavaScript entrypoints. Confirm the host app registers rails-fields-kit--tom-select with TomSelectController on the Stimulus application it already boots; setup doctor does not inspect every boot file or decide Application.start policy.
```

Review notes:

- Target mismatch evidence should show the expected target and the observed target in the same line.
- Legacy release notes may refer to the same mismatch as `importmap pin rails_fields_kit expected target rails_fields_kit/index.js`; current examples keep that target relationship inside the `[MISSING] Importmap pins:` report line.
- When evidence is recorded from a narrow terminal or wrapped Markdown view, the wrapped continuation should still keep `(expected ...` before `found ...` so reviewers can pair the expected and observed values without re-running the command.
- `found no explicit target` should read as a concrete diagnostic, not as an empty or crashed state.
- Missing pins and target mismatches can appear in one aggregated `Importmap pins` line.
- CSS import and bundler alias checks remain host-app responsibilities unless a future issue explicitly changes the doctor behavior.

## Narrow Evidence Checklist

Use this checklist when recording release or PR evidence:

- [ ] The status legend appears before individual check lines.
- [ ] `[OK]`, `[MISSING]`, and `[MANUAL]` labels are visually easy to distinguish in the recorded output.
- [ ] The evidence note distinguishes `[MISSING]` action items from `[MANUAL]` host-app checks.
- [ ] Missing importmap target output includes both expected and observed target values.
- [ ] Tom Select package evidence is described as advisory dependency visibility, not package/version policy.
- [ ] Stimulus registration evidence distinguishes detected advisory signals from manual host-app boot checks.
- [ ] `[OK] Stimulus registration` is not described as Rails Fields Kit owning the app boot file, controller registry shape, or `Application.start()` policy.
- [ ] `[MANUAL] Stimulus registration` is not described as a failed automatic check unless a separate issue changes setup doctor behavior.
- [ ] CSS import evidence distinguishes detected advisory signals from manual host-app stylesheet checks.
- [ ] `[OK] CSS import` is not described as Rails Fields Kit owning stylesheet bundling, theme policy, or production CSS.
- [ ] `[MANUAL] CSS import` is not described as a failed automatic check unless a separate issue changes setup doctor behavior.
- [ ] Narrow-width evidence says whether the output was reviewed in a standard terminal width, a wrapped Markdown/code-block view, or both.
- [ ] Wrapped mismatch lines still make the expected and observed target relationship readable without changing setup doctor wording.
- [ ] Manual checklist lines are not described as failed automatic checks.
- [ ] Evidence notes say whether the app under review is importmap, jsbundling, bundler-managed JavaScript, or another setup path.
- [ ] Any deferred follow-up is recorded as docs/setup policy work, not as a visual reference failure.

## Non-goals

- Do not change setup doctor runtime behavior or output wording here.
- Do not introduce a terminal UI framework.
- Do not add a browser-based setup checker.
- Do not define host app setup policy, auto-fix behavior, or bundler/importmap ownership.
