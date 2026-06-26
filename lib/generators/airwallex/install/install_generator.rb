# frozen_string_literal: true

module Airwallex
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "airwallex.rb", "config/initializers/airwallex.rb"
      end
    end
  end
end
