# frozen_string_literal: true

require "json"
require "faraday"

module Airwallex
  class Client
    DEFAULT_HEADERS = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }.freeze

    attr_reader :client_id, :api_key, :environment, :timeout, :open_timeout, :logger

    def initialize(**options)
      config = Airwallex.configuration

      @client_id = options.fetch(:client_id, config.client_id)
      @api_key = options.fetch(:api_key, config.api_key)
      @environment = Configuration.validate_environment!(options.fetch(:environment, config.environment))
      @timeout = options.fetch(:timeout, config.timeout)
      @open_timeout = options.fetch(:open_timeout, config.open_timeout)
      @logger = options.fetch(:logger, config.logger)
    end

    def base_url
      Configuration::ENVIRONMENTS.fetch(environment)
    end

    def get(path, params = {}, headers = {})
      request(:get, path, params: params, headers: headers)
    end

    def post(path, body = {}, headers = {})
      request(:post, path, body: body, headers: headers)
    end

    def patch(path, body = {}, headers = {})
      request(:patch, path, body: body, headers: headers)
    end

    def delete(path, params = {}, headers = {})
      request(:delete, path, params: params, headers: headers)
    end

    private

    def request(method, path, params: nil, body: nil, headers: {})
      response = connection.run_request(method, request_url(path), body, merge_headers(headers)) do |req|
        req.params.update(params) if params && !params.empty?
      end

      handle_response(response)
    rescue Faraday::TimeoutError => e
      raise TimeoutError, e.message
    rescue Faraday::ConnectionFailed => e
      raise TimeoutError, e.message if timeout_error?(e)

      raise
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

    def merge_headers(headers)
      DEFAULT_HEADERS.merge(headers)
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
