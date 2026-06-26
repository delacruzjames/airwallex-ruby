# frozen_string_literal: true

RSpec.describe "documentation quality" do
  let(:readme) { File.read(File.expand_path("../../README.md", __dir__)) }
  let(:root) { File.expand_path("../..", __dir__) }

  it "README includes Unofficial Ruby SDK" do
    expect(readme).to include("Unofficial Ruby SDK")
  end

  it "README includes installation section" do
    expect(readme).to include("## Installation")
    expect(readme).to include('gem "airwallex-ruby"')
  end

  it "README includes configuration example" do
    expect(readme).to include("## Basic configuration")
    expect(readme).to include("Airwallex.configure")
    expect(readme).to include("Airwallex.client")
  end

  it "README includes PaymentIntents example" do
    expect(readme).to include("## PaymentIntents")
    expect(readme).to include("client.payment_intents.create")
    expect(readme).to include("idempotency_key:")
  end

  it "README includes Refunds example" do
    expect(readme).to include("## Refunds")
    expect(readme).to include("client.refunds.create")
  end

  it "README includes Webhook verification example" do
    expect(readme).to include("## Webhook verification")
    expect(readme).to include("Airwallex::Webhook.construct_event")
  end

  it "README includes Rails installation example" do
    expect(readme).to include("## Rails installation")
    expect(readme).to include("rails generate airwallex:install")
  end

  it "README includes Error handling section" do
    expect(readme).to include("## Error handling")
    expect(readme).to include("Airwallex::NotFoundError")
    expect(readme).to include("Airwallex::WebhookSignatureError")
  end

  %w[
    basic_configuration.rb
    payment_intent_create.rb
    refund_create.rb
    webhook_verification.rb
    rails_webhook_controller.rb
  ].each do |filename|
    it "examples/#{filename} exists" do
      path = File.join(root, "examples", filename)
      expect(File).to exist(path)
    end
  end
end
