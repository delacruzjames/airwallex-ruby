# frozen_string_literal: true

RSpec.describe Airwallex::Resources::Authentication do
  it "inherits from Airwallex::Resources::BaseResource" do
    expect(described_class).to be < Airwallex::Resources::BaseResource
  end
end
