# Rails Fields Kit Development

This document summarizes the local development checks that should stay aligned with CI.

## Install dependencies

```bash
bundle install
```

## Lint locally

```bash
bundle exec standardrb
```

## Test locally

```bash
bundle exec rspec
```

## Build locally

```bash
bundle exec rake build
```

These are the primary repository checks used in CI:

- `bundle exec standardrb`
- `bundle exec rspec`
- `bundle exec rake build`

When build fails, check these first:

- `rails_fields_kit.gemspec` metadata URLs
- missing files in `specification.files`
- generator template paths
- documentation paths referenced from README
- RubyGems warnings about metadata, licenses, or required Ruby version

## Release-related checks

Before release, also review:

- `CHANGELOG.md`
- `doc/release.md`
- `rails_fields_kit.gemspec`
- `lib/rails_fields_kit/version.rb`

## CI policy

CI should stay aligned with the local commands above. During active development, run the local checks first and use GitHub Actions to confirm the branch head when the change is ready for review.
