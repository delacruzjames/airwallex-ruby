# frozen_string_literal: true

RSpec.describe "Airwallex idempotency keys" do
  let(:client) { Airwallex::Client.new(environment: :demo) }
  let(:base_url) { "https://api-demo.airwallex.com/api/v1" }

  describe "Client#post" do
    let(:url) { "#{base_url}/pa/payment_intents/create" }

    before do
      stub_request(:post, url)
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })
    end

    it "includes x-idempotency-key when idempotency_key is provided" do
      client.post("/pa/payment_intents/create", { amount: 1000 }, {}, authenticated: false,
                                                                      idempotency_key: "unique-key-123")

      expect(WebMock).to have_requested(:post, url)
        .with(headers: { "x-idempotency-key" => "unique-key-123" })
    end

    it "does not include x-idempotency-key when idempotency_key is nil" do
      client.post("/pa/payment_intents/create", { amount: 1000 }, {}, authenticated: false)

      expect(WebMock).to(have_requested(:post, url)
        .with { |req| !req.headers.key?("X-Idempotency-Key") && !req.headers.key?("x-idempotency-key") })
    end

    it "raises Airwallex::ArgumentError when idempotency_key is empty" do
      expect do
        client.post("/pa/payment_intents/create", {}, {}, authenticated: false, idempotency_key: "")
      end.to raise_error(Airwallex::ArgumentError, "idempotency_key must be a non-empty String")
    end

    it "raises Airwallex::ArgumentError when idempotency_key is whitespace" do
      expect do
        client.post("/pa/payment_intents/create", {}, {}, authenticated: false, idempotency_key: "   ")
      end.to raise_error(Airwallex::ArgumentError, "idempotency_key must be a non-empty String")
    end

    it "raises Airwallex::ArgumentError when idempotency_key is not a String" do
      expect do
        client.post("/pa/payment_intents/create", {}, {}, authenticated: false, idempotency_key: 123)
      end.to raise_error(Airwallex::ArgumentError, "idempotency_key must be a non-empty String")
    end
  end

  describe "Client#patch" do
    let(:url) { "#{base_url}/pa/payment_intents/int_123" }

    before do
      stub_request(:patch, url)
        .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })
    end

    it "includes x-idempotency-key when idempotency_key is provided" do
      client.patch("/pa/payment_intents/int_123", { amount: 1000 }, {}, authenticated: false,
                                                                        idempotency_key: "unique-key-456")

      expect(WebMock).to have_requested(:patch, url)
        .with(headers: { "x-idempotency-key" => "unique-key-456" })
    end

    it "does not include x-idempotency-key when idempotency_key is nil" do
      client.patch("/pa/payment_intents/int_123", { amount: 1000 }, {}, authenticated: false)

      expect(WebMock).to(have_requested(:patch, url)
        .with { |req| !req.headers.key?("X-Idempotency-Key") && !req.headers.key?("x-idempotency-key") })
    end

    it "raises Airwallex::ArgumentError when idempotency_key is empty" do
      expect do
        client.patch("/pa/payment_intents/int_123", {}, {}, authenticated: false, idempotency_key: "")
      end.to raise_error(Airwallex::ArgumentError, "idempotency_key must be a non-empty String")
    end

    it "raises Airwallex::ArgumentError when idempotency_key is not a String" do
      expect do
        client.patch("/pa/payment_intents/int_123", {}, {}, authenticated: false, idempotency_key: :symbol)
      end.to raise_error(Airwallex::ArgumentError, "idempotency_key must be a non-empty String")
    end
  end
end
