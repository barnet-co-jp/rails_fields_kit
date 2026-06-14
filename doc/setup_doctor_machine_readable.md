# Setup doctor machine-readable output

`RailsFieldsKit::SetupDoctor` can emit the same read-only setup checks as JSON for host-app CI, generator smoke tests, or release verification scripts.

```ruby
output = StringIO.new
RailsFieldsKit::SetupDoctor.new.run(io: output, format: :json)
payload = JSON.parse(output.string)
```

The default text output remains unchanged. JSON output is an alternate representation; it does not add auto-fix behavior and it does not decide whether advisory checks should fail a host app build.

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

## Boundary

The doctor remains read-only. It does not inspect every possible asset or bundler path, rewrite files, install packages, register Stimulus controllers, or decide the host app's JavaScript/CSS policy.
