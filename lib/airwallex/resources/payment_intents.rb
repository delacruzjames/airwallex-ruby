# frozen_string_literal: true

module Airwallex
  module Resources
    class PaymentIntents < BaseResource
      def create(params = {}, idempotency_key: nil)
        validate_params!(params)
        post("/pa/payment_intents/create", params, {}, idempotency_key: idempotency_key)
      end

      def retrieve(id)
        validate_id!(id)
        get("/pa/payment_intents/#{id}")
      end

      def update(id, params = {}, idempotency_key: nil)
        validate_id!(id)
        validate_params!(params)
        post("/pa/payment_intents/#{id}/update", params, {}, idempotency_key: idempotency_key)
      end

      def cancel(id, idempotency_key: nil)
        validate_id!(id)
        post("/pa/payment_intents/#{id}/cancel", {}, {}, idempotency_key: idempotency_key)
      end

      def list(params = {})
        validate_params!(params)
        get("/pa/payment_intents", params)
      end
    end
  end
end
