# frozen_string_literal: true

# Example Airwallex webhook controller for Rails.
# Copy into app/controllers/airwallex_webhooks_controller.rb
#
# Route (config/routes.rb):
#   post "/webhooks/airwallex", to: "airwallex_webhooks#create"
#
# class AirwallexWebhooksController < ApplicationController
#   skip_before_action :verify_authenticity_token
#
#   def create
#     event = Airwallex::Webhook.construct_event(
#       payload: request.body.read,
#       signature: request.headers["x-signature"],
#       timestamp: request.headers["x-timestamp"],
#       secret: webhook_secret
#     )
#
#     case event["name"]
#     when "payment_intent.succeeded"
#       # handle payment success
#     when "refund.accepted"
#       # handle refund accepted
#     end
#
#     head :ok
#   rescue Airwallex::WebhookSignatureError, Airwallex::InvalidResponseError
#     head :bad_request
#   end
#
#   private
#
#   def webhook_secret
#     Rails.application.credentials.dig(:airwallex, :webhook_secret) ||
#       ENV.fetch("AIRWALLEX_WEBHOOK_SECRET")
#   end
# end
