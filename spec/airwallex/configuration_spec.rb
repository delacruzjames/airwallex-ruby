# frozen_string_literal: true

RSpec.describe Airwallex::Configuration do
  it "can be initialized" do
    config = described_class.new

    expect(config).to be_a(described_class)
    expect(config.environment).to eq(:demo)
  end

  it "stores credentials and environment" do
    config = described_class.new
    config.client_id = "client_id"
    config.api_key = "api_key"
    config.environment = :production

    expect(config.client_id).to eq("client_id")
    expect(config.api_key).to eq("api_key")
    expect(config.api_base_url).to eq("https://api.airwallex.com/api/v1")
  end
end
