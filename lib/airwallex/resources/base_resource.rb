# frozen_string_literal: true

module Airwallex
  module Resources
    class BaseResource
      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      def get(path, params = {}, headers = {}, **options)
        client.get(path, params, headers, **options)
      end

      def post(path, body = {}, headers = {}, **options)
        client.post(path, body, headers, **options)
      end

      def patch(path, body = {}, headers = {}, **options)
        client.patch(path, body, headers, **options)
      end

      def delete(path, params = {}, headers = {}, **options)
        client.delete(path, params, headers, **options)
      end

      def validate_idempotency_key!(idempotency_key)
        return if idempotency_key.nil?

        return if idempotency_key.is_a?(String) && !idempotency_key.strip.empty?

        raise Airwallex::ArgumentError, "idempotency_key must be a non-empty String"
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
