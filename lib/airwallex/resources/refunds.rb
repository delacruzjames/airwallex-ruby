# frozen_string_literal: true

module Airwallex
  module Resources
    class Refunds < BaseResource
      def create(params = {}, idempotency_key: nil)
        validate_params!(params)
        post("/pa/refunds/create", params, {}, idempotency_key: idempotency_key)
      end

      def retrieve(id)
        validate_id!(id)
        get("/pa/refunds/#{id}")
      end

      def list(params = {})
        validate_params!(params)
        get("/pa/refunds", params)
      end
    end
  end
end
