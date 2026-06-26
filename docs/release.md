# Release Checklist

## Before release

- bundle install
- bundle exec rspec
- bundle exec rubocop
- bundle exec rake build
- gem install ./pkg/airwallex-ruby-0.1.0.gem
- irb
- require "airwallex"
- Airwallex::VERSION

## Git release

- git status
- git add .
- git commit -m "Prepare v0.1.0 release"
- git tag v0.1.0
- git push origin main
- git push origin v0.1.0

Pushing a version tag triggers the [Release workflow](../.github/workflows/release.yml), which runs RuboCop, RSpec, builds the gem, publishes to RubyGems, and creates a GitHub Release.

### GitHub Actions setup

Add a repository secret:

| Secret | Description |
|--------|-------------|
| `RUBYGEMS_API_KEY` | RubyGems API key with push access |

Because this gem sets `rubygems_mfa_required`, create the API key at [rubygems.org](https://rubygems.org/sign_in) after MFA is enabled. The key must include push permission for `airwallex-ruby`.

Manual release (without pushing a tag first):

1. Open **Actions → Release → Run workflow**
2. Enter the tag (for example `v0.1.0`)

The workflow verifies that the tag matches `Airwallex::VERSION` before publishing.

## RubyGems release

- gem push pkg/airwallex-ruby-0.1.0.gem

Only publish after final review.

## Post-release verification

- gem install airwallex-ruby
- irb
- require "airwallex"
- Airwallex::VERSION
