# frozen_string_literal: true

require_relative "airwallex/version"
require_relative "airwallex/errors"
require_relative "airwallex/configuration"
require_relative "airwallex/client"
require_relative "airwallex/resources/base_resource"
require_relative "airwallex/resources/authentication"

module Airwallex
  module Resources
  end

  class << self
    attr_accessor :config

    def configure
      self.config ||= Configuration.new
      yield(config) if block_given?
      config
    end

    def client
      @client ||= Client.new(config || Configuration.new)
    end
  end
end
