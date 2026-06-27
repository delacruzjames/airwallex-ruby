# frozen_string_literal: true

RSpec.describe "sandbox integration scripts" do
  let(:root) { File.expand_path("../..", __dir__) }

  it "includes docs/sandbox.md" do
    expect(File).to exist(File.join(root, "docs", "sandbox.md"))
  end

  it "includes .env.example" do
    expect(File).to exist(File.join(root, ".env.example"))
  end

  %w[
    support.rb
    authenticate.rb
    create_payment_intent.rb
    retrieve_payment_intent.rb
    create_refund.rb
    verify_webhook_signature.rb
  ].each do |script|
    it "includes scripts/sandbox/#{script}" do
      expect(File).to exist(File.join(root, "scripts", "sandbox", script))
    end
  end

  describe ".env.example" do
    let(:contents) { File.read(File.join(root, ".env.example")) }

    it "includes AIRWALLEX_CLIENT_ID" do
      expect(contents).to include("AIRWALLEX_CLIENT_ID")
    end

    it "includes AIRWALLEX_API_KEY" do
      expect(contents).to include("AIRWALLEX_API_KEY")
    end
  end

  describe "docs/sandbox.md" do
    let(:contents) { File.read(File.join(root, "docs", "sandbox.md")) }

    it "includes sandbox credential safety guidance" do
      expect(contents).to include("Use Airwallex sandbox/demo credentials only")
    end

    it "includes .env commit guidance" do
      expect(contents).to include("Never commit `.env`")
    end
  end

  describe "script safety" do
    it "does not print API keys from authenticate script output statements" do
      contents = File.read(File.join(root, "scripts", "sandbox", "authenticate.rb"))
      output_lines = contents.lines.grep(/\b(puts|print|warn|p)\b/)

      expect(output_lines.join).not_to include("AIRWALLEX_API_KEY}")
    end

    it "does not print full client_secret from create_payment_intent script" do
      contents = File.read(File.join(root, "scripts", "sandbox", "create_payment_intent.rb"))

      expect(contents).not_to include('payment_intent["client_secret"]')
      expect(contents).not_to include("client_secret']")
    end

    it "does not print webhook secret from verify_webhook_signature script" do
      contents = File.read(File.join(root, "scripts", "sandbox", "verify_webhook_signature.rb"))
      output_lines = contents.lines.grep(/\b(puts|print|warn|p)\b/)

      expect(output_lines.join).not_to include("AIRWALLEX_WEBHOOK_SECRET")
    end
  end
end
