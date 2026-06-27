# frozen_string_literal: true

require "openssl"
require_relative "support"

secret = ENV.fetch("AIRWALLEX_WEBHOOK_SECRET")

payload = '{"name":"payment_intent.succeeded","data":{"object":{"id":"int_sandbox_test"}}}'
timestamp = Time.now.to_i.to_s
signature = OpenSSL::HMAC.hexdigest(
  "SHA256",
  secret,
  timestamp + payload
)

begin
  event = Airwallex::Webhook.construct_event(
    payload: payload,
    signature: signature,
    timestamp: timestamp,
    secret: secret
  )

  puts "Webhook verified: true"
  puts "Event name: #{event['name']}"
  puts "Object id: #{event.dig('data', 'object', 'id')}"
rescue Airwallex::Error => e
  SandboxSupport.print_error(e)
  exit 1
end
