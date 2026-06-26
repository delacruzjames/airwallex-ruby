# frozen_string_literal: true

module Airwallex
  module Resources
    class Authentication < BaseResource
      LOGIN_PATH = "/authentication/login"

      def login
        client.validate_credentials!

        response = post(LOGIN_PATH, {}, authentication_headers, authenticated: false)
        client.store_token!(response)
        response
      end

      private

      def authentication_headers
        headers = {
          "x-client-id" => client.client_id,
          "x-api-key" => client.api_key
        }
        headers["x-login-as"] = client.login_as if client.login_as
        headers
      end
    end
  end
end
