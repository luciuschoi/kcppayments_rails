class Order < ApplicationRecord
  # KCP 공식 영수증 URL 생성
  def kcp_receipt_url
    return nil unless kcp_transaction_no.present?
    
    # 결제 수단에 따른 cmd 파라미터 결정
    cmd = case payment_method_type
          when 'credit_card'
            'card_bill'
          when 'bank_transfer'
            'acnt_bill'
          when 'virtual_account'
            'vcnt_bill'
          when 'mobile_cash'
            'mcash_bill'
          else
            'card_bill' # 기본값
          end
    
    base_url = "https://admin8.kcp.co.kr/assist/bill.BillActionNew.do"
    params = {
      cmd: cmd,
      tno: kcp_transaction_no,
      order_no: order_no,
      trade_mony: amount
      # 주의: site_cd 파라미터는 실제 KCP 가맹점 코드가 필요합니다
    }
    
    "#{base_url}?#{params.to_query}"
  end
  
  # 영수증 사용 가능 여부 확인
  def kcp_receipt_available?
    status == "paid" && kcp_transaction_no.present?
  end
  
  # 실제 KCP 거래인지 확인 (개발/데모 환경 구분)
  def real_kcp_transaction?
    return false unless kcp_transaction_no.present?
    
    # 데모 거래번호 패턴 확인
    is_demo = kcp_transaction_no.match?(/^(DEMO|KCP)/) || 
              created_at > 1.day.ago && Rails.env.development?
    
    !is_demo
  end
  
  private
  
  # 결제 수단 타입 결정 (payment_method에서 추출)
  def payment_method_type
    return 'credit_card' unless payment_method.present?
    
    case payment_method.downcase
    when /credit|card|신용|카드/
      'credit_card'
    when /bank|transfer|계좌|이체/
      'bank_transfer'
    when /virtual|account|가상|계좌/
      'virtual_account'
    when /mobile|cash|모바일|현금/
      'mobile_cash'
    else
      'credit_card'
    end
  end
end
