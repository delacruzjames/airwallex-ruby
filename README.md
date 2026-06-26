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

### Refunds

```ruby
refund = client.refunds.create(
  {
    payment_intent_id: "int_123",
    amount: 500,
    reason: "requested_by_customer",
    metadata: {
      order_id: "ORDER-1001"
    }
  },
  idempotency_key: "order-1001-refund-1"
)

puts refund["id"]

refund = client.refunds.retrieve("ref_123")

refunds = client.refunds.list(
  payment_intent_id: "int_123",
  page_num: 0,
  page_size: 20
)
```

### Idempotency

Use idempotency keys for payment creation, updates, cancellations, refunds, and any operation that should not be duplicated. The key should be unique per operation — a good pattern is your internal order ID plus the operation name.

```ruby
payment_intent = client.payment_intents.create(
  {
    amount: 1000,
    currency: "PHP",
    merchant_order_id: "ORDER-1001"
  },
  idempotency_key: "order-1001-create"
)

client.payment_intents.update(
  payment_intent["id"],
  { amount: 1500 },
  idempotency_key: "order-1001-update"
)

client.payment_intents.cancel(
  payment_intent["id"],
  idempotency_key: "order-1001-cancel"
)
```

Lower-level HTTP methods also accept `idempotency_key` on POST and PATCH:

```ruby
client.post("/some/path", { amount: 1000 }, {}, idempotency_key: "unique-key-123")
client.patch("/some/path", { amount: 1000 }, {}, idempotency_key: "unique-key-456")
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
