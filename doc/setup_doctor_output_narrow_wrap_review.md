# Setup Doctor Narrow Wrap Review Aid

Use this companion artifact with `doc/setup_doctor_output_review.md` when a PR or release needs narrow terminal, GitHub PR comment, or Markdown preview evidence for setup doctor output.

This page is review evidence only. It does not define setup doctor runtime wording, exit-code behavior, auto-fix policy, host-app setup policy, or production UI.

## Review Surfaces

Check at least one of these surfaces before claiming narrow readability:

| Surface | Representative width | What to look for |
| --- | --- | --- |
| Terminal | 80 columns | Status labels remain scannable and the first action item is easy to find. |
| GitHub PR comment code block | Default PR conversation width | Long diagnostic lines wrap without separating `expected` from the matching `found` value. |
| Markdown preview | 390px narrow viewport | `[MANUAL]` reads as host-app follow-up, not as a failed automatic check. |

Record the surface and width in the PR or release evidence note. Do not mark browser or terminal evidence as confirmed if it was only source-reviewed.

## Status Scan Checklist

- `[OK]` means setup doctor found a representative setup signal.
- `[MISSING]` is the automatic action item for the detected setup route.
- `[MANUAL]` is a host-app responsibility check, not an automatic failure.
- The status legend should appear before the first diagnostic line.
- The `Next step` line should say to fix `[MISSING]` first, then review `[MANUAL]` for the app's JavaScript toolchain.

## Wrapped Importmap Example

When the importmap target mismatch line wraps, keep each expected/found pair adjacent in evidence notes. A review note may reflow the captured output for readability, but it should not imply a new runtime output mode.

```text
[MISSING] Importmap pins: Missing Rails Fields Kit importmap pins:
rails_fields_kit/tom_select_controller. Rails Fields Kit importmap pins
with unexpected targets: rails_fields_kit (expected
rails_fields_kit/index.js, found rails_fields_kit),
rails_fields_kit/tom_select_controller (expected
rails_fields_kit/tom_select_controller.js, found no explicit target).
```

Review the line as readable only if both relationships are still clear:

| Pin | Expected | Found |
| --- | --- | --- |
| `rails_fields_kit` | `rails_fields_kit/index.js` | `rails_fields_kit` |
| `rails_fields_kit/tom_select_controller` | `rails_fields_kit/tom_select_controller.js` | `no explicit target` |

If the pair is not readable in the captured surface, record a docs/setup policy follow-up. Do not change setup doctor output wording from this review aid alone.

## Advisory Ownership Examples

Use these short examples when a captured state mixes detected setup signals with host-app follow-up.

```text
[OK] CSS import: Found Tom Select CSS import signal in app/javascript/application.js.
This is an advisory stylesheet visibility check only; stylesheet pipeline and
theme policy stay with the host app.

[MANUAL] Stimulus registration: Rails Fields Kit Stimulus registration signal
was not found in representative JavaScript entrypoints. Confirm the host app
registers rails-fields-kit--tom-select with TomSelectController on the Stimulus
application it already boots.
```

The review passes when the captured surface keeps these distinctions readable:

- `[OK] CSS import` is a detected advisory signal, not ownership of the app stylesheet pipeline.
- `[MANUAL] Stimulus registration` is host-app boot-policy follow-up, not a failed automatic check.
- Tom Select package visibility is dependency evidence only; package manager and version policy stay with the host app.

## Generated Setup Note Examples

Use these short examples when a captured state needs to show the generated host-app setup note check after #2623.

```text
[OK] Generated setup note: Found doc/rails_fields_kit_setup.md.

[MANUAL] Generated setup note: doc/rails_fields_kit_setup.md was not found.
This can be OK when the app used --skip-setup-notes or keeps setup notes in a
host-owned location; setup doctor does not create or grade setup notes.
```

The review passes when the captured surface keeps these distinctions readable:

- `[OK] Generated setup note` is a visibility signal for the generated note path, not proof that the note content was reviewed.
- `[MANUAL] Generated setup note` is a valid host-app route when setup notes were skipped or stored elsewhere.
- Missing generated setup notes are not described as `[MISSING]`, auto-fix work, or host-app CI failure unless another issue changes setup doctor behavior.

## Evidence Note Template

```text
Setup doctor narrow wrap evidence:
- Surface: 80-column terminal / GitHub PR comment code block / 390px Markdown preview
- Setup path: importmap / jsbundling / bundler-managed JavaScript / other
- Reviewed states: First-run mixed status / Advisory Tom Select package / Stimulus registration advisory / CSS import advisory / Generated setup note advisory / Importmap target mismatch
- Result: readable / needs docs follow-up
- Notes: expected/found pairs stayed adjacent; [MANUAL] read as host-app follow-up, not failure
```

Keep detailed output in the PR or release evidence note and record the release summary in `doc/sample_app_results.md` when the review is release-wide.
