# frozen_string_literal: true

require "bundler/setup"
require "dotenv/load"
require "airwallex"
require "securerandom"
require "json"

module SandboxSupport
  module_function

  def client
    Airwallex::Client.new(
      client_id: ENV.fetch("AIRWALLEX_CLIENT_ID"),
      api_key: ENV.fetch("AIRWALLEX_API_KEY"),
      login_as: ENV["AIRWALLEX_LOGIN_AS"],
      environment: :demo
    )
  end

  def redact(value, visible: 6)
    return nil if value.nil? || value.empty?

    "#{value[0, visible]}...REDACTED"
  end

  def print_error(error)
    warn "Error: #{error.class}"
    warn "Message: #{error.message}"
    warn "Status: #{error.status}" if error.respond_to?(:status) && error.status
    warn "Code: #{error.code}" if error.respond_to?(:code) && error.code
    warn "Source: #{error.source}" if error.respond_to?(:source) && error.source
  end

  def env_int(name, default)
    value = ENV[name]
    return default if value.nil? || value.strip.empty?

    Integer(value)
  end

  def require_argument!(value, message)
    return value unless value.nil? || value.strip.empty?

    warn message
    exit 1
  end
end
