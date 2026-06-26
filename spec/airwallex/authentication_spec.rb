# frozen_string_literal: true

require "json"

RSpec.describe "Airwallex authentication" do
  let(:base_url) { "https://api-demo.airwallex.com/api/v1" }
  let(:login_url) { "#{base_url}/authentication/login" }
  let(:client) do
    Airwallex::Client.new(
      client_id: "client_id",
      api_key: "api_key",
      environment: :demo
    )
  end
  let(:expires_at) { Time.now + 3600 }
  let(:auth_response_body) do
    {
      token: "test_access_token",
      expires_at: expires_at.iso8601
    }.to_json
  end

  def stub_login(response_body: auth_response_body, status: 200)
    stub_request(:post, login_url)
      .to_return(status: status, body: response_body, headers: { "Content-Type" => "application/json" })
  end

  describe "#authenticate" do
    it "calls POST /authentication/login" do
      stub_login

      client.authenticate

      expect(WebMock).to have_requested(:post, login_url)
    end

    it "includes x-client-id in the authentication request" do
      stub_login

      client.authenticate

      expect(WebMock).to have_requested(:post, login_url)
        .with(headers: { "x-client-id" => "client_id" })
    end

    it "includes x-api-key in the authentication request" do
      stub_login

      client.authenticate

      expect(WebMock).to have_requested(:post, login_url)
        .with(headers: { "x-api-key" => "api_key" })
    end

    context "when login_as is provided" do
      let(:client) do
        Airwallex::Client.new(
          client_id: "client_id",
          api_key: "api_key",
          login_as: "acct_123",
          environment: :demo
        )
      end

      it "includes x-login-as in the authentication request" do
        stub_login

        client.authenticate

        expect(WebMock).to have_requested(:post, login_url)
          .with(headers: { "x-login-as" => "acct_123" })
      end
    end

    context "when login_as is nil" do
      it "does not include x-login-as in the authentication request" do
        stub_login

        client.authenticate

        expect(WebMock).not_to have_requested(:post, login_url)
          .with(headers: { "x-login-as" => /.+/ })
      end
    end

    it "stores access_token on successful authentication" do
      stub_login

      client.authenticate

      expect(client.access_token).to eq("test_access_token")
    end

    it "stores token_expires_at on successful authentication" do
      stub_login

      client.authenticate

      expect(client.token_expires_at).to be_within(1).of(expires_at)
    end

    it "raises Airwallex::ConfigurationError when client_id is missing" do
      client = Airwallex::Client.new(api_key: "api_key", environment: :demo)

      expect { client.authenticate }
        .to raise_error(Airwallex::ConfigurationError, /client_id/)
    end

    it "raises Airwallex::ConfigurationError when api_key is missing" do
      client = Airwallex::Client.new(client_id: "client_id", environment: :demo)

      expect { client.authenticate }
        .to raise_error(Airwallex::ConfigurationError, /api_key/)
    end

    it "raises Airwallex::AuthenticationError when the response does not include a token" do
      stub_login(response_body: { expires_at: expires_at.iso8601 }.to_json)

      expect { client.authenticate }
        .to raise_error(Airwallex::AuthenticationError, /token/)
    end

    it "raises Airwallex::AuthenticationError when expires_at is invalid" do
      stub_login(response_body: { token: "test_access_token", expires_at: "not-a-time" }.to_json)

      expect { client.authenticate }
        .to raise_error(Airwallex::AuthenticationError, /expires_at/)
    end

    it "does not include Authorization header on the login request" do
      stub_login

      client.authenticate

      expect(WebMock).not_to have_requested(:post, login_url)
        .with(headers: { "Authorization" => /.+/ })
    end
  end

  describe "#authenticated?" do
    it "returns true when the token is valid" do
      stub_login
      client.authenticate

      expect(client).to be_authenticated
    end

    it "returns false when the token is missing" do
      expect(client).not_to be_authenticated
    end

    it "returns false when the token is expired" do
      stub_login(response_body: {
        token: "expired_token",
        expires_at: (Time.now - 120).iso8601
      }.to_json)
      client.authenticate

      expect(client).not_to be_authenticated
    end

    it "returns false when the token expires within 60 seconds" do
      stub_login(response_body: {
        token: "almost_expired_token",
        expires_at: (Time.now + 30).iso8601
      }.to_json)
      client.authenticate

      expect(client).not_to be_authenticated
    end
  end

  describe "#auth_headers" do
    it "returns Authorization Bearer header using the access token" do
      stub_login
      client.authenticate

      expect(client.auth_headers).to eq("Authorization" => "Bearer test_access_token")
    end
  end

  describe "authenticated API requests" do
    let(:resource_url) { "#{base_url}/payment_intents" }

    it "automatically authenticates when the token is missing" do
      stub_login
      stub_request(:get, resource_url)
        .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })

      client.get("/payment_intents")

      expect(WebMock).to have_requested(:post, login_url)
      expect(WebMock).to have_requested(:get, resource_url)
    end

    it "includes Authorization Bearer header on authenticated requests" do
      stub_login
      stub_request(:get, resource_url)
        .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })

      client.get("/payment_intents")

      expect(WebMock).to have_requested(:get, resource_url)
        .with(headers: { "Authorization" => "Bearer test_access_token" })
    end

    it "does not re-authenticate when the token is still valid" do
      stub_login
      stub_request(:get, resource_url)
        .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })

      client.get("/payment_intents")
      client.get("/payment_intents")

      expect(WebMock).to have_requested(:post, login_url).once
    end

    it "re-authenticates when the token is expired" do
      stub_login(response_body: {
        token: "expired_token",
        expires_at: (Time.now - 120).iso8601
      }.to_json)
      client.authenticate

      stub_login(response_body: {
        token: "fresh_token",
        expires_at: (Time.now + 3600).iso8601
      }.to_json)
      stub_request(:get, resource_url)
        .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })

      client.get("/payment_intents")

      expect(WebMock).to have_requested(:post, login_url).twice
      expect(WebMock).to have_requested(:get, resource_url)
        .with(headers: { "Authorization" => "Bearer fresh_token" })
    end
  end
end

RSpec.describe Airwallex::Resources::Authentication do
  it "inherits from Airwallex::Resources::BaseResource" do
    expect(described_class).to be < Airwallex::Resources::BaseResource
  end
end

RSpec.describe Airwallex::AuthenticationError do
  it "inherits from Airwallex::Error" do
    expect(described_class).to be < Airwallex::Error
  end
end
