# frozen_string_literal: true

RSpec.describe "repository files" do
  let(:root) { File.expand_path("../..", __dir__) }

  {
    "CONTRIBUTING.md" => "Development setup",
    "SECURITY.md" => "Reporting a Vulnerability",
    "CODE_OF_CONDUCT.md" => "Contributor Covenant",
    ".github/workflows/ci.yml" => "bundle exec rspec",
    ".github/ISSUE_TEMPLATE/bug_report.md" => "Steps to reproduce",
    ".github/ISSUE_TEMPLATE/feature_request.md" => "Proposed solution",
    ".github/pull_request_template.md" => "Checklist",
    "docs/github.md" => "GitHub Repository Checklist",
    "docs/examples.md" => "Basic Ruby usage",
    "examples/rails_app/README.md" => "Airwallex Ruby Rails Example",
    "examples/rails_app/config/initializers/airwallex.rb" => "Airwallex.configure",
    "examples/rails_app/config/routes.rb" => "airwallex_webhooks#create",
    "examples/rails_app/app/controllers/airwallex_demo_controller.rb" => "create_payment_intent",
    "examples/rails_app/app/controllers/airwallex_webhooks_controller.rb" => "Airwallex::Webhook.construct_event"
  }.each do |relative_path, expected_content|
    it "includes #{relative_path}" do
      path = File.join(root, relative_path)
      expect(File).to exist(path), "expected #{relative_path} to exist"
      expect(File.read(path)).to include(expected_content)
    end
  end
end
