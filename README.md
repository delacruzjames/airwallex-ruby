# airwallex-ruby

Unofficial Ruby SDK for [Airwallex](https://www.airwallex.com/) APIs.

> **Disclaimer:** This is **not** an official Airwallex SDK. It is maintained independently. For official integrations, refer to [Airwallex documentation](https://www.airwallex.com/docs).

Requires **Ruby 3.1+**.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "airwallex-ruby"
```

Then run:

```bash
bundle install
```

Or install the gem directly (once published):

```bash
gem install airwallex-ruby
```

## Usage

```ruby
require "airwallex"

Airwallex.configure do |config|
  config.client_id = ENV["AIRWALLEX_CLIENT_ID"]
  config.api_key = ENV["AIRWALLEX_API_KEY"]
  config.environment = :demo # or :production
end

client = Airwallex.client
```

Phase 1 provides the foundation only. HTTP requests and resource methods will be added in later phases.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

See [docs/airwallex-research.md](docs/airwallex-research.md) for API notes and planned resources.

## License

MIT — see [LICENSE.txt](LICENSE.txt).
