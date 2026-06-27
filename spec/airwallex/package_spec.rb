# frozen_string_literal: true

RSpec.describe "gem package" do
  let(:root) { File.expand_path("../..", __dir__) }
  let(:gemspec) { Gem::Specification.load(File.join(root, "airwallex-ruby.gemspec")) }

  it "has version 0.1.0" do
    expect(Airwallex::VERSION).to eq("0.1.0")
  end

  it "has the correct gem name" do
    expect(gemspec.name).to eq("airwallex-ruby")
  end

  it "requires Ruby 3.1 or newer" do
    expect(gemspec.required_ruby_version).to eq(Gem::Requirement.new(">= 3.1.0"))
  end

  it "depends on faraday" do
    expect(gemspec.dependencies.map(&:name)).to include("faraday")
  end

  it "depends on json" do
    expect(gemspec.dependencies.map(&:name)).to include("json")
  end

  it "includes README.md" do
    expect(File).to exist(File.join(root, "README.md"))
    expect(gemspec.files).to include("README.md")
  end

  it "includes CHANGELOG.md" do
    expect(File).to exist(File.join(root, "CHANGELOG.md"))
    expect(gemspec.files).to include("CHANGELOG.md")
  end

  it "includes a license file" do
    license_path = %w[LICENSE LICENSE.txt].find { |name| File.exist?(File.join(root, name)) }
    expect(license_path).not_to be_nil
    expect(gemspec.files).to include(license_path)
  end

  it "includes docs/release.md" do
    expect(File).to exist(File.join(root, "docs", "release.md"))
    expect(gemspec.files).to include("docs/release.md")
  end

  it "does not include spec files in the packaged gem" do
    expect(gemspec.files.none? { |path| path.start_with?("spec/") }).to be(true)
  end

  it "does not include the Rails sample app in the packaged gem" do
    expect(gemspec.files.none? { |path| path.start_with?("examples/rails_app/") }).to be(true)
  end
end
