# frozen_string_literal: true

require_relative "support"

payment_intent_id = SandboxSupport.require_argument!(
  ARGV[0],
  "Usage: ruby scripts/sandbox/create_refund.rb int_xxx"
)

client = SandboxSupport.client

params = {
  payment_intent_id: payment_intent_id,
  amount: SandboxSupport.env_int("AIRWALLEX_SANDBOX_REFUND_AMOUNT", 100),
  reason: "requested_by_customer",
  metadata: {
    source: "airwallex-ruby-sandbox-script"
  }
}

idempotency_key = "sandbox-refund-#{payment_intent_id}-#{SecureRandom.hex(4)}"

begin
  refund = client.refunds.create(params, idempotency_key: idempotency_key)

  puts "Refund id: #{refund['id']}"
  puts "Status: #{refund['status']}" if refund["status"]
  puts "Amount: #{refund['amount']}" if refund.key?("amount")
rescue Airwallex::Error => e
  SandboxSupport.print_error(e)
  exit 1
end
