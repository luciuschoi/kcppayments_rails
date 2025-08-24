# frozen_string_literal: true

require "rails/generators"

module KcppaymentsRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_stimulus_controller
        template "kcp_controller.js", "app/javascript/controllers/kcp_controller.js"
      end

      def create_initializer
        template "kcppayments_rails.rb", "config/initializers/kcppayments_rails.rb"
      end
    end
  end
end


