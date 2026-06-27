# frozen_string_literal: true

require_relative "support"

payment_intent_id = SandboxSupport.require_argument!(
  ARGV[0],
  "Usage: ruby scripts/sandbox/retrieve_payment_intent.rb int_xxx"
)

client = SandboxSupport.client

begin
  payment_intent = client.payment_intents.retrieve(payment_intent_id)

  puts "PaymentIntent id: #{payment_intent['id']}"
  puts "Status: #{payment_intent['status']}" if payment_intent["status"]
  puts "Currency: #{payment_intent['currency']}" if payment_intent["currency"]
  puts "Amount: #{payment_intent['amount']}" if payment_intent.key?("amount")
  puts "Created at: #{payment_intent['created_at']}" if payment_intent["created_at"]
rescue Airwallex::Error => e
  SandboxSupport.print_error(e)
  exit 1
end
