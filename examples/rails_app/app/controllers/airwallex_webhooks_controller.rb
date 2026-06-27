# frozen_string_literal: true

class AirwallexWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = Airwallex::Webhook.construct_event(
      payload: request.body.read,
      signature: request.headers["x-signature"],
      timestamp: request.headers["x-timestamp"],
      secret: Rails.application.credentials.dig(:airwallex, :webhook_secret) || ENV.fetch("AIRWALLEX_WEBHOOK_SECRET")
    )

    case event["name"]
    when "payment_intent.succeeded"
      # handle payment success
    when "refund.accepted"
      # handle refund accepted
    end

    head :ok
  rescue Airwallex::WebhookSignatureError, Airwallex::InvalidResponseError
    head :bad_request
  end
end
