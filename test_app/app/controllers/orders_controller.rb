class OrdersController < ApplicationController
  def index
    @orders = Order.all
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.order_no = "ORD#{Time.now.to_i}"
    @order.status = "pending"
    
    if @order.save
      redirect_to @order, notice: '주문이 생성되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:product_name, :amount, :buyer_name, :buyer_email, :tax_free_amount)
  end
end