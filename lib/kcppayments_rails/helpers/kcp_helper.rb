# frozen_string_literal: true

module KcppaymentsRails
  module KcpHelper
    # KCP 표준결제 스크립트 로더
    def kcp_script_tag
      src = KcppaymentsRails.configuration.js_url
      # KCP는 전통적으로 jsp 경로를 로드합니다 (ex: payplus_web.jsp)
      # 레거시 리소스이므로 async/defer 없이 삽입하는 것을 권장합니다.
      javascript_include_tag(src)
    end

    # 결제 폼에 필요한 hidden 필드 및 data-controller 속성을 부여
    # form_with 등의 블록 내부에서 사용
    def kcp_form_attrs(order_id:, amount:, buyer_name:, buyer_email:, product_name:, return_url: nil, escrow: nil, tax_free_amount: nil)
      {
        data: {
          controller: "kcp",
          kcp_order_id_value: order_id,
          kcp_amount_value: amount,
          kcp_buyer_name_value: buyer_name,
          kcp_buyer_email_value: buyer_email,
          kcp_product_name_value: product_name,
          kcp_return_url_value: return_url,
          kcp_escrow_value: (escrow.nil? ? KcppaymentsRails.configuration.escrow : escrow),
          kcp_tax_free_amount_value: tax_free_amount
        }
      }
    end
  end
end


