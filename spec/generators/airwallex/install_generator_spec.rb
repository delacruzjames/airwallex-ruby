# frozen_string_literal: true

RSpec.describe "Airwallex::Generators::InstallGenerator" do
  let(:template_path) do
    File.expand_path("../../../lib/generators/airwallex/install/templates/airwallex.rb", __dir__)
  end

  let(:template_content) { File.read(template_path) }

  describe "generator class" do
    it "exists when Rails is available" do
      skip "Rails not available" unless rails_available?

      require "rails/generators"
      require "generators/airwallex/install/install_generator"

      expect(Airwallex::Generators::InstallGenerator).to be < Rails::Generators::Base
    end
  end

  describe "initializer template" do
    it "exists" do
      expect(File).to exist(template_path)
    end

    it "uses Rails.application.credentials.dig(:airwallex, :client_id)" do
      expect(template_content).to include("Rails.application.credentials.dig(:airwallex, :client_id)")
    end

    it "falls back to ENV[\"AIRWALLEX_CLIENT_ID\"]" do
      expect(template_content).to include('ENV["AIRWALLEX_CLIENT_ID"]')
    end

    it "includes api_key configuration" do
      expect(template_content).to include("config.api_key")
      expect(template_content).to include("Rails.application.credentials.dig(:airwallex, :api_key)")
    end

    it "includes login_as configuration" do
      expect(template_content).to include("config.login_as")
      expect(template_content).to include("Rails.application.credentials.dig(:airwallex, :login_as)")
    end

    it "sets production environment to :production" do
      expect(template_content).to include("Rails.env.production? ? :production")
    end

    it "sets non-production environment to :demo" do
      expect(template_content).to include(":demo")
    end

    it "sets timeout" do
      expect(template_content).to include("config.timeout = 30")
    end

    it "sets open_timeout" do
      expect(template_content).to include("config.open_timeout = 10")
    end
  end

  def rails_available?
    require "rails/generators"
    true
  rescue LoadError
    false
  end
end
