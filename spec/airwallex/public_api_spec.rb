# frozen_string_literal: true

RSpec.describe "public API" do
  it "loads the gem" do
    expect { require "airwallex" }.not_to raise_error
  end

  it "exposes module-level configuration" do
    expect(Airwallex).to respond_to(:configure)
    expect(Airwallex).to respond_to(:configuration)
    expect(Airwallex).to respond_to(:reset_configuration!)
    expect(Airwallex).to respond_to(:client)
  end

  it "exposes core classes and modules" do
    expect(Airwallex::Client).to be_a(Class)
    expect(Airwallex::Webhook).to be_a(Module)
  end

  it "exposes client resources" do
    client = Airwallex::Client.new(
      client_id: "client_id",
      api_key: "api_key",
      environment: :demo
    )

    expect(client).to respond_to(:authentication)
    expect(client).to respond_to(:payment_intents)
    expect(client).to respond_to(:refunds)
  end
end
