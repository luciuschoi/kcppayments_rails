# frozen_string_literal: true

# KcpPaymentsRails 초기화 설정
KcppaymentsRails.configure do |config|
  # KCP 테스트 계정 설정 (실제 테스트 계정 정보로 변경 필요)
  config.site_cd = ENV["KCP_SITE_CD"] || "T0000"  # 테스트 사이트 코드
  config.site_key = ENV["KCP_SITE_KEY"] || "3grptw1.zW0GSo4PQdaGvsF__"  # 테스트 사이트 키
  
  # 개발 환경에서는 테스트 서버 사용
  if Rails.env.development?
    config.gateway_url = "https://testpaygw.kcp.co.kr"
    config.js_url = "https://testpay.kcp.co.kr/plugin/payplus_web.jsp"
  else
    config.gateway_url = "https://paygw.kcp.co.kr"
    config.js_url = "https://pay.kcp.co.kr/plugin/payplus_web.jsp"
    config.kcp_cert_info = ENV["KCP_CERT_INFO"]
  end
  
  # 에스크로 사용 여부
  config.escrow = false
  
  # 면세 금액 필드 이름
  config.tax_free_amount_field = :tax_free_amount
end