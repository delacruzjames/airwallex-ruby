# frozen_string_literal: true

# Create a PaymentIntent with an idempotency key.
#
# Usage:
#   AIRWALLEX_CLIENT_ID=... AIRWALLEX_API_KEY=... ruby examples/payment_intent_create.rb

require "airwallex"

client = Airwallex::Client.new(
  client_id: ENV["AIRWALLEX_CLIENT_ID"],
  api_key: ENV["AIRWALLEX_API_KEY"],
  login_as: ENV["AIRWALLEX_LOGIN_AS"],
  environment: :demo
)

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
