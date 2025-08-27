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
        payment_method: params[:pay_method]
      )
      redirect_to success_payments_path(order_id: order.id)
    else
      order.update(status: "failed")
      redirect_to failure_payments_path(order_id: order.id)
    end
  end

  def success
    @order = if params[:order_no]
      Order.find_by!(order_no: params[:order_no])
    else
      Order.find(params[:order_id])
    end
    
    # 데모 모드인 경우 주문을 결제 완료로 업데이트
    if params[:demo] == 'true'
      @order.update(
        status: "paid",
        payment_method: "데모 결제 (#{get_payment_method_name(@order)})"
      )
      @demo_mode = true
    end
  end
  
  private
  
  def get_payment_method_name(order)
    # 임시로 신용카드로 설정 (실제로는 선택된 결제 수단 기반)
    "신용카드"
  end

  def failure
    @order = if params[:order_no]
      Order.find_by!(order_no: params[:order_no])
    else
      Order.find(params[:order_id])
    end
  end
end