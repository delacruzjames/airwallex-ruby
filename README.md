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

### Payment Intents

```ruby
client = Airwallex::Client.new(
  client_id: ENV["AIRWALLEX_CLIENT_ID"],
  api_key: ENV["AIRWALLEX_API_KEY"],
  environment: :demo
)

payment_intent = client.payment_intents.create(
  amount: 1000,
  currency: "PHP",
  merchant_order_id: "ORDER-1001",
  return_url: "https://example.com/return"
)

puts payment_intent["id"]
puts payment_intent["client_secret"]
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

See [docs/airwallex-research.md](docs/airwallex-research.md) for API notes and planned resources.

## License

MIT — see [LICENSE.txt](LICENSE.txt).
