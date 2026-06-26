# frozen_string_literal: true

require "json"
require "openssl"

module Airwallex
  module Webhook
    MILLISECONDS_THRESHOLD = 1_000_000_000_000

    module_function

    def construct_event(payload:, signature:, timestamp:, secret:, tolerance: 300)
      verify_signature!(
        payload: payload,
        signature: signature,
        timestamp: timestamp,
        secret: secret,
        tolerance: tolerance
      )

      JSON.parse(payload)
    rescue JSON::ParserError
      raise InvalidResponseError, "Invalid webhook payload"
    end

    def verify_signature(payload:, signature:, timestamp:, secret:, tolerance: 300)
      verify_signature!(
        payload: payload,
        signature: signature,
        timestamp: timestamp,
        secret: secret,
        tolerance: tolerance
      )

      true
    end

    def verify_signature!(payload:, signature:, timestamp:, secret:, tolerance: 300)
      validate_inputs!(payload, signature, timestamp, secret, tolerance)

      normalized_timestamp = normalize_timestamp!(timestamp)
      validate_timestamp_tolerance!(normalized_timestamp, tolerance)

      expected_signature = compute_signature(timestamp, payload, secret)

      raise WebhookSignatureError, "Invalid signature" unless secure_compare(expected_signature, signature.to_s)

      true
    end

    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"
      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res.zero?
    end

    def validate_inputs!(payload, signature, timestamp, secret, tolerance)
      raise WebhookSignatureError, "Missing payload" if payload.nil? || payload.to_s.empty?
      raise WebhookSignatureError, "Missing signature" if signature.nil? || signature.to_s.empty?
      raise WebhookSignatureError, "Missing timestamp" if timestamp.nil? || timestamp.to_s.empty?
      raise WebhookSignatureError, "Missing secret" if secret.nil? || secret.to_s.empty?
      raise WebhookSignatureError, "Invalid tolerance" unless tolerance.is_a?(Integer) && tolerance.positive?
    end

    def normalize_timestamp!(timestamp)
      ts = Integer(timestamp)
      ts /= 1000 if ts > MILLISECONDS_THRESHOLD
      ts
    rescue ::ArgumentError, ::TypeError
      raise WebhookSignatureError, "Invalid timestamp"
    end

    def validate_timestamp_tolerance!(timestamp, tolerance)
      return if (Time.now.to_i - timestamp).abs <= tolerance

      raise WebhookSignatureError, "Timestamp outside tolerance"
    end

    def compute_signature(timestamp, payload, secret)
      value_to_digest = timestamp.to_s + payload.to_s

      OpenSSL::HMAC.hexdigest(
        "SHA256",
        secret,
        value_to_digest
      )
    end

    private_class_method :validate_inputs!, :normalize_timestamp!, :validate_timestamp_tolerance!, :compute_signature
  end
end
