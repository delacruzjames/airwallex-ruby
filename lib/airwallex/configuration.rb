# frozen_string_literal: true

module Airwallex
  class Configuration
    ENVIRONMENTS = {
      demo: "https://api-demo.airwallex.com/api/v1",
      production: "https://api.airwallex.com/api/v1"
    }.freeze

    attr_accessor :client_id, :api_key, :timeout, :open_timeout, :logger
    attr_reader :environment

    def initialize
      @environment = :demo
      @timeout = 30
      @open_timeout = 10
      @logger = nil
    end

    def environment=(value)
      self.class.validate_environment!(value)
      @environment = value
    end

    def base_url
      ENVIRONMENTS.fetch(environment)
    end

    alias api_base_url base_url

    def self.validate_environment!(environment)
      return environment if ENVIRONMENTS.key?(environment)

      valid = ENVIRONMENTS.keys.map(&:inspect).join(", ")
      raise ConfigurationError, "Invalid environment: #{environment.inspect}. Valid environments are: #{valid}"
    end
  end
end
