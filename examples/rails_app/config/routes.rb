Rails.application.routes.draw do
  post "/airwallex/payment_intents", to: "airwallex_demo#create_payment_intent"
  post "/airwallex/refunds", to: "airwallex_demo#create_refund"
  post "/webhooks/airwallex", to: "airwallex_webhooks#create"
end
