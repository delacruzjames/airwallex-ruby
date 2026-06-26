# frozen_string_literal: true

require "json"

RSpec.describe Airwallex::Resources::Refunds do
  let(:base_url) { "https://api-demo.airwallex.com/api/v1" }
  let(:login_url) { "#{base_url}/authentication/login" }
  let(:client) do
    Airwallex::Client.new(
      client_id: "client_id",
      api_key: "api_key",
      environment: :demo
    )
  end
  let(:refunds) { client.refunds }
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
    it "returns Airwallex::Resources::Refunds" do
      expect(client.refunds).to be_a(described_class)
    end

    it "memoizes the resource object" do
      first = client.refunds
      second = client.refunds

      expect(first).to equal(second)
    end
  end

  it "inherits from Airwallex::Resources::BaseResource" do
    expect(described_class).to be < Airwallex::Resources::BaseResource
  end

  describe "#create" do
    let(:create_url) { "#{base_url}/pa/refunds/create" }
    let(:params) do
      {
        payment_intent_id: "int_123",
        amount: 500,
        reason: "requested_by_customer",
        metadata: {
          order_id: "ORDER-1001"
        }
      }
    end
    let(:response_body) do
      {
        id: "ref_123",
        status: "SUCCEEDED",
        amount: 500
      }.to_json
    end

    it "sends POST /pa/refunds/create" do
      stub_login
      stub_request(:post, create_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      refunds.create(params)

      expect(WebMock).to have_requested(:post, create_url)
    end

    it "sends request body as JSON" do
      stub_login
      stub_request(:post, create_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      refunds.create(params)

      expect(WebMock).to have_requested(:post, create_url)
        .with(body: params.to_json)
    end

    it "passes x-idempotency-key header when idempotency_key is provided" do
      stub_login
      stub_request(:post, create_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      refunds.create(params, idempotency_key: "order-1001-refund-1")

      expect(WebMock).to have_requested(:post, create_url)
        .with(headers: { "x-idempotency-key" => "order-1001-refund-1" })
    end

    it "works without idempotency_key" do
      stub_login
      stub_request(:post, create_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      result = refunds.create(params)

      expect(result).to eq("id" => "ref_123", "status" => "SUCCEEDED", "amount" => 500)
      expect(WebMock).to(have_requested(:post, create_url)
        .with { |req| !req.headers.key?("X-Idempotency-Key") && !req.headers.key?("x-idempotency-key") })
    end

    it "raises Airwallex::ArgumentError when params is not a Hash" do
      expect { refunds.create("invalid") }
        .to raise_error(Airwallex::ArgumentError, "params must be a Hash")
    end

    it "raises Airwallex::ArgumentError for invalid idempotency_key" do
      expect { refunds.create(params, idempotency_key: "") }
        .to raise_error(Airwallex::ArgumentError, "idempotency_key must be a non-empty String")
    end
  end

  describe "#retrieve" do
    let(:refund_id) { "ref_123" }
    let(:retrieve_url) { "#{base_url}/pa/refunds/#{refund_id}" }
    let(:response_body) do
      { id: refund_id, status: "SUCCEEDED" }.to_json
    end

    it "sends GET /pa/refunds/{id}" do
      stub_login
      stub_request(:get, retrieve_url)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      refunds.retrieve(refund_id)

      expect(WebMock).to have_requested(:get, retrieve_url)
    end

    it "raises Airwallex::ArgumentError when id is nil" do
      expect { refunds.retrieve(nil) }
        .to raise_error(Airwallex::ArgumentError, "id is required")
    end

    it "raises Airwallex::ArgumentError when id is empty" do
      expect { refunds.retrieve("   ") }
        .to raise_error(Airwallex::ArgumentError, "id is required")
    end
  end

  describe "#list" do
    let(:list_url) { "#{base_url}/pa/refunds" }
    let(:params) do
      {
        payment_intent_id: "int_123",
        page_num: 0,
        page_size: 20
      }
    end
    let(:response_body) do
      { items: [], has_more: false }.to_json
    end

    it "sends GET /pa/refunds" do
      stub_login
      stub_request(:get, list_url)
        .with(query: params)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      refunds.list(params)

      expect(WebMock).to have_requested(:get, list_url).with(query: params)
    end

    it "sends query params" do
      stub_login
      stub_request(:get, list_url)
        .with(query: params)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

      refunds.list(params)

      expect(WebMock).to have_requested(:get, list_url)
        .with(query: params)
    end

    it "raises Airwallex::ArgumentError when params is not a Hash" do
      expect { refunds.list("invalid") }
        .to raise_error(Airwallex::ArgumentError, "params must be a Hash")
    end
  end

  describe "authentication" do
    let(:list_url) { "#{base_url}/pa/refunds" }

    it "authenticates Refunds requests by default" do
      stub_login
      stub_request(:get, list_url)
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

      refunds.list

      expect(WebMock).to have_requested(:post, login_url)
      expect(WebMock).to have_requested(:get, list_url)
        .with(headers: { "Authorization" => "Bearer test_token" })
    end
  end
end
