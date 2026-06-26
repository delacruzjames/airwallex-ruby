# frozen_string_literal: true

module Airwallex
  module Resources
    class BaseResource
      attr_reader :client

      def initialize(client)
        @client = client
      end
    end
  end
end
