# frozen_string_literal: true

# Basic global configuration and client access.
#
# Usage:
#   AIRWALLEX_CLIENT_ID=... AIRWALLEX_API_KEY=... ruby examples/basic_configuration.rb

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

puts "Airwallex client ready (#{client.environment} environment)"
