# frozen_string_literal: true

module Airwallex
  class Client
    attr_reader :client_id, :api_key, :environment, :timeout, :open_timeout, :logger

    def initialize(**options)
      config = Airwallex.configuration

      @client_id = options.fetch(:client_id, config.client_id)
      @api_key = options.fetch(:api_key, config.api_key)
      @environment = Configuration.validate_environment!(options.fetch(:environment, config.environment))
      @timeout = options.fetch(:timeout, config.timeout)
      @open_timeout = options.fetch(:open_timeout, config.open_timeout)
      @logger = options.fetch(:logger, config.logger)
    end

    def base_url
      Configuration::ENVIRONMENTS.fetch(environment)
    end
  end
end
