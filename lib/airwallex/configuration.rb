# frozen_string_literal: true

module Airwallex
  class Configuration
    ENVIRONMENTS = {
      demo: "https://api-demo.airwallex.com/api/v1",
      production: "https://api.airwallex.com/api/v1"
    }.freeze

    attr_accessor :client_id, :api_key, :environment

    def initialize
      @environment = :demo
    end

    def api_base_url
      ENVIRONMENTS.fetch(environment) do
        raise ArgumentError, "Unknown environment: #{environment.inspect}"
      end
    end
  end
end
