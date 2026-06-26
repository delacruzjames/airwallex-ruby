# frozen_string_literal: true

RSpec.describe Airwallex::Client do
  it "can be initialized" do
    config = Airwallex::Configuration.new
    client = described_class.new(config)

    expect(client).to be_a(described_class)
    expect(client.config).to eq(config)
  end

  it "is available from Airwallex.client after configure" do
    Airwallex.configure do |config|
      config.client_id = "test_client_id"
      config.api_key = "test_api_key"
      config.environment = :demo
    end

    expect(Airwallex.client).to be_a(described_class)
  end
end

RSpec.describe Airwallex do
  it "defines VERSION" do
    expect(Airwallex::VERSION).to eq("0.1.0")
  end
end

RSpec.describe Airwallex::Error do
  it "inherits from StandardError" do
    expect(described_class).to be < StandardError
  end
end
