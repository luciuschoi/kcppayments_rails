class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  
  def new
    @order = Order.find(params[:order_id])
  end

  def create
    @order = Order.find(params[:order_id])
    
    # 이 액션은 실제로는 KCP JavaScript에서 결제창을 열기 전에 호출되거나
    # 결제 정보를 서버에서 검증할 때 사용될 수 있습니다.
    # 지금은 결제 폼을 다시 보여줍니다.
    
    flash.now[:notice] = "결제를 진행해주세요."
    render :new
  end

  def callback
    # KCP 결제 콜백 처리
    order = Order.find_by(order_no: params[:ordr_idxx])
    
    if params[:res_cd] == "0000"
      order.update(
        status: "paid",
        payment_method: params[:pay_method],
        kcp_transaction_no: params[:tno] # KCP 거래번호 저장
      )
      redirect_to success_payments_path(order_id: order.id)
    else
      order.update(status: "failed")
      redirect_to failure_payments_path(order_id: order.id)
    end
  end

  def success
    begin
      @order = if params[:order_no].present?
        Order.find_by!(order_no: params[:order_no])
      elsif params[:order_id].present?
        Order.find(params[:order_id])
      else
        Rails.logger.error "PaymentsController#success called without order_id or order_no parameters"
        redirect_to orders_path, alert: "주문 정보를 찾을 수 없습니다." and return
      end
      
      # 데모 모드인 경우 주문을 결제 완료로 업데이트
      if params[:demo] == 'true'
        # 데모용 KCP 거래번호 생성 (14자리 숫자 형식: YYYYMMDDHHMMSS)
        demo_tno = Time.current.strftime('%Y%m%d%H%M%S')
        
        @order.update(
          status: "paid",
          payment_method: "데모 결제 (#{get_payment_method_name(@order)})",
          kcp_transaction_no: demo_tno
        )
        @demo_mode = true
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error "Order not found with params: #{params.inspect}"
      redirect_to orders_path, alert: "주문을 찾을 수 없습니다." and return
    rescue => e
      Rails.logger.error "Unexpected error in success action: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to orders_path, alert: "처리 중 오류가 발생했습니다." and return
    end
  end

  def failure
    begin
      @order = if params[:order_no].present?
        Order.find_by!(order_no: params[:order_no])
      elsif params[:order_id].present?
        Order.find(params[:order_id])
      else
        Rails.logger.error "PaymentsController#failure called without order_id or order_no parameters"
        redirect_to orders_path, alert: "주문 정보를 찾을 수 없습니다." and return
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error "Order not found with params: #{params.inspect}"
      redirect_to orders_path, alert: "주문을 찾을 수 없습니다." and return
    rescue => e
      Rails.logger.error "Unexpected error in failure action: #{e.message}"
      redirect_to orders_path, alert: "처리 중 오류가 발생했습니다." and return
    end
  end

  def receipt
    Rails.logger.debug "Receipt action called with params: #{params.inspect}"
    
    # 더 안전한 방식으로 주문 조회
    @order = Order.find_by(id: params[:id])
    Rails.logger.debug "Found order: #{@order.inspect}"
    
    # 주문이 존재하지 않거나 결제가 완료되지 않은 경우
    if @order.nil?
      Rails.logger.debug "Order not found, redirecting"
      redirect_to orders_path, alert: "주문을 찾을 수 없습니다." and return
    elsif @order.status != "paid"
      Rails.logger.debug "Order status is not paid: #{@order.status}"
      redirect_to orders_path, alert: "결제가 완료된 주문만 영수증을 출력할 수 있습니다." and return
    else
      Rails.logger.debug "Rendering receipt for order: #{@order.id}"
      # 영수증 출력용 레이아웃 없이 렌더링
      render layout: false
    end
  rescue => e
    Rails.logger.error "Unexpected error in receipt action: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    @order = nil  # 확실히 nil로 설정
    redirect_to orders_path, alert: "오류가 발생했습니다." and return
  end
  
  private
  
  def get_payment_method_name(order)
    # 임시로 신용카드로 설정 (실제로는 선택된 결제 수단 기반)
    "신용카드"
  end
end