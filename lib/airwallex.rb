# frozen_string_literal: true

require_relative "airwallex/version"
require_relative "airwallex/errors"
require_relative "airwallex/configuration"
require_relative "airwallex/client"
require_relative "airwallex/resources/base_resource"
require_relative "airwallex/resources/authentication"
require_relative "airwallex/resources/payment_intents"
require_relative "airwallex/resources/refunds"

module Airwallex
  module Resources
  end

  class << self
    def configure
      yield(configuration) if block_given?
      @client = nil
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def reset_configuration!
      @configuration = Configuration.new
      @client = nil
    end

    def client
      @client ||= Client.new
    end
  end
end
