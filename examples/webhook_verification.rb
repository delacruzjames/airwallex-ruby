# frozen_string_literal: true

# Verify an Airwallex webhook payload and parse the event.
#
# Usage:
#   AIRWALLEX_WEBHOOK_SECRET=... ruby examples/webhook_verification.rb

require "airwallex"
require "openssl"

secret = ENV.fetch("AIRWALLEX_WEBHOOK_SECRET")
payload = '{"name":"payment_intent.succeeded","data":{}}'
timestamp = Time.now.to_i.to_s
signature = OpenSSL::HMAC.hexdigest("SHA256", secret, timestamp + payload)

event = Airwallex::Webhook.construct_event(
  payload: payload,
  signature: signature,
  timestamp: timestamp,
  secret: secret
)

puts event["name"]
