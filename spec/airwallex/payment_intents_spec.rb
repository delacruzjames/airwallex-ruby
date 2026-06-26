# frozen_string_literal: true

require "json"

RSpec.describe Airwallex::Resources::PaymentIntents do
  let(:base_url) { "https://api-demo.airwallex.com/api/v1" }
  let(:login_url) { "#{base_url}/authentication/login" }
  let(:client) do
    Airwallex::Client.new(
      client_id: "client_id",
      api_key: "api_key",
      environment: :demo
    )
  end
  let(:payment_intents) { client.payment_intents }
  let(:auth_response_body) do
    {
      token: "test_token",
      expires_at: "2099-01-01T00:00:00Z"
    }.to_json
  end

  def stub_login
    stub_request(:post, login_url)
      .to_return(status: 200, body: auth_response_body, headers: { "Content-Type" => "application/json" })
  end

  describe "client accessor" do
    it "returns Airwallex::Resources::PaymentIntents" do
      expect(client.payment_intents).to be_a(described_class)
    end

    it "memoizes the resource object" do
      first = client.payment_intents
      second = client.payment_intents

      expect(first).to equal(second)
    end
  end

  it "inherits from Airwallex::Resources::BaseResource" do
    expect(described_class).to be < Airwallex::Resources::BaseResource
  end

  describe "#create" do
    let(:create_url) { "#{base_url}/pa/payment_intents/create" }
    let(:params) do
      {
        amount: 1000,
        currency: "PHP",
        merchant_order_id: "ORDER-1001",
        return_url: "https://example.com/return"
      }
    end
    let(:response_body) do
      {
        id: "int_123",
        client_secret: "secret_abc",
        status: "REQUIRES_PAYMENT_METHOD"
      }.to_json
    end

    it "sends POST /pa/payment_intents/create" do
      stub_login
      stub_request(:post, create_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.create(params)

      expect(WebMock).to have_requested(:post, create_url)
    end

    it "sends request body as JSON" do
      stub_login
      stub_request(:post, create_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.create(params)

      expect(WebMock).to have_requested(:post, create_url)
        .with(body: params.to_json)
    end

    it "raises Airwallex::ArgumentError when params is not a Hash" do
      expect { payment_intents.create("invalid") }
        .to raise_error(Airwallex::ArgumentError, "params must be a Hash")
    end
  end

  describe "#retrieve" do
    let(:payment_intent_id) { "int_123" }
    let(:retrieve_url) { "#{base_url}/pa/payment_intents/#{payment_intent_id}" }
    let(:response_body) do
      { id: payment_intent_id, status: "SUCCEEDED" }.to_json
    end

    it "sends GET /pa/payment_intents/{id}" do
      stub_login
      stub_request(:get, retrieve_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.retrieve(payment_intent_id)

      expect(WebMock).to have_requested(:get, retrieve_url)
    end

    it "raises Airwallex::ArgumentError when id is nil" do
      expect { payment_intents.retrieve(nil) }
        .to raise_error(Airwallex::ArgumentError, "id is required")
    end

    it "raises Airwallex::ArgumentError when id is empty" do
      expect { payment_intents.retrieve("   ") }
        .to raise_error(Airwallex::ArgumentError, "id is required")
    end
  end

  describe "#update" do
    let(:payment_intent_id) { "int_123" }
    let(:update_url) { "#{base_url}/pa/payment_intents/#{payment_intent_id}/update" }
    let(:params) do
      {
        amount: 1500,
        merchant_order_id: "ORDER-1001-UPDATED"
      }
    end
    let(:response_body) do
      { id: payment_intent_id, amount: 1500 }.to_json
    end

    it "sends POST /pa/payment_intents/{id}/update" do
      stub_login
      stub_request(:post, update_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.update(payment_intent_id, params)

      expect(WebMock).to have_requested(:post, update_url)
    end

    it "sends request body as JSON" do
      stub_login
      stub_request(:post, update_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.update(payment_intent_id, params)

      expect(WebMock).to have_requested(:post, update_url)
        .with(body: params.to_json)
    end

    it "raises Airwallex::ArgumentError when id is nil" do
      expect { payment_intents.update(nil, params) }
        .to raise_error(Airwallex::ArgumentError, "id is required")
    end

    it "raises Airwallex::ArgumentError when params is not a Hash" do
      expect { payment_intents.update(payment_intent_id, "invalid") }
        .to raise_error(Airwallex::ArgumentError, "params must be a Hash")
    end
  end

  describe "#cancel" do
    let(:payment_intent_id) { "int_123" }
    let(:cancel_url) { "#{base_url}/pa/payment_intents/#{payment_intent_id}/cancel" }
    let(:response_body) do
      { id: payment_intent_id, status: "CANCELLED" }.to_json
    end

    it "sends POST /pa/payment_intents/{id}/cancel" do
      stub_login
      stub_request(:post, cancel_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.cancel(payment_intent_id)

      expect(WebMock).to have_requested(:post, cancel_url)
    end

    it "raises Airwallex::ArgumentError when id is nil" do
      expect { payment_intents.cancel(nil) }
        .to raise_error(Airwallex::ArgumentError, "id is required")
    end
  end

  describe "#list" do
    let(:list_url) { "#{base_url}/pa/payment_intents" }
    let(:params) do
      {
        currency: "PHP",
        page_num: 0,
        page_size: 20
      }
    end
    let(:response_body) do
      { items: [], has_more: false }.to_json
    end

    it "sends GET /pa/payment_intents" do
      stub_login
      stub_request(:get, list_url)
        .with(query: params)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.list(params)

      expect(WebMock).to have_requested(:get, list_url).with(query: params)
    end

    it "sends query params" do
      stub_login
      stub_request(:get, list_url)
        .with(query: params)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      payment_intents.list(params)

      expect(WebMock).to have_requested(:get, list_url)
        .with(query: params)
    end

    it "raises Airwallex::ArgumentError when params is not a Hash" do
      expect { payment_intents.list("invalid") }
        .to raise_error(Airwallex::ArgumentError, "params must be a Hash")
    end
  end

  describe "authentication" do
    let(:list_url) { "#{base_url}/pa/payment_intents" }

    it "authenticates PaymentIntent requests by default" do
      stub_login
      stub_request(:get, list_url)
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

      payment_intents.list

      expect(WebMock).to have_requested(:post, login_url)
      expect(WebMock).to have_requested(:get, list_url)
        .with(headers: { "Authorization" => "Bearer test_token" })
    end
  end
end

RSpec.describe Airwallex::ArgumentError do
  it "inherits from Airwallex::Error" do
    expect(described_class).to be < Airwallex::Error
  end
end
