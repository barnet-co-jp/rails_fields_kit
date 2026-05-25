# Rails Fields Kit Release Guide

This guide describes the lightweight release flow for Rails Fields Kit.

## Policy

- Rails Fields Kit targets Rails 7.0 and newer.
- Rails dependency is currently bounded to Rails 7 and Rails 8.
- GitHub Actions CI is not required for every exploratory commit during active development.
- Branch-ready changes should pass the local checks in [`doc/development.md`](development.md):

```bash
bundle exec standardrb
bundle exec rspec
bundle exec rake build
```

- Before release, rerun those local checks on the latest `main` and confirm GitHub Actions CI succeeds for the exact release candidate commit.

## Pre-release checklist

1. Pull the latest main branch.

   ```bash
   git pull
   ```

2. Install dependencies.

   ```bash
   bundle install
   ```

3. Run the linter locally.

   ```bash
   bundle exec standardrb
   ```

4. Run the test suite locally.

   ```bash
   bundle exec rspec
   ```

5. Build the gem locally.

   ```bash
   bundle exec rake build
   ```

6. Confirm the latest GitHub Actions CI run is green for the commit you plan to release.

   This is the final branch-head confirmation for lint, RSpec, JavaScript syntax, and gem package/install smoke checks.

7. Review documentation.

   - `README.md`
   - `CHANGELOG.md`
   - `doc/setup.md`
   - `doc/public_api.md`
   - `doc/field_helpers.md`
   - `doc/controller_helpers.md`
   - `doc/token_suggestions.md`
   - `doc/ransack_suggestions.md`
   - `doc/table_adapters.md`
   - `doc/configuration.md`
   - `doc/events.md`
   - `doc/development.md`
   - `doc/sample_app_checklist.md`
   - `doc/sample_app_results.md`
   - `doc/final_release_checklist.md`
   - `doc/release.md`
   - the version-specific release note draft for the target release

8. Confirm version.

   ```ruby
   # lib/rails_fields_kit/version.rb
   RailsFieldsKit::VERSION = "x.y.z"
   ```

9. Install the built gem into a sample Rails 7+ application, verify [`sample_app_checklist.md`](sample_app_checklist.md), and record the result in [`sample_app_results.md`](sample_app_results.md).

## Release steps

1. Update `CHANGELOG.md`.

   Move entries from `Unreleased` to the target version, for example:

   ```markdown
   ## 0.1.1 - YYYY-MM-DD
   ```

2. Prepare the version-specific release note draft.

   Copy the structure from `doc/release_notes_0_1_0.md` when you need a new draft, then replace the version number and verification details for the target release.

3. Commit release metadata.

   ```bash
   git add CHANGELOG.md lib/rails_fields_kit/version.rb
   git commit -m "Prepare x.y.z release"
   ```

4. Build the gem.

   ```bash
   bundle exec rake build
   ```

5. Publish the gem when ready.

   ```bash
   bundle exec rake release
   ```

## Post-release checklist

- Confirm the gem is visible on RubyGems.
- Create a GitHub release if desired.
- Start the next changelog section:

```markdown
## Unreleased
```

- Prepare the next release note draft when useful.

## Notes

This project intentionally avoids owning the JavaScript package manager or importmap setup. Host applications should install Tom Select and register the Stimulus controller using the documented public import paths through their existing JavaScript toolchain.
