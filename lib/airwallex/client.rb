# frozen_string_literal: true

module Airwallex
  class Client
    attr_reader :config

    def initialize(config)
      @config = config
    end
  end
end
