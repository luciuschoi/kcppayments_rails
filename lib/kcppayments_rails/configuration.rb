# frozen_string_literal: true

module KcppaymentsRails
  class Configuration
    # KCP 표준결제 기본 설정 값들
    attr_accessor :site_cd, :site_key, :gateway_url, :js_url, :escrow, :tax_free_amount_field

    def initialize
      @site_cd = ENV["KCP_SITE_CD"]
      @site_key = ENV["KCP_SITE_KEY"]
      @gateway_url = ENV["KCP_GATEWAY_URL"] || "https://testpaygw.kcp.co.kr"
      @js_url = ENV["KCP_JS_URL"] || "https://testpay.kcp.co.kr/plugin/payplus_web.jsp"
      # @target_url = if Rails.env.production? # 운영서버
      #     "https://spl.kcp.co.kr"
      #   else # Rails.env.development? || Rails.env.staging? # 개발서버 또는 스테이징서버
      #     "https://stg-spl.kcp.co.kr"
      #   end
      @escrow = false
      @tax_free_amount_field = :tax_free_amount
    end
  end
end


