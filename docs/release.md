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
- git push origin develop

Publishing a GitHub Release from **develop** triggers the [Release workflow](../.github/workflows/release.yml), which:

1. Merges `develop` into `master`
2. Runs RuboCop and RSpec
3. Builds the gem
4. Publishes to RubyGems
5. Attaches the `.gem` file to the GitHub Release

### Create the release on GitHub

1. Open **Releases → Draft a new release**
2. Set **Target** to `develop`
3. Create tag `v0.1.0` (must match `Airwallex::VERSION`)
4. Add release notes and click **Publish release**

### GitHub Actions setup

Preferred: configure [RubyGems trusted publishing](https://guides.rubygems.org/trusted-publishing/) for this repository with workflow file `release.yml`.

Fallback: add a repository secret:

| Secret | Description |
|--------|-------------|
| `RUBYGEMS_API_KEY` | RubyGems API key with push access |

Because this gem sets `rubygems_mfa_required`, create the API key at [rubygems.org](https://rubygems.org/sign_in) after MFA is enabled. The key must include push permission for `airwallex-ruby`.

Manual release retry (without publishing a new GitHub Release):

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
