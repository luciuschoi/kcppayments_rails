# frozen_string_literal: true

require_relative "kcppayments_rails/version"
require_relative "kcppayments_rails/configuration"
require_relative "kcppayments_rails/client"

begin
  require_relative "kcppayments_rails/engine"
rescue LoadError
  # Rails가 아닌 환경에서는 엔진을 로드하지 않습니다.
end

module KcppaymentsRails
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
