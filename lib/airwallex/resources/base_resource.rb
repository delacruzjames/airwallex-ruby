# frozen_string_literal: true

module Airwallex
  module Resources
    class BaseResource
      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      def get(path, params = {}, headers = {}, authenticated: true)
        client.get(path, params, headers, authenticated: authenticated)
      end

      def post(path, body = {}, headers = {}, authenticated: true)
        client.post(path, body, headers, authenticated: authenticated)
      end

      def patch(path, body = {}, headers = {}, authenticated: true)
        client.patch(path, body, headers, authenticated: authenticated)
      end

      def delete(path, params = {}, headers = {}, authenticated: true)
        client.delete(path, params, headers, authenticated: authenticated)
      end

      def validate_id!(id, name = "id")
        raise Airwallex::ArgumentError, "#{name} is required" if id.nil? || id.to_s.strip.empty?
      end

      def validate_params!(params)
        raise Airwallex::ArgumentError, "params must be a Hash" unless params.is_a?(Hash)
      end
    end
  end
end
