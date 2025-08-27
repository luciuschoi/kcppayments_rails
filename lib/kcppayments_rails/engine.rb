# frozen_string_literal: true

require "rails/engine"

module KcppaymentsRails
  class Engine < ::Rails::Engine
    isolate_namespace KcppaymentsRails

    initializer "kcppayments_rails.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        include KcppaymentsRails::KcpHelper
      end
      
      ActiveSupport.on_load(:action_controller) do
        helper KcppaymentsRails::KcpHelper
      end
    end
  end
end


