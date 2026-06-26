# frozen_string_literal: true

Airwallex.configure do |config|
  config.client_id = Rails.application.credentials.dig(:airwallex, :client_id) || ENV["AIRWALLEX_CLIENT_ID"]
  config.api_key = Rails.application.credentials.dig(:airwallex, :api_key) || ENV["AIRWALLEX_API_KEY"]
  config.login_as = Rails.application.credentials.dig(:airwallex, :login_as) || ENV["AIRWALLEX_LOGIN_AS"]
  config.environment = Rails.env.production? ? :production : :demo
  config.timeout = 30
  config.open_timeout = 10
end
