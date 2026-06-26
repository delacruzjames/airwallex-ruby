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
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    tracked_files = if system("git rev-parse --is-inside-work-tree >/dev/null 2>&1")
                      `git ls-files -z`.split("\x0").reject do |path|
                        path.start_with?("spec/", ".github/") || path == "Gemfile.lock"
                      end
                    end

    next tracked_files if tracked_files&.any?

    Dir["{lib,docs}/**/*", "README.md", "CHANGELOG.md", "LICENSE.txt", "airwallex-ruby.gemspec"]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "json", "~> 2.0"
end
