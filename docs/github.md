# GitHub Repository Checklist

## Required files

- README.md
- CHANGELOG.md
- LICENSE
- CONTRIBUTING.md
- SECURITY.md
- CODE_OF_CONDUCT.md
- .github/workflows/ci.yml
- .github/ISSUE_TEMPLATE/bug_report.md
- .github/ISSUE_TEMPLATE/feature_request.md
- .github/pull_request_template.md

## Before opening repository publicly

- Verify no `.env` files are committed.
- Verify no real Airwallex credentials are present.
- Run `bundle exec rspec`.
- Run `bundle exec rubocop`.
- Run `bundle exec rake build`.
- Confirm README examples are accurate.
- Confirm gemspec metadata points to the correct GitHub repo.
