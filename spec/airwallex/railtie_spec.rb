# frozen_string_literal: true

RSpec.describe "Airwallex Rails integration" do
  describe "requiring the gem outside Rails" do
    it "loads without Rails" do
      expect { require "airwallex" }.not_to raise_error
      expect(Airwallex).to be_a(Module)
    end

    it "does not define Railtie when Rails is not loaded" do
      skip "Rails is loaded" if defined?(Rails::Railtie)

      expect(Airwallex.const_defined?(:Railtie, false)).to be(false)
    end
  end

  describe "Railtie" do
    it "is defined when Rails is loaded" do
      skip "Rails not available" unless rails_available?

      require "airwallex/railtie"

      expect(Airwallex::Railtie).to be < Rails::Railtie
    end
  end

  def rails_available?
    require "active_support/all"
    require "rails/railtie"
    true
  rescue LoadError, NoMethodError
    false
  end
end
