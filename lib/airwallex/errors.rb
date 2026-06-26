# frozen_string_literal: true

module Airwallex
  class Error < StandardError
  end

  class ConfigurationError < Error
  end

  class HTTPError < Error
    attr_reader :status, :code, :source, :details, :response_body

    def initialize(message = nil, **attrs)
      super(message)
      @status = attrs[:status]
      @code = attrs[:code]
      @source = attrs[:source]
      @details = attrs[:details]
      @response_body = attrs[:response_body]
    end

    def self.raise_for_response!(status, parsed_body, raw_body)
      fields = parsed_body.is_a?(Hash) ? parsed_body : {}
      raise error_class_for(status).new(
        extract_message(parsed_body, status),
        status: status,
        code: fields["code"],
        source: fields["source"],
        details: fields["details"],
        response_body: raw_body
      )
    end

    def self.error_class_for(status)
      return ServerError if status.between?(500, 599)

      status_error_map.fetch(status, HTTPError)
    end

    def self.extract_message(parsed_body, status)
      return parsed_body["message"] if parsed_body.is_a?(Hash) && parsed_body["message"]
      return parsed_body["code"] if parsed_body.is_a?(Hash) && parsed_body["code"]

      "HTTP #{status}"
    end

    def self.status_error_map
      @status_error_map ||= {
        400 => BadRequestError,
        401 => UnauthorizedError,
        403 => ForbiddenError,
        404 => NotFoundError,
        409 => ConflictError,
        429 => RateLimitError
      }.freeze
    end

    private_class_method :error_class_for, :extract_message, :status_error_map
  end

  class BadRequestError < HTTPError; end
  class UnauthorizedError < HTTPError; end
  class ForbiddenError < HTTPError; end
  class NotFoundError < HTTPError; end
  class ConflictError < HTTPError; end
  class RateLimitError < HTTPError; end
  class ServerError < HTTPError; end
  class TimeoutError < HTTPError; end
  class InvalidResponseError < HTTPError; end
end
