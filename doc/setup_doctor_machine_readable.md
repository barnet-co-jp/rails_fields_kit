# Setup doctor machine-readable output

`RailsFieldsKit::SetupDoctor` can emit the same read-only setup checks as JSON for host-app CI, generator smoke tests, or release verification scripts.

Use the Ruby API when a script needs the structured payload. Capture the output in an IO object, then parse the JSON from that object:

```ruby
require "json"
require "stringio"

output = StringIO.new
RailsFieldsKit::SetupDoctor.new.run(io: output, format: :json)
payload = JSON.parse(output.string)
```

The default text output remains unchanged. JSON output is an alternate representation; it does not add auto-fix behavior and it does not decide whether advisory checks should fail a host app build.

## Ruby usage boundary

`run(io:, format: :json)` is the documented machine-readable entrypoint. It writes a pretty-printed JSON payload to the provided IO object and returns `true`, matching the text-output command behavior.

Host apps can wrap this Ruby call in their own Rake task, CI script, or release verification command when they need automation. Rails Fields Kit does not currently document a separate `rails rails_fields_kit:doctor --json` CLI contract, and this guide should not be read as promising one.

## Payload shape

```json
{
  "schema_version": 1,
  "tool": "rails_fields_kit:doctor",
  "summary": {
    "ok": 1,
    "missing": 0,
    "manual": 5
  },
  "checks": [
    {
      "key": "initializer",
      "label": "Initializer",
      "status": "ok",
      "manual": false,
      "message": "Found config/initializers/rails_fields_kit.rb."
    }
  ]
}
```

`status` is one of `ok`, `missing`, or `manual`.

- `ok`: detected setup signal.
- `missing`: an expected setup file or importmap pin is absent or mismatched.
- `manual`: advisory host-app check. Treat it as input to the app's own CI policy, not as a hard failure by default.

The `manual` boolean is included so callers can keep advisory checks separate from missing required setup signals without parsing message text.

## CI policy boundary

The `summary` counts and `checks` array are inspection data. They can help a host app decide what to log, alert on, or fail in that app's own pipeline, but Rails Fields Kit does not define a universal pass/fail policy for every consuming app.

A common wrapper is to fail only when `summary["missing"]` is greater than zero, while recording `manual` checks for review. That is a host-app policy choice, not behavior enforced by `SetupDoctor`.

## Release and sample evidence

When release or sample-app evidence needs structured setup visibility, record a representative JSON check rather than copying the full payload schema into the evidence log. A narrow PR comment can name the branch or commit checked, the Ruby API call used, the observed `summary["missing"]` count, and whether any `manual` checks were reviewed as host-app advisory items.

Use this short note shape when a PR comment or narrow Markdown preview is the evidence surface:

```text
Setup doctor JSON evidence
Branch/head: <branch or commit checked>
Ruby API: RailsFieldsKit::SetupDoctor.new.run(io: output, format: :json)
Observed summary["missing"]: <count>
Manual advisory checks reviewed: <yes/no, with short scope>
Remaining host-app follow-up: <none or short owner/action>
Boundary: JSON output only; no CLI --json, schema publication, or CI policy change.
```

Keep each line short enough that a 390px-equivalent PR comment can wrap without losing the key/value relationship. If the evidence needs detailed wrapped text output, use `doc/setup_doctor_output_review.md` instead of expanding this JSON note into a full setup-doctor transcript.

Use `doc/sample_app_results.md` for release-candidate evidence and a PR comment for narrow docs or setup-doctor evidence. In either location, link back to this guide as the payload source of truth and keep the evidence focused on what was observed for that branch.

Do not treat this evidence lane as a CLI `--json` contract, a formal schema publication, auto-fix behavior, SARIF or JUnit output, or a universal host-app CI pass/fail policy.

## Boundary

The doctor remains read-only. It does not inspect every possible asset or bundler path, rewrite files, install packages, register Stimulus controllers, emit SARIF or JUnit, publish a formal JSON schema, or decide the host app's JavaScript/CSS or CI policy.
