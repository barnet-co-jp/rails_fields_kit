# Rails Fields Kit Release Guide

This guide describes the lightweight release flow for Rails Fields Kit.

## Policy

- Rails Fields Kit targets Rails 7.0 and newer.
- CI is intentionally not required during active development.
- During development, verify changes locally with:

```bash
git pull
bundle exec rspec
```

- Run CI only near the final release stage when it is worth spending CI minutes.

## Pre-release checklist

1. Pull the latest main branch.

   ```bash
   git pull
   ```

2. Install dependencies.

   ```bash
   bundle install
   ```

3. Run the test suite locally.

   ```bash
   bundle exec rspec
   ```

4. Review documentation.

   - `README.md`
   - `CHANGELOG.md`
   - `doc/setup.md`
   - `doc/field_helpers.md`
   - `doc/controller_helpers.md`
   - `doc/configuration.md`
   - `doc/events.md`

5. Confirm version.

   ```ruby
   # lib/rails_fields_kit/version.rb
   RailsFieldsKit::VERSION = "0.1.0"
   ```

6. Build the gem locally.

   ```bash
   bundle exec rake build
   ```

7. Optionally install the built gem into a sample Rails 7+ application and verify:

   - `rails generate rails_fields_kit:install`
   - Stimulus controller registration
   - Tom Select CSS loading
   - `rfk_combobox` with remote search
   - `rfk_find_with` selected preload
   - `rfk_create_with` create-on-the-fly

## Release steps

1. Update `CHANGELOG.md`.

   Move entries from `Unreleased` to the target version, for example:

   ```markdown
   ## 0.1.0 - YYYY-MM-DD
   ```

2. Commit release metadata.

   ```bash
   git add CHANGELOG.md lib/rails_fields_kit/version.rb
   git commit -m "Prepare 0.1.0 release"
   ```

3. Build the gem.

   ```bash
   bundle exec rake build
   ```

4. Publish the gem when ready.

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

## Notes

This project intentionally avoids owning the JavaScript package manager or importmap setup. Host applications should install Tom Select and register the Stimulus controller using their existing JavaScript toolchain.
