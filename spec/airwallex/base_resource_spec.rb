# frozen_string_literal: true

RSpec.describe Airwallex::Resources::BaseResource do
  let(:client) do
    Airwallex::Client.new(
      client_id: "client_id",
      api_key: "api_key",
      environment: :demo
    )
  end

  let(:resource_class) do
    Class.new(described_class) do
      def call_get
        get("/balances/current", { currency: "USD" }, { "X-Test" => "1" }, authenticated: false)
      end

      def call_post
        post("/pa/payment_intents/create", { amount: 100 }, { "X-Test" => "2" }, authenticated: false)
      end

      def call_patch
        patch("/pa/payment_intents/int_123", { amount: 200 }, { "X-Test" => "3" }, authenticated: false)
      end

      def call_delete
        delete("/pa/payment_intents/int_123", { force: true }, { "X-Test" => "4" }, authenticated: false)
      end
    end
  end

  let(:resource) { resource_class.new(client) }

  it "stores the client" do
    expect(resource.client).to be(client)
  end

  describe "request helpers" do
    it "delegates get to the client" do
      expect(client).to receive(:get)
        .with("/balances/current", { currency: "USD" }, { "X-Test" => "1" }, authenticated: false)
        .and_return({})

      resource.call_get
    end

    it "delegates post to the client" do
      expect(client).to receive(:post)
        .with("/pa/payment_intents/create", { amount: 100 }, { "X-Test" => "2" }, authenticated: false)
        .and_return({})

      resource.call_post
    end

    it "delegates patch to the client" do
      expect(client).to receive(:patch)
        .with("/pa/payment_intents/int_123", { amount: 200 }, { "X-Test" => "3" }, authenticated: false)
        .and_return({})

      resource.call_patch
    end

    it "delegates delete to the client" do
      expect(client).to receive(:delete)
        .with("/pa/payment_intents/int_123", { force: true }, { "X-Test" => "4" }, authenticated: false)
        .and_return({})

      resource.call_delete
    end
  end
end
