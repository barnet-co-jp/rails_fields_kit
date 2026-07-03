# Setup doctor read-only report surface

`RailsFieldsKit::SetupDoctor` is a read-only diagnostic helper for checking whether a host app has the visible pieces needed for the current Rails Fields Kit setup routes. It does not rewrite app files, install JavaScript packages, decide CI policy, or turn setup gaps into command failures.

The doctor also reports the generated host-app setup note at `doc/rails_fields_kit_setup.md`. When the note is present, it is an `[OK]` visibility signal. When it is absent, the item is `[MANUAL]`, not `[MISSING]`, because `rails generate rails_fields_kit:install --skip-setup-notes` is a valid route and some host apps keep app-specific setup notes elsewhere. The doctor does not create the note, inspect its contents, or judge app-specific checklist quality.

## Programmatic inspection

Host-app scripts and release evidence scripts may inspect `SetupDoctor#checks` when they need a small Ruby-facing view of the current diagnostic state. Each item is a `RailsFieldsKit::SetupDoctor::Check` with these read-only fields:

| Field | Meaning |
| --- | --- |
| `key` | Symbol identifier for the diagnostic item, such as `:initializer`, `:generated_setup_note`, `:importmap`, `:tom_select_package`, or `:css_import`. |
| `label` | Human-readable label used in the text report. |
| `status` | Symbol status. Current representative values are `:ok`, `:missing`, and `:manual`. |
| `message` | Human-readable diagnostic message. |

Treat these objects as inspection output. Host apps should not mutate returned checks or depend on the exact ordering as a workflow policy. A `:missing` status means Rails Fields Kit detected an actionable setup gap for the inspected route. A `:manual` status means the item remains a host-app responsibility because the gem cannot safely infer every JavaScript toolchain, package policy, generated-note policy, or bundler configuration.

When a script needs the same read-only checks as a structured JSON payload, use [`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md). That guide documents the `schema_version`, `tool`, `summary`, and `checks` representation without making the doctor an auto-fix tool, SARIF/JUnit emitter, or host-app CI pass/fail policy.

## Text evidence

`SetupDoctor#report_lines` returns the same human-readable lines printed by the doctor command. It is useful for logs, release notes, or support evidence where a text snapshot is easier to review than custom formatting.

`report_lines` is not a JSON schema, SARIF/JUnit contract, or stable machine-readable report format. Scripts that need structured inspection should read `checks` directly or use the JSON representation documented in [`setup_doctor_machine_readable.md`](setup_doctor_machine_readable.md), while keeping any CI failure policy in the host app.

## Command behavior

`SetupDoctor#run(io:)` writes `report_lines` to the provided IO object and returns `true`. When called with `format: :json`, it writes the same diagnostic state as the structured JSON representation. Both output paths stay read-only: they report detected setup visibility, then leave fixes, package installation, setup-note creation, importmap policy, bundler aliases, Stimulus registration, CSS loading, and CI pass/fail decisions to the host app.

The Rails task `rails rails_fields_kit:doctor` follows the same boundary. It is a visibility check, not an auto-fix command or a host-app setup policy engine.
