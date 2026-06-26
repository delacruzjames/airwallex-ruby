# airwallex-ruby

[![CI](https://github.com/delacruzjames/airwallex-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/delacruzjames/airwallex-ruby/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/github/license/delacruzjames/airwallex-ruby)](LICENSE.txt)

Unofficial Ruby SDK for Airwallex APIs.

## Disclaimer

This is an unofficial Ruby SDK for Airwallex. It is not maintained, sponsored, or endorsed by Airwallex.

Requires **Ruby 3.1+**.

## Features

- Configuration support
- Demo and production environments
- Authentication and token caching
- Faraday-based HTTP client
- Typed error handling
- PaymentIntents resource
- Refunds resource
- Idempotency key support
- Webhook signature verification
- Optional Rails initializer generator
- RSpec/WebMock test coverage

## Installation

Add this line to your application's Gemfile:

```ruby
gem "airwallex-ruby"
```

Then run:

```bash
bundle install
```

For local development against a checkout of this repository:

```ruby
gem "airwallex-ruby", path: "../airwallex-ruby"
```

## Basic configuration

```ruby
require "airwallex"

Airwallex.configure do |config|
  config.client_id = ENV["AIRWALLEX_CLIENT_ID"]
  config.api_key = ENV["AIRWALLEX_API_KEY"]
  config.login_as = ENV["AIRWALLEX_LOGIN_AS"]
  config.environment = :demo
  config.timeout = 30
  config.open_timeout = 10
end

client = Airwallex.client
```

## Direct client initialization

You can also construct a client directly without global configuration:

```ruby
client = Airwallex::Client.new(
  client_id: ENV["AIRWALLEX_CLIENT_ID"],
  api_key: ENV["AIRWALLEX_API_KEY"],
  login_as: ENV["AIRWALLEX_LOGIN_AS"],
  environment: :demo
)
```

## Environments

| Environment | Base URL |
|-------------|----------|
| `:demo` | `https://api-demo.airwallex.com/api/v1` |
| `:production` | `https://api.airwallex.com/api/v1` |

Set `config.environment` or pass `environment:` when creating a client.

## Authentication

Authentication is handled automatically. When an authenticated request is made, the client calls `POST /authentication/login` if no valid token is cached. The access token is stored in memory and reused until it expires. All authenticated requests include `Authorization: Bearer <token>`.

You can authenticate explicitly or check authentication state:

```ruby
client.authenticate
client.authenticated?
```

## PaymentIntents

### Create

```ruby
payment_intent = client.payment_intents.create(
  {
    amount: 1000,
    currency: "PHP",
    merchant_order_id: "ORDER-1001",
    return_url: "https://example.com/return"
  },
  idempotency_key: "order-1001-create"
)

puts payment_intent["id"]
puts payment_intent["client_secret"]
```

### Retrieve

```ruby
payment_intent = client.payment_intents.retrieve("int_123")
```

### Update

```ruby
payment_intent = client.payment_intents.update(
  "int_123",
  {
    amount: 1500
  },
  idempotency_key: "order-1001-update"
)
```

### Cancel

```ruby
client.payment_intents.cancel(
  "int_123",
  idempotency_key: "order-1001-cancel"
)
```

### List

```ruby
payment_intents = client.payment_intents.list(
  currency: "PHP",
  page_num: 0,
  page_size: 20
)
```

## Refunds

### Create

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
```

### Retrieve

```ruby
refund = client.refunds.retrieve("ref_123")
```

### List

```ruby
refunds = client.refunds.list(
  payment_intent_id: "int_123",
  page_num: 0,
  page_size: 20
)
```

## Idempotency

Use idempotency keys for payment creation, updates, cancellations, and refunds. The key should be unique per operation.

Good examples:

- `order-1001-create`
- `order-1001-update`
- `order-1001-refund-1`

Pass `idempotency_key:` to resource methods or lower-level `client.post` / `client.patch` calls. The SDK sends the key as the `x-idempotency-key` header.

## Webhook verification

Verify incoming webhook requests using the raw request body and Airwallex signature headers:

```ruby
raw_body = request.body.read

event = Airwallex::Webhook.construct_event(
  payload: raw_body,
  signature: request.headers["x-signature"],
  timestamp: request.headers["x-timestamp"],
  secret: ENV.fetch("AIRWALLEX_WEBHOOK_SECRET")
)

case event["name"]
when "payment_intent.succeeded"
  # handle payment success
when "refund.accepted"
  # handle refund accepted
end
```

Important notes:

- Always use the raw request body.
- Verify the signature before parsing JSON (`construct_event` does this for you).
- Old timestamps are rejected by default (300 second tolerance).
- Signature comparison is timing-safe.

## Rails installation

Run the generator:

```bash
rails generate airwallex:install
```

This creates:

```
config/initializers/airwallex.rb
```

Credentials example:

```yaml
airwallex:
  client_id: your_client_id
  api_key: your_api_key
  login_as: optional_account_id
  webhook_secret: your_webhook_secret
```

Rails webhook controller example:

```ruby
class AirwallexWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = Airwallex::Webhook.construct_event(
      payload: request.body.read,
      signature: request.headers["x-signature"],
      timestamp: request.headers["x-timestamp"],
      secret: Rails.application.credentials.dig(:airwallex, :webhook_secret) || ENV.fetch("AIRWALLEX_WEBHOOK_SECRET")
    )

    case event["name"]
    when "payment_intent.succeeded"
      # handle payment success
    when "refund.accepted"
      # handle refund accepted
    end

    head :ok
  rescue Airwallex::WebhookSignatureError, Airwallex::InvalidResponseError
    head :bad_request
  end
end
```

Route:

```ruby
post "/webhooks/airwallex", to: "airwallex_webhooks#create"
```

See also [examples/rails_webhook_controller.rb](examples/rails_webhook_controller.rb).

## Error handling

The SDK raises typed errors for configuration, authentication, HTTP status codes, timeouts, invalid responses, and webhook verification failures.

| Error | Description |
|-------|-------------|
| `Airwallex::Error` | Base error for all SDK errors |
| `Airwallex::ConfigurationError` | Missing or invalid configuration |
| `Airwallex::AuthenticationError` | Login or token handling failed |
| `Airwallex::ArgumentError` | Invalid method arguments |
| `Airwallex::HTTPError` | Base class for HTTP error responses |
| `Airwallex::BadRequestError` | HTTP 400 |
| `Airwallex::UnauthorizedError` | HTTP 401 |
| `Airwallex::ForbiddenError` | HTTP 403 |
| `Airwallex::NotFoundError` | HTTP 404 |
| `Airwallex::ConflictError` | HTTP 409 |
| `Airwallex::RateLimitError` | HTTP 429 |
| `Airwallex::ServerError` | HTTP 5xx |
| `Airwallex::TimeoutError` | Request timeout or connection failure |
| `Airwallex::InvalidResponseError` | Invalid JSON or webhook payload |
| `Airwallex::WebhookSignatureError` | Webhook signature or timestamp verification failed |

Example:

```ruby
begin
  client.payment_intents.retrieve("int_123")
rescue Airwallex::NotFoundError => e
  puts e.status
  puts e.code
  puts e.message
rescue Airwallex::RateLimitError
  # retry later
rescue Airwallex::Error => e
  # generic Airwallex SDK error
end
```

## Release / Local Installation

Build the gem from a checkout:

```bash
gem build airwallex-ruby.gemspec
```

Or use the Rake task (output goes to `pkg/`):

```bash
bundle exec rake build
```

Install locally:

```bash
gem install ./airwallex-ruby-0.1.0.gem
# or, after rake build:
gem install ./pkg/airwallex-ruby-0.1.0.gem
```

Test in IRB:

```ruby
require "airwallex"
Airwallex::VERSION
# => "0.1.0"
```

## Publishing

Do not publish until the release checklist is complete and changes have been reviewed.

### Automated (recommended)

After review, tag and push. GitHub Actions publishes to RubyGems and creates a GitHub Release:

```bash
git tag v0.1.0
git push origin main
git push origin v0.1.0
```

Requires the `RUBYGEMS_API_KEY` repository secret. See [docs/release.md](docs/release.md).

### Manual

```bash
gem push airwallex-ruby-0.1.0.gem
# or, after rake build:
gem push pkg/airwallex-ruby-0.1.0.gem
```

See [docs/release.md](docs/release.md) for the full release checklist.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
bundle exec rake build
```

See [docs/airwallex-research.md](docs/airwallex-research.md) for API notes and planned resources.

## Testing

- RSpec is used for the test suite.
- WebMock is used to stub Airwallex API requests.
- No real Airwallex credentials are required for unit tests.

## Roadmap

- PaymentIntent confirm/capture support
- PaymentAttempts resource
- Customers resource
- PaymentConsents resource
- Transfers resource
- Balances resource
- Transactions resource
- File uploads
- More Rails generators
- Integration test mode

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add specs for your changes
4. Run the test suite (`bundle exec rspec`) and RuboCop (`bundle exec rubocop`)
5. Open a pull request

## Examples

Runnable and copy-paste examples live in the [examples/](examples/) directory:

- [basic_configuration.rb](examples/basic_configuration.rb)
- [payment_intent_create.rb](examples/payment_intent_create.rb)
- [refund_create.rb](examples/refund_create.rb)
- [webhook_verification.rb](examples/webhook_verification.rb)
- [rails_webhook_controller.rb](examples/rails_webhook_controller.rb)

## License

MIT — see [LICENSE.txt](LICENSE.txt).
