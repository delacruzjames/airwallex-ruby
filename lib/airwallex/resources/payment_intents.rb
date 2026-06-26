# frozen_string_literal: true

module Airwallex
  module Resources
    class PaymentIntents < BaseResource
      def create(params = {})
        validate_params!(params)
        post("/pa/payment_intents/create", params)
      end

      def retrieve(id)
        validate_id!(id)
        get("/pa/payment_intents/#{id}")
      end

      def update(id, params = {})
        validate_id!(id)
        validate_params!(params)
        post("/pa/payment_intents/#{id}/update", params)
      end

      def cancel(id)
        validate_id!(id)
        post("/pa/payment_intents/#{id}/cancel")
      end

      def list(params = {})
        validate_params!(params)
        get("/pa/payment_intents", params)
      end
    end
  end
end
