# Rails Fields Kit Development

This document summarizes the local development checks used while CI is intentionally deferred.

## Test locally

```bash
git pull
bundle install
bundle exec rspec
```

During active development, this is the primary verification command.

## Build locally

```bash
bundle exec rake build
```

This checks that the gemspec can be packaged and that packaged files are available.

## Release-related checks

Before release, also review:

- `CHANGELOG.md`
- `doc/release.md`
- `rails_fields_kit.gemspec`
- `lib/rails_fields_kit/version.rb`

## CI policy

CI should be saved for the final release stage or moments where the cost is justified. While iterating quickly, prefer local `bundle exec rspec` and `bundle exec rake build`.
