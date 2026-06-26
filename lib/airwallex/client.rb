# frozen_string_literal: true

require "json"
require "faraday"
require "time"

module Airwallex
  class Client
    DEFAULT_HEADERS = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }.freeze

    TOKEN_EXPIRY_BUFFER = 60

    attr_reader :client_id, :api_key, :login_as, :environment, :timeout, :open_timeout, :logger,
                :access_token, :token_expires_at

    def initialize(**options)
      config = Airwallex.configuration

      @client_id = options.fetch(:client_id, config.client_id)
      @api_key = options.fetch(:api_key, config.api_key)
      @login_as = options.key?(:login_as) ? options[:login_as] : config.login_as
      @environment = Configuration.validate_environment!(options.fetch(:environment, config.environment))
      @timeout = options.fetch(:timeout, config.timeout)
      @open_timeout = options.fetch(:open_timeout, config.open_timeout)
      @logger = options.fetch(:logger, config.logger)
      @access_token = nil
      @token_expires_at = nil
    end

    def base_url
      Configuration::ENVIRONMENTS.fetch(environment)
    end

    def authentication
      @authentication ||= Resources::Authentication.new(self)
    end

    def payment_intents
      @payment_intents ||= Resources::PaymentIntents.new(self)
    end

    def refunds
      @refunds ||= Resources::Refunds.new(self)
    end

    def authenticate
      authentication.login
    end

    def authenticated?
      !access_token.nil? && !token_expired?
    end

    def auth_headers
      { "Authorization" => "Bearer #{access_token}" }
    end

    def get(path, params = {}, headers = {}, authenticated: true)
      request(:get, path, params: params, headers: headers, authenticated: authenticated)
    end

    def post(path, body = {}, headers = {}, authenticated: true, idempotency_key: nil)
      validate_idempotency_key!(idempotency_key)
      request(:post, path, body: body, headers: headers, authenticated: authenticated,
                           idempotency_key: idempotency_key)
    end

    def patch(path, body = {}, headers = {}, authenticated: true, idempotency_key: nil)
      validate_idempotency_key!(idempotency_key)
      request(:patch, path, body: body, headers: headers, authenticated: authenticated,
                            idempotency_key: idempotency_key)
    end

    def delete(path, params = {}, headers = {}, authenticated: true)
      request(:delete, path, params: params, headers: headers, authenticated: authenticated)
    end

    def validate_credentials!
      raise ConfigurationError, "client_id is required" if client_id.nil? || client_id.to_s.empty?
      raise ConfigurationError, "api_key is required" if api_key.nil? || api_key.to_s.empty?
    end

    def store_token!(response)
      token = response["token"]
      raise AuthenticationError, "Authentication response missing token" if token.nil? || token.to_s.empty?

      @access_token = token
      @token_expires_at = parse_expires_at(response["expires_at"])
    end

    private

    def request(method, path, params: nil, body: nil, headers: {}, authenticated: true,
                idempotency_key: nil)
      ensure_authenticated! if authenticated

      response = connection.run_request(
        method,
        request_url(path),
        body,
        merge_headers(headers, authenticated: authenticated, idempotency_key: idempotency_key)
      ) do |req|
        req.params.update(params) if params && !params.empty?
      end

      handle_response(response)
    rescue Faraday::TimeoutError => e
      raise TimeoutError, e.message
    rescue Faraday::ConnectionFailed => e
      raise TimeoutError, e.message if timeout_error?(e)

      raise
    end

    def ensure_authenticated!
      authenticate unless authenticated?
    end

    def token_expired?
      return true if access_token.nil? || token_expires_at.nil?

      Time.now >= (token_expires_at - TOKEN_EXPIRY_BUFFER)
    end

    def parse_expires_at(value)
      if value.nil? || value.to_s.strip.empty?
        raise AuthenticationError, "Authentication response has invalid expires_at"
      end

      case value
      when Time
        value
      when Integer, Float
        Time.at(value)
      when String
        Time.parse(value)
      else
        raise AuthenticationError, "Authentication response has invalid expires_at"
      end
    rescue ::ArgumentError, ::TypeError
      raise AuthenticationError, "Authentication response has invalid expires_at"
    end

    def timeout_error?(error)
      cause = error.wrapped_exception
      cause.is_a?(Net::OpenTimeout) ||
        cause.is_a?(Net::ReadTimeout) ||
        cause.is_a?(Timeout::Error) ||
        error.message.match?(/timeout|timed out/i)
    end

    def request_url(path)
      path = path.to_s
      return path if path.start_with?("http://", "https://")

      path = "/#{path}" unless path.start_with?("/")
      "#{base_url}#{path}"
    end

    def connection
      @connection ||= Faraday.new do |conn|
        conn.options.timeout = timeout
        conn.options.open_timeout = open_timeout
        conn.request :json
        conn.adapter Faraday.default_adapter
      end
    end

    def merge_headers(headers, authenticated:, idempotency_key: nil)
      merged = DEFAULT_HEADERS.merge(headers)
      merged = merged.merge(auth_headers) if authenticated
      merged["x-idempotency-key"] = idempotency_key if idempotency_key
      merged
    end

    def validate_idempotency_key!(idempotency_key)
      return if idempotency_key.nil?

      return if idempotency_key.is_a?(String) && !idempotency_key.strip.empty?

      raise ArgumentError, "idempotency_key must be a non-empty String"
    end

    def handle_response(response)
      parsed_body = parse_body(response.body)

      return parsed_body if response.status.between?(200, 299)

      HTTPError.raise_for_response!(response.status, parsed_body, response.body)
    end

    def parse_body(body)
      return {} if body.nil? || body.to_s.strip.empty?

      JSON.parse(body)
    rescue JSON::ParserError => e
      raise InvalidResponseError, "Invalid JSON response: #{e.message}"
    end
  end
end
