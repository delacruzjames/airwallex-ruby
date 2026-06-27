# frozen_string_literal: true

require_relative "support"

client = SandboxSupport.client

begin
  client.authenticate

  puts "Authenticated: true"
  puts "Access token: #{SandboxSupport.redact(client.access_token)}"
  puts "Expires at: #{client.token_expires_at.utc.strftime('%Y-%m-%d %H:%M:%S UTC')}"
  puts "Base URL: #{client.base_url}"
rescue Airwallex::Error => e
  SandboxSupport.print_error(e)
  exit 1
end
