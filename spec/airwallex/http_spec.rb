# frozen_string_literal: true

require "json"

RSpec.describe "Airwallex HTTP layer" do
  let(:client) { Airwallex::Client.new(environment: :demo) }
  let(:base_url) { "https://api-demo.airwallex.com/api/v1" }

  describe "#get" do
    it "sends GET request to correct base URL" do
      stub_request(:get, "#{base_url}/balances/current")
        .to_return(status: 200, body: '{"available":100}', headers: { "Content-Type" => "application/json" })

      result = client.get("/balances/current", authenticated: false)

      expect(result).to eq("available" => 100)
    end
  end

  describe "#post" do
    it "sends JSON body" do
      stub_request(:post, "#{base_url}/pa/payment_intents/create")
        .with(body: { amount: 100, currency: "USD" }.to_json)
        .to_return(status: 200, body: '{"id":"int_123"}', headers: { "Content-Type" => "application/json" })

      result = client.post("/pa/payment_intents/create", { amount: 100, currency: "USD" }, authenticated: false)

      expect(result).to eq("id" => "int_123")
    end
  end

  describe "#patch" do
    it "sends JSON body" do
      stub_request(:patch, "#{base_url}/pa/payment_intents/int_123")
        .with(body: { amount: 200 }.to_json)
        .to_return(
          status: 200,
          body: '{"id":"int_123","amount":200}',
          headers: { "Content-Type" => "application/json" }
        )

      result = client.patch("/pa/payment_intents/int_123", { amount: 200 }, authenticated: false)

      expect(result).to eq("id" => "int_123", "amount" => 200)
    end
  end

  describe "#delete" do
    it "sends DELETE request" do
      stub_request(:delete, "#{base_url}/pa/payment_intents/int_123")
        .to_return(
          status: 200,
          body: '{"id":"int_123","status":"CANCELLED"}',
          headers: { "Content-Type" => "application/json" }
        )

      result = client.delete("/pa/payment_intents/int_123", {}, {}, authenticated: false)

      expect(result).to eq("id" => "int_123", "status" => "CANCELLED")
    end
  end

  describe "successful responses" do
    it "returns parsed JSON body as Hash" do
      stub_request(:get, "#{base_url}/health")
        .to_return(status: 200, body: '{"status":"ok","version":1}', headers: { "Content-Type" => "application/json" })

      expect(client.get("/health", authenticated: false)).to eq("status" => "ok", "version" => 1)
    end

    it "returns empty Hash for empty successful response" do
      stub_request(:delete, "#{base_url}/pa/payment_intents/int_123")
        .to_return(status: 204, body: "")

      expect(client.delete("/pa/payment_intents/int_123", {}, {}, authenticated: false)).to eq({})
    end
  end

  describe "headers" do
    it "sends custom headers" do
      stub_request(:get, "#{base_url}/balances/current")
        .with(headers: { "X-Request-Id" => "req_123" })
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

      client.get("/balances/current", {}, { "X-Request-Id" => "req_123" }, authenticated: false)
    end

    it "sends default JSON headers" do
      stub_request(:post, "#{base_url}/pa/payment_intents/create")
        .with(headers: { "Content-Type" => "application/json", "Accept" => "application/json" })
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

      client.post("/pa/payment_intents/create", {}, {}, authenticated: false)

      expect(WebMock).not_to have_requested(:post, "#{base_url}/pa/payment_intents/create")
        .with(headers: { "Authorization" => /.+/ })
    end
  end

  describe "HTTP error responses" do
    let(:error_body) do
      {
        code: "invalid_argument",
        source: "amount",
        message: "The amount is invalid",
        details: {}
      }.to_json
    end

    it "raises Airwallex::BadRequestError for 400" do
      stub_request(:post, "#{base_url}/pa/payment_intents/create")
        .to_return(status: 400, body: error_body, headers: { "Content-Type" => "application/json" })

      expect { client.post("/pa/payment_intents/create", {}, {}, authenticated: false) }
        .to raise_error(Airwallex::BadRequestError)
    end

    it "raises Airwallex::UnauthorizedError for 401" do
      stub_request(:get, "#{base_url}/balances/current")
        .to_return(status: 401, body: error_body, headers: { "Content-Type" => "application/json" })

      expect { client.get("/balances/current", authenticated: false) }
        .to raise_error(Airwallex::UnauthorizedError)
    end

    it "raises Airwallex::ForbiddenError for 403" do
      stub_request(:get, "#{base_url}/balances/current")
        .to_return(status: 403, body: error_body, headers: { "Content-Type" => "application/json" })

      expect { client.get("/balances/current", authenticated: false) }
        .to raise_error(Airwallex::ForbiddenError)
    end

    it "raises Airwallex::NotFoundError for 404" do
      stub_request(:get, "#{base_url}/pa/payment_intents/missing")
        .to_return(status: 404, body: error_body, headers: { "Content-Type" => "application/json" })

      expect { client.get("/pa/payment_intents/missing", authenticated: false) }
        .to raise_error(Airwallex::NotFoundError)
    end

    it "raises Airwallex::ConflictError for 409" do
      stub_request(:post, "#{base_url}/pa/payment_intents/create")
        .to_return(status: 409, body: error_body, headers: { "Content-Type" => "application/json" })

      expect { client.post("/pa/payment_intents/create", {}, {}, authenticated: false) }
        .to raise_error(Airwallex::ConflictError)
    end

    it "raises Airwallex::RateLimitError for 429" do
      stub_request(:get, "#{base_url}/balances/current")
        .to_return(status: 429, body: error_body, headers: { "Content-Type" => "application/json" })

      expect { client.get("/balances/current", authenticated: false) }
        .to raise_error(Airwallex::RateLimitError)
    end

    it "raises Airwallex::ServerError for 500" do
      stub_request(:get, "#{base_url}/balances/current")
        .to_return(status: 500, body: error_body, headers: { "Content-Type" => "application/json" })

      expect { client.get("/balances/current", authenticated: false) }
        .to raise_error(Airwallex::ServerError)
    end

    it "exposes API error response fields on the error object" do
      stub_request(:post, "#{base_url}/pa/payment_intents/create")
        .to_return(status: 400, body: error_body, headers: { "Content-Type" => "application/json" })

      path = "/pa/payment_intents/create"

      expect { client.post(path, {}, {}, authenticated: false) }
        .to raise_error(Airwallex::BadRequestError) do |error|
        expect(error.message).to eq("The amount is invalid")
        expect(error.status).to eq(400)
        expect(error.code).to eq("invalid_argument")
        expect(error.source).to eq("amount")
        expect(error.details).to eq({})
        expect(error.response_body).to eq(error_body)
      end
    end
  end

  describe "invalid responses" do
    it "raises Airwallex::InvalidResponseError for invalid JSON" do
      stub_request(:get, "#{base_url}/health")
        .to_return(status: 200, body: "not-json", headers: { "Content-Type" => "application/json" })

      expect { client.get("/health", authenticated: false) }
        .to raise_error(Airwallex::InvalidResponseError, /Invalid JSON response/)
    end
  end

  describe "timeouts" do
    it "raises Airwallex::TimeoutError on Faraday timeout" do
      stub_request(:get, "#{base_url}/balances/current").to_timeout

      expect { client.get("/balances/current", authenticated: false) }
        .to raise_error(Airwallex::TimeoutError)
    end
  end
end
