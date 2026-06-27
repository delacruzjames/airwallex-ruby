# Examples

## Basic Ruby usage

Configure the SDK and create a client:

```ruby
require "airwallex"

Airwallex.configure do |config|
  config.client_id = ENV["AIRWALLEX_CLIENT_ID"]
  config.api_key = ENV["AIRWALLEX_API_KEY"]
  config.login_as = ENV["AIRWALLEX_LOGIN_AS"]
  config.environment = :demo
end

client = Airwallex.client
```

See [examples/basic_configuration.rb](../examples/basic_configuration.rb).

## Rails usage

In a Rails app, run the install generator:

```bash
rails generate airwallex:install
```

Then use the configured client in controllers or services:

```ruby
payment_intent = Airwallex.client.payment_intents.create(
  {
    amount: 1000,
    currency: "PHP",
    merchant_order_id: "ORDER-1001"
  },
  idempotency_key: "order-1001-create"
)
```

See the lightweight sample app in [examples/rails_app](../examples/rails_app/).

## Webhook usage

Verify incoming webhook requests with the raw body and signature headers:

```ruby
event = Airwallex::Webhook.construct_event(
  payload: request.body.read,
  signature: request.headers["x-signature"],
  timestamp: request.headers["x-timestamp"],
  secret: ENV.fetch("AIRWALLEX_WEBHOOK_SECRET")
)
```

See [examples/webhook_verification.rb](../examples/webhook_verification.rb) and [examples/rails_webhook_controller.rb](../examples/rails_webhook_controller.rb).

## Local sample app location

A minimal Rails integration example lives at:

```
examples/rails_app/
```

It demonstrates initializer configuration, PaymentIntent creation, Refund creation, webhook verification, and example routes without requiring real Airwallex credentials to boot.
