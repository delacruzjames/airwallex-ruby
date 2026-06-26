# frozen_string_literal: true

RSpec.describe Airwallex::Configuration do
  subject(:config) { described_class.new }

  describe "defaults" do
    it "sets environment to :demo" do
      expect(config.environment).to eq(:demo)
    end

    it "sets timeout to 30" do
      expect(config.timeout).to eq(30)
    end

    it "sets open_timeout to 10" do
      expect(config.open_timeout).to eq(10)
    end

    it "sets logger to nil" do
      expect(config.logger).to be_nil
    end
  end

  describe "attribute assignment" do
    it "stores client_id, api_key, login_as, environment, timeout, open_timeout, and logger" do
      logger = Logger.new($stdout)

      config.client_id = "client_id"
      config.api_key = "api_key"
      config.login_as = "acct_123"
      config.environment = :production
      config.timeout = 60
      config.open_timeout = 20
      config.logger = logger

      expect(config.client_id).to eq("client_id")
      expect(config.api_key).to eq("api_key")
      expect(config.login_as).to eq("acct_123")
      expect(config.environment).to eq(:production)
      expect(config.timeout).to eq(60)
      expect(config.open_timeout).to eq(20)
      expect(config.logger).to eq(logger)
    end
  end

  describe "#base_url" do
    it "returns the demo URL for :demo" do
      config.environment = :demo

      expect(config.base_url).to eq("https://api-demo.airwallex.com/api/v1")
    end

    it "returns the production URL for :production" do
      config.environment = :production

      expect(config.base_url).to eq("https://api.airwallex.com/api/v1")
    end
  end

  describe "environment validation" do
    it "raises Airwallex::ConfigurationError for an invalid environment" do
      expect { config.environment = :staging }
        .to raise_error(Airwallex::ConfigurationError, /Invalid environment/)
    end
  end
end

RSpec.describe Airwallex do
  describe ".configure" do
    it "yields the global configuration object" do
      yielded = nil

      described_class.configure do |config|
        yielded = config
        config.client_id = "client_id"
        config.api_key = "api_key"
        config.environment = :demo
      end

      expect(yielded).to eq(described_class.configuration)
      expect(described_class.configuration.client_id).to eq("client_id")
      expect(described_class.configuration.api_key).to eq("api_key")
      expect(described_class.configuration.environment).to eq(:demo)
    end
  end

  describe ".configuration" do
    it "returns the global configuration object" do
      config = described_class.configuration

      expect(config).to be_a(Airwallex::Configuration)
      expect(config.environment).to eq(:demo)
    end
  end

  describe ".reset_configuration!" do
    it "restores default configuration values" do
      described_class.configure do |config|
        config.client_id = "client_id"
        config.api_key = "api_key"
        config.environment = :production
        config.timeout = 99
        config.open_timeout = 99
        config.logger = Logger.new($stdout)
      end

      described_class.reset_configuration!

      config = described_class.configuration
      expect(config.client_id).to be_nil
      expect(config.api_key).to be_nil
      expect(config.environment).to eq(:demo)
      expect(config.timeout).to eq(30)
      expect(config.open_timeout).to eq(10)
      expect(config.logger).to be_nil
    end
  end
end
