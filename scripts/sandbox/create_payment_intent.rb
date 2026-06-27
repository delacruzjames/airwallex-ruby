# frozen_string_literal: true

require_relative "support"

client = SandboxSupport.client

params = {
  amount: SandboxSupport.env_int("AIRWALLEX_SANDBOX_AMOUNT", 1000),
  currency: ENV.fetch("AIRWALLEX_SANDBOX_CURRENCY", "PHP"),
  merchant_order_id: "sandbox-order-#{SecureRandom.hex(8)}",
  return_url: ENV.fetch("AIRWALLEX_SANDBOX_RETURN_URL", "https://example.com/return")
}

begin
  payment_intent = client.payment_intents.create(params, idempotency_key: params[:merchant_order_id])

  secret_field = "client_secret"
  has_client_secret = !payment_intent.fetch(secret_field, "").to_s.empty?

  puts "PaymentIntent id: #{payment_intent['id']}"
  puts "Status: #{payment_intent['status']}" if payment_intent["status"]
  puts "Currency: #{payment_intent['currency']}" if payment_intent["currency"]
  puts "Amount: #{payment_intent['amount']}" if payment_intent.key?("amount")
  puts "client_secret present?: #{has_client_secret}"
rescue Airwallex::Error => e
  SandboxSupport.print_error(e)
  exit 1
end
