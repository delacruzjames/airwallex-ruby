# frozen_string_literal: true

require_relative "lib/airwallex/version"

Gem::Specification.new do |spec|
  spec.name = "airwallex-ruby"
  spec.version = Airwallex::VERSION
  spec.authors = ["James Martin Dela Cruz"]
  spec.email = ["delacruzjamesmartin@gmail.com"]

  spec.summary = "Unofficial Ruby SDK for Airwallex APIs"
  spec.description = "An unofficial Ruby client library for Airwallex payment, payout, and treasury APIs."
  spec.homepage = "https://github.com/delacruzjames/airwallex-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    files = if system("git rev-parse --is-inside-work-tree >/dev/null 2>&1")
              `git ls-files -z`.split("\x0").reject do |path|
                path.start_with?("spec/", ".github/", "examples/rails_app/") ||
                  path == "Gemfile.lock" ||
                  path.end_with?(".gem") ||
                  path.start_with?(".env")
              end
            end

    if files.nil? || files.empty?
      files = Dir["{lib,docs}/**/*", "README.md", "CHANGELOG.md", "LICENSE.txt", "airwallex-ruby.gemspec"]
    end

    %w[README.md CHANGELOG.md LICENSE.txt docs/release.md].each do |path|
      files << path if File.exist?(path) && !files.include?(path)
    end

    files
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "json", "~> 2.0"

  spec.add_development_dependency "dotenv", "~> 3.0"
  spec.add_development_dependency "rails", ">= 7.2", "< 8"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop", "~> 1.75"
  spec.add_development_dependency "webmock", "~> 3.23"
end
