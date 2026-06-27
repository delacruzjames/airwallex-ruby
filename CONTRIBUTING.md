# Contributing

Thank you for considering contributing to airwallex-ruby.

## Development setup

```bash
bundle install
```

## Running tests

```bash
bundle exec rspec
```

## Running lint

```bash
bundle exec rubocop
```

## Running all checks

```bash
bundle exec rspec
bundle exec rubocop
bundle exec rake build
```

## Pull request guidelines

- Keep changes focused.
- Add specs for new behavior.
- Update README.md when public API changes.
- Update CHANGELOG.md for user-facing changes.
- Do not commit real Airwallex credentials.
- Do not use real production API keys in tests.

## Commit style

Use clear commit messages.

Examples:

```
Add PaymentIntents resource
Fix webhook signature validation
Document Rails initializer usage
```
