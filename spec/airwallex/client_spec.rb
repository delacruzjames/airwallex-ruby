# frozen_string_literal: true

RSpec.describe Airwallex::Client do
  describe ".new" do
    it "accepts direct options" do
      client = described_class.new(
        client_id: "client_id",
        api_key: "api_key",
        environment: :demo
      )

      expect(client.client_id).to eq("client_id")
      expect(client.api_key).to eq("api_key")
      expect(client.environment).to eq(:demo)
    end

    it "initializes from global configuration when options are omitted" do
      Airwallex.configure do |config|
        config.client_id = "global_client_id"
        config.api_key = "global_api_key"
        config.environment = :production
        config.timeout = 45
        config.open_timeout = 15
      end

      client = described_class.new

      expect(client.client_id).to eq("global_client_id")
      expect(client.api_key).to eq("global_api_key")
      expect(client.environment).to eq(:production)
      expect(client.timeout).to eq(45)
      expect(client.open_timeout).to eq(15)
    end

    it "allows direct options to override global configuration" do
      Airwallex.configure do |config|
        config.client_id = "global_client_id"
        config.api_key = "global_api_key"
        config.environment = :demo
      end

      client = described_class.new(
        client_id: "override_client_id",
        api_key: "override_api_key",
        environment: :production
      )

      expect(client.client_id).to eq("override_client_id")
      expect(client.api_key).to eq("override_api_key")
      expect(client.environment).to eq(:production)
    end

    it "raises Airwallex::ConfigurationError for an invalid environment" do
      expect do
        described_class.new(environment: :staging)
      end.to raise_error(Airwallex::ConfigurationError, /Invalid environment/)
    end
  end

  describe "#base_url" do
    it "returns the demo URL for :demo" do
      client = described_class.new(environment: :demo)

      expect(client.base_url).to eq("https://api-demo.airwallex.com/api/v1")
    end

    it "returns the production URL for :production" do
      client = described_class.new(environment: :production)

      expect(client.base_url).to eq("https://api.airwallex.com/api/v1")
    end
  end
end

RSpec.describe Airwallex do
  describe ".client" do
    it "returns an Airwallex::Client" do
      described_class.configure do |config|
        config.client_id = "test_client_id"
        config.api_key = "test_api_key"
        config.environment = :demo
      end

      expect(described_class.client).to be_a(Airwallex::Client)
    end

    it "builds the client from global configuration" do
      described_class.configure do |config|
        config.client_id = "test_client_id"
        config.api_key = "test_api_key"
        config.environment = :demo
      end

      client = described_class.client

      expect(client.client_id).to eq("test_client_id")
      expect(client.api_key).to eq("test_api_key")
      expect(client.environment).to eq(:demo)
      expect(client.base_url).to eq("https://api-demo.airwallex.com/api/v1")
    end
  end

  it "defines VERSION" do
    expect(Airwallex::VERSION).to eq("0.1.0")
  end
end

RSpec.describe Airwallex::Error do
  it "inherits from StandardError" do
    expect(described_class).to be < StandardError
  end
end

RSpec.describe Airwallex::ConfigurationError do
  it "inherits from Airwallex::Error" do
    expect(described_class).to be < Airwallex::Error
  end
end
