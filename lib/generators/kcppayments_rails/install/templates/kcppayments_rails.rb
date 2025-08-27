# frozen_string_literal: true

# KcpPaymentsRails 초기화 설정
KcppaymentsRails.configure do |config|
  # 테스트/운영 계정에 맞게 설정하세요
  # config.site_cd = ENV["KCP_SITE_CD"]
  # config.site_key = ENV["KCP_SITE_KEY"]
  # config.gateway_url = "https://testpaygw.kcp.co.kr"
  # config.js_url = "https://testpay.kcp.co.kr/plugin/payplus_web.jsp"
  # config.escrow = false
  # config.tax_free_amount_field = :tax_free_amount
end


