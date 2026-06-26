# frozen_string_literal: true

# Create a refund with an idempotency key.
#
# Usage:
#   AIRWALLEX_CLIENT_ID=... AIRWALLEX_API_KEY=... ruby examples/refund_create.rb

require "airwallex"

client = Airwallex::Client.new(
  client_id: ENV["AIRWALLEX_CLIENT_ID"],
  api_key: ENV["AIRWALLEX_API_KEY"],
  login_as: ENV["AIRWALLEX_LOGIN_AS"],
  environment: :demo
)

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
