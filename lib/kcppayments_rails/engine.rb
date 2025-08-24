# frozen_string_literal: true

require "rails/engine"

module KcppaymentsRails
  class Engine < ::Rails::Engine
    isolate_namespace KcppaymentsRails

    initializer "kcppayments_rails.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        require_relative "helpers/kcp_helper"
        include KcppaymentsRails::KcpHelper
      end
    end
  end
end


