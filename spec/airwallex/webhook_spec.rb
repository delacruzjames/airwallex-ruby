# frozen_string_literal: true

require "openssl"

RSpec.describe Airwallex::Webhook do
  def sign(payload, timestamp, secret)
    OpenSSL::HMAC.hexdigest(
      "SHA256",
      secret,
      timestamp.to_s + payload.to_s
    )
  end

  let(:payload) { '{"name":"payment_intent.succeeded","data":{"object":{"id":"int_123"}}}' }
  let(:timestamp) { Time.now.to_i.to_s }
  let(:secret) { "whsec_test" }
  let(:signature) { sign(payload, timestamp, secret) }

  describe ".construct_event" do
    it "returns parsed Hash for valid payload and signature" do
      event = described_class.construct_event(
        payload: payload,
        signature: signature,
        timestamp: timestamp,
        secret: secret
      )

      expect(event).to eq(
        "name" => "payment_intent.succeeded",
        "data" => { "object" => { "id" => "int_123" } }
      )
    end

    it "raises Airwallex::InvalidResponseError after valid signature for invalid JSON payload" do
      invalid_payload = "not-json"
      invalid_signature = sign(invalid_payload, timestamp, secret)

      expect do
        described_class.construct_event(
          payload: invalid_payload,
          signature: invalid_signature,
          timestamp: timestamp,
          secret: secret
        )
      end.to raise_error(Airwallex::InvalidResponseError, "Invalid webhook payload")
    end
  end

  describe ".verify_signature" do
    it "returns true for valid payload and signature" do
      result = described_class.verify_signature(
        payload: payload,
        signature: signature,
        timestamp: timestamp,
        secret: secret
      )

      expect(result).to be true
    end
  end

  describe ".verify_signature!" do
    it "does not raise for valid payload and signature" do
      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: signature,
          timestamp: timestamp,
          secret: secret
        )
      end.not_to raise_error
    end

    it "calculates signature from timestamp + raw payload" do
      custom_timestamp = "1714000000"
      custom_signature = sign(payload, custom_timestamp, secret)

      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: custom_signature,
          timestamp: custom_timestamp,
          secret: secret,
          tolerance: 999_999_999
        )
      end.not_to raise_error
    end

    it "raises Airwallex::WebhookSignatureError for invalid signature" do
      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: "invalid_signature",
          timestamp: timestamp,
          secret: secret
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Invalid signature")
    end

    it "raises Airwallex::WebhookSignatureError for missing payload" do
      expect do
        described_class.verify_signature!(
          payload: nil,
          signature: signature,
          timestamp: timestamp,
          secret: secret
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Missing payload")
    end

    it "raises Airwallex::WebhookSignatureError for empty payload" do
      expect do
        described_class.verify_signature!(
          payload: "",
          signature: signature,
          timestamp: timestamp,
          secret: secret
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Missing payload")
    end

    it "raises Airwallex::WebhookSignatureError for missing signature" do
      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: nil,
          timestamp: timestamp,
          secret: secret
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Missing signature")
    end

    it "raises Airwallex::WebhookSignatureError for missing timestamp" do
      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: signature,
          timestamp: nil,
          secret: secret
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Missing timestamp")
    end

    it "raises Airwallex::WebhookSignatureError for missing secret" do
      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: signature,
          timestamp: timestamp,
          secret: nil
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Missing secret")
    end

    it "raises Airwallex::WebhookSignatureError for invalid timestamp" do
      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: signature,
          timestamp: "not-a-timestamp",
          secret: secret
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Invalid timestamp")
    end

    it "raises Airwallex::WebhookSignatureError when timestamp is outside tolerance" do
      old_timestamp = (Time.now.to_i - 600).to_s
      old_signature = sign(payload, old_timestamp, secret)

      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: old_signature,
          timestamp: old_timestamp,
          secret: secret
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Timestamp outside tolerance")
    end

    it "supports millisecond timestamps" do
      ms_timestamp = (Time.now.to_i * 1000).to_s
      ms_signature = sign(payload, ms_timestamp, secret)

      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: ms_signature,
          timestamp: ms_timestamp,
          secret: secret
        )
      end.not_to raise_error
    end

    it "allows tolerance to be customized" do
      old_timestamp = (Time.now.to_i - 600).to_s
      old_signature = sign(payload, old_timestamp, secret)

      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: old_signature,
          timestamp: old_timestamp,
          secret: secret,
          tolerance: 900
        )
      end.not_to raise_error
    end

    it "raises Airwallex::WebhookSignatureError for invalid tolerance" do
      expect do
        described_class.verify_signature!(
          payload: payload,
          signature: signature,
          timestamp: timestamp,
          secret: secret,
          tolerance: 0
        )
      end.to raise_error(Airwallex::WebhookSignatureError, "Invalid tolerance")
    end

    it "uses secure comparison instead of plain equality for signature comparison" do
      expected_signature = sign(payload, timestamp, secret)

      expect(described_class).to receive(:secure_compare).with(expected_signature, signature).and_call_original

      described_class.verify_signature!(
        payload: payload,
        signature: signature,
        timestamp: timestamp,
        secret: secret
      )
    end
  end
end
