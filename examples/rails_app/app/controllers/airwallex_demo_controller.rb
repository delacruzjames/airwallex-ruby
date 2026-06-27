# frozen_string_literal: true

class AirwallexDemoController < ApplicationController
  def create_payment_intent
    payment_intent = Airwallex.client.payment_intents.create(
      {
        amount: params.fetch(:amount),
        currency: params.fetch(:currency, "PHP"),
        merchant_order_id: params.fetch(:merchant_order_id),
        return_url: params[:return_url]
      },
      idempotency_key: "payment-intent-#{params.fetch(:merchant_order_id)}"
    )

    render json: payment_intent
  rescue Airwallex::Error => e
    render json: { error: e.message }, status: :bad_request
  end

  def create_refund
    refund = Airwallex.client.refunds.create(
      {
        payment_intent_id: params.fetch(:payment_intent_id),
        amount: params.fetch(:amount),
        reason: params[:reason] || "requested_by_customer"
      },
      idempotency_key: "refund-#{params.fetch(:payment_intent_id)}-#{Time.now.to_i}"
    )

    render json: refund
  rescue Airwallex::Error => e
    render json: { error: e.message }, status: :bad_request
  end
end
