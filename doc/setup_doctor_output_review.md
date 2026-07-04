# Setup Doctor Output Review

Use this focused docs/design artifact when a release or PR changes setup doctor diagnostics, setup evidence, or generated setup notes. This artifact is not production UI and does not define setup doctor runtime behavior. It gives reviewers a stable way to scan representative CLI output states without mixing them into field visual references.

Use `doc/setup_doctor_output_narrow_wrap_review.md` with this route when the evidence needs an 80-column terminal, GitHub PR comment code block, or 390px Markdown preview readability check. The companion artifact is review evidence only; keep setup doctor runtime wording, exit-code behavior, auto-fix policy, and host-app setup policy here as non-goals unless a separate implementation issue changes them.

## Scope

- Review the readability of representative setup doctor output states.
- Confirm that the status legend explains `[OK]`, `[MISSING]`, and `[MANUAL]` before the user reaches individual checks.
- Confirm that `[OK]`, `[MISSING]`, and `[MANUAL]` lines are easy to scan as diagnostic evidence.
- Confirm that generated setup note evidence distinguishes `[OK]` note presence from `[MANUAL]` host-app note ownership.
- Confirm that importmap target mismatch output is readable after the target-drift diagnostic landed.
- Confirm that unresolved import evidence records the failing documented path, checked alias or pin target, and remaining host-app follow-up without changing setup doctor behavior.
- Confirm that package.json Tom Select dependency evidence reads as advisory visibility, not as host-app package policy.
- Confirm that CSS import evidence distinguishes `[OK] CSS import` as a detected advisory signal from `[MANUAL] CSS import` as a host-app responsibility check.
- Confirm that Stimulus registration evidence distinguishes `[OK] Stimulus registration` as a representative source signal from `[MANUAL] Stimulus registration` as host-app follow-up.
- Confirm narrow or wrapped evidence against the representative states in this artifact before recording a release-wide sample app result.
- Use `doc/setup_doctor_output_narrow_wrap_review.md` when the review note needs surface-specific narrow-width checklist prompts or an evidence note template.
- Keep command behavior, wording source, host app setup policy, and auto-fix decisions outside this artifact.

## Release Evidence Handoff

Use this artifact as the review aid for setup doctor evidence, then record the release result in the sample app evidence flow rather than duplicating the full CLI output in every PR.

- Use `doc/sample_app_checklist.md` to decide whether setup doctor evidence belongs in the release baseline or the host-app setup lane.
- Record release-wide results in `doc/sample_app_results.md` under `Setup doctor checks`, including the app setup path: importmap, jsbundling, bundler-managed JavaScript, or another route.
- For a narrow docs or setup-doctor PR, a PR comment is enough when it names the command, setup path, representative `[OK]` / `[MISSING]` / `[MANUAL]` lines, branch or commit, viewport or wrapping width, and result.
- For generated setup note advisory evidence, include whether the note path was present or absent, and keep `--skip-setup-notes` / host-owned notes as valid `[MANUAL]` routes rather than failures.
- For unresolved import diagnostics, include the failing documented import path, whether the package-root `rails_fields_kit` path or direct `rails_fields_kit/tom_select_controller` path failed, the alias or importmap pin target checked, and any remaining host-app follow-up such as Stimulus boot, Tom Select install, or CSS import.
- When the PR comment needs a reusable narrow evidence template, start from `doc/setup_doctor_output_narrow_wrap_review.md` and link the note back to this review route instead of copying the companion artifact wholesale.
- Use the representative review states below to decide whether the PR evidence should cover the first-run legend, a generated setup note advisory lane, an advisory-only Tom Select package lane, a Stimulus registration advisory lane, a CSS import advisory lane, an importmap mismatch lane, an unresolved import diagnostics lane, or all of those states.
- Treat `[MANUAL]` lines as host-app responsibility checks. Do not count them as failed automatic checks unless the release issue explicitly changes setup doctor behavior.
- Treat `[OK] CSS import` as evidence that setup doctor found a representative import signal; it does not mean Rails Fields Kit owns the app stylesheet pipeline, theme choice, or every possible asset path.
- Treat `[OK] Stimulus registration` as evidence that setup doctor found a representative controller registration signal; it does not mean Rails Fields Kit owns the app boot file, `Application.start()` policy, or every possible controller registry.
- Treat `[OK] Generated setup note` as path visibility evidence only; it does not mean setup doctor reviewed note content or setup quality.
- Keep auto-fix behavior, exit-code policy, and host-app setup policy decisions out of release evidence notes unless a separate implementation issue changes them.

## Representative Narrow Review States

Use these states when a PR or release asks for narrow terminal, wrapped Markdown, or code-block readability evidence. They are review scenarios, not new setup doctor output variants.

| State | Use it when | Narrow / wrapped evidence should show |
| --- | --- | --- |
| First-run mixed status | The PR changes the setup doctor overview, generated setup notes, or evidence wording | The status legend appears before checks, `[MISSING]` reads as the automatic action item, and `[MANUAL]` reads as host-app follow-up rather than failure. |
| Generated setup note advisory | The PR touches generated setup note evidence, setup note review notes, or #2623 follow-up wording | `[OK] Generated setup note` reads as path visibility, while `[MANUAL] Generated setup note` reads as a valid skipped or host-owned note route rather than a failed automatic check. |
| Advisory Tom Select package | The PR touches package dependency visibility, Stimulus registration guidance, or CSS import evidence | The Tom Select package line reads as advisory dependency visibility, and manual Stimulus / CSS checks do not look like failed automatic checks. |
| Stimulus registration advisory | The PR touches Stimulus registration detection, setup visibility, or release evidence for controller registration | `[OK] Stimulus registration` reads as a representative source signal, while `[MANUAL] Stimulus registration` reads as host-app boot policy follow-up rather than a failed automatic check. |
| CSS import advisory | The PR touches CSS import detection, setup visibility, or release evidence for Tom Select stylesheets | `[OK] CSS import` reads as a representative detected import signal, while `[MANUAL] CSS import` reads as host-app stylesheet or bundler-pipeline follow-up rather than a failed automatic check. |
| Importmap target mismatch | The PR changes importmap pin diagnostics or generated setup notes | Each wrapped mismatch keeps its `expected ...` and `found ...` values paired closely enough to review without re-running the command. |
| Unresolved import diagnostics | The PR changes setup troubleshooting, package-root imports, direct controller imports, or setup evidence wording | The note distinguishes `rails_fields_kit` from `rails_fields_kit/tom_select_controller`, names the checked alias or pin target, and keeps Tom Select install, CSS import, and Stimulus boot as separate host-app follow-up. |

For PR-level evidence, name the state and record the width used, such as `80-column terminal`, `390px Markdown preview`, or `GitHub PR comment code block`. For release-wide evidence, keep the detailed output in the release notes or PR comment and record the summary result in `doc/sample_app_results.md`.

Use this matrix when deciding which evidence note to write after a narrow or wrapped review. It keeps the representative state, checklist focus, and recording context together so reviewers do not have to infer which checklist section applies.

| Evidence note names | Pair with checklist section | Include in the note |
| --- | --- | --- |
| `First-run mixed status` | Status Interpretation | Legend position, `[MISSING]` action item, `[MANUAL]` host-app follow-up wording, and the width or preview surface used. |
| `Generated setup note advisory` | Advisory Ownership | Whether the note state is `[OK]` or `[MANUAL]`, whether `doc/rails_fields_kit_setup.md` was present, and whether skipped or host-owned notes remain valid. |
| `Advisory Tom Select package` | Advisory Ownership | Package evidence boundary, manual Stimulus / CSS follow-up wording, setup path, and whether the line came from package.json visibility only. |
| `Stimulus registration advisory` | Advisory Ownership | Whether the captured state is `[OK]` or `[MANUAL]`, the representative entrypoint or absence of one, and the host-app boot-policy boundary. |
| `CSS import advisory` | Advisory Ownership | Whether the captured state is `[OK]` or `[MANUAL]`, the representative stylesheet or entrypoint, and the host-app stylesheet / bundler boundary. |
| `Importmap target mismatch` | Wrapping Evidence | The wrapped width, each expected target, each found target, and whether the pair remains readable without changing setup doctor wording. |
| `Unresolved import diagnostics` | Unresolved Import Evidence | The failing documented import path, checked alias or importmap pin target, setup path, and remaining host-app follow-up separated by responsibility. |

Do not create a new runtime output mode just to satisfy this review. If a state is unreadable after wrapping, record it as a docs/setup policy follow-up unless the issue explicitly asks to change setup doctor wording.

## Representative Output States

`RailsFieldsKit::SetupDoctor#report_lines` formats each check as `[STATUS] Label: message`. Keep examples in that shape so release evidence can be compared with actual terminal output. The status legend is part of the human-readable output and should appear before the check list.

```text
rails rails_fields_kit:doctor

Rails Fields Kit setup doctor

Status legend: [OK] detected setup; [MISSING] needs action for the detected setup route; [MANUAL] host-app check, not an automatic failure.
Next step: fix [MISSING] lines first, then review [MANUAL] lines for this app's JavaScript toolchain.

[OK] Initializer: Found config/initializers/rails_fields_kit.rb.
[OK] Generated setup note: Found doc/rails_fields_kit_setup.md.
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
- `[OK] Generated setup note` means the generated note path is present. It does not inspect the note body, decide whether the checklist is complete, or grade app-specific setup quality.
- `[MANUAL] Generated setup note` should remain a valid route when the app used `--skip-setup-notes` or keeps notes outside `doc/rails_fields_kit_setup.md`.
- The `Next step` line should make first-run output actionable without adding an auto-fix policy.
- Bundler-only apps can have manual JavaScript checks without implying an importmap failure.
- `[OK] CSS import` only proves a representative stylesheet or JavaScript entrypoint contains a Tom Select CSS import signal. It does not make Rails Fields Kit responsible for stylesheet bundling, theme selection, or production CSS policy.
- `[OK] Stimulus registration` only proves a representative JavaScript entrypoint contains a Rails Fields Kit registration signal. It does not make Rails Fields Kit responsible for the app's Stimulus boot file, controller registry shape, or `Application.start()` policy.

## Generated Setup Note Advisory

Use this state when setup doctor output or release evidence needs to show the difference between a detected generated setup note and a host-owned or intentionally skipped setup note route.

Generated setup note present:

```text
rails rails_fields_kit:doctor

[OK] Generated setup note: Found doc/rails_fields_kit_setup.md.
```

Generated setup note absent:

```text
rails rails_fields_kit:doctor

[MANUAL] Generated setup note: doc/rails_fields_kit_setup.md was not found. If this app used --skip-setup-notes or keeps setup notes elsewhere, confirm the host-owned setup note route; setup doctor does not create, inspect, or grade generated setup notes.
```

Review notes:

- `[OK] Generated setup note` is a detected advisory state for the generated note path.
- `[MANUAL] Generated setup note` means setup doctor did not find `doc/rails_fields_kit_setup.md`, but absence can be intentional for skipped generated notes or host-owned documentation.
- Both states keep generated note creation, note content quality, setup checklist ownership, and host-app CI policy outside setup doctor.
- Do not treat `[MANUAL] Generated setup note` as `[MISSING]`, auto-fix work, or a hard failure unless a separate setup policy issue explicitly changes doctor behavior.

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

[OK] CSS import: Found Tom Select CSS import signal in app/javascript/application.js. This is an advisory stylesheet visibility check only; stylesheet pipeline and theme policy stay with the host app.
```

Detected representative stylesheet or theme file:

```text
rails rails_fields_kit:doctor

[OK] CSS import: Found Tom Select CSS import signal in app/assets/stylesheets/application.css. This is an advisory stylesheet visibility check only; stylesheet pipeline and theme policy stay with the host app.
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
- Do not treat `[MANUAL] CSS import` as a hard failure unless a separate release or setup policy issue explicitly changes setup doctor behavior.

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

## Unresolved Import Diagnostics

Use this state when a setup or release note needs to show that a documented import failed to resolve without turning that result into a setup doctor runtime change.

```text
Evidence note: Unresolved import diagnostics
Setup path: bundler-managed JavaScript
Failing documented import: rails_fields_kit
Checked target: bundler alias for rails_fields_kit -> app/javascript/rails_fields_kit/index.js
Result: package-root import still unresolved in the host app bundle.
Remaining follow-up: host app checks its bundler alias and package resolution; Tom Select package install, CSS import, and Stimulus boot policy are separate checks.
```

```text
Evidence note: Unresolved import diagnostics
Setup path: importmap
Failing documented import: rails_fields_kit/tom_select_controller
Checked target: importmap pin rails_fields_kit/tom_select_controller -> rails_fields_kit/tom_select_controller.js
Result: direct controller import still unresolved in the browser importmap.
Remaining follow-up: host app checks the importmap pin target and registration file; package-root helper imports are a separate path.
```

Review notes:

- Record the failing documented path exactly as either `rails_fields_kit` or `rails_fields_kit/tom_select_controller` instead of collapsing both into generic unresolved imports.
- For package-root failures, check the `rails_fields_kit` alias or pin target against `rails_fields_kit/index.js` and keep `doc/public_api.md#javascript-exports` as the helper list source of truth.
- For direct controller failures, check the `rails_fields_kit/tom_select_controller` alias or pin target against `rails_fields_kit/tom_select_controller.js` and keep controller registration as a separate Stimulus boot check.
- If both documented paths fail, record both paths and targets separately before changing host-app bundler aliases, importmap pins, or setup notes.
- Do not describe unresolved import evidence as Tom Select package installation, CSS import, or Stimulus boot evidence. Those remain separate host-app responsibility checks.
- Do not change setup doctor output wording, importmap generation, bundler alias detection, or auto-fix behavior from this review artifact.

## Narrow Evidence Checklist

Use this checklist when recording release or PR evidence. Work from the status meaning first, then check advisory ownership, wrapping readability, and the evidence recording context.

### Status Interpretation

- [ ] The status legend appears before individual check lines.
- [ ] `[OK]`, `[MISSING]`, and `[MANUAL]` labels are visually easy to distinguish in the recorded output.
- [ ] The evidence note distinguishes `[MISSING]` action items from `[MANUAL]` host-app checks.
- [ ] Manual checklist lines are not described as failed automatic checks.

### Advisory Ownership

- [ ] Generated setup note evidence distinguishes detected note visibility from note content quality or setup checklist approval.
- [ ] `[OK] Generated setup note` is not described as setup note body review, setup completeness approval, or host-app policy ownership.
- [ ] `[MANUAL] Generated setup note` is not described as a failed automatic check when `--skip-setup-notes` or host-owned notes are valid for the app.
- [ ] Tom Select package evidence is described as advisory dependency visibility, not package/version policy.
- [ ] Stimulus registration evidence distinguishes detected advisory signals from manual host-app boot checks.
- [ ] `[OK] Stimulus registration` is not described as Rails Fields Kit owning the app boot file, controller registry shape, or `Application.start()` policy.
- [ ] `[MANUAL] Stimulus registration` is not described as a failed automatic check unless a separate issue changes setup doctor behavior.
- [ ] CSS import evidence distinguishes detected advisory signals from manual host-app stylesheet checks.
- [ ] `[OK] CSS import` is not described as Rails Fields Kit owning stylesheet bundling, theme policy, or production CSS.
- [ ] `[MANUAL] CSS import` is not described as a failed automatic check unless a separate release or setup policy issue explicitly changes setup doctor behavior.

### Wrapping Evidence

- [ ] Missing importmap target output includes both expected and observed target values.
- [ ] Narrow-width evidence says whether the output was reviewed in a standard terminal width, a wrapped Markdown/code-block view, or both.
- [ ] Wrapped mismatch lines still make the expected and observed target relationship readable without changing setup doctor wording.

### Unresolved Import Evidence

- [ ] Evidence names the failing documented import path as `rails_fields_kit` or `rails_fields_kit/tom_select_controller`.
- [ ] Package-root evidence checks the `rails_fields_kit` alias or pin target separately from the direct controller target.
- [ ] Direct controller evidence checks the `rails_fields_kit/tom_select_controller` alias or pin target separately from package-root helper imports.
- [ ] Evidence records whether the app setup path is importmap, jsbundling, bundler-managed JavaScript, or another route.
- [ ] Remaining Tom Select install, CSS import, and Stimulus boot follow-up stays separate from the unresolved import result.

### Recording Context

- [ ] Evidence notes say whether the app under review is importmap, jsbundling, bundler-managed JavaScript, or another setup path.
- [ ] Any deferred follow-up is recorded as docs/setup policy work, not as a visual reference failure.

## Non-goals

- Do not change setup doctor runtime behavior or output wording here.
- Do not introduce a terminal UI framework.
- Do not add a browser-based setup checker.
- Do not define host app setup policy, auto-fix behavior, or bundler/importmap ownership.
