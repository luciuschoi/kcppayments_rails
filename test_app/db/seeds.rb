# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# KCP 결제 테스트용 샘플 주문 데이터 생성
puts "Creating sample orders..."

# 일반 과세 상품 주문
Order.find_or_create_by!(order_no: "ORD20240101001") do |order|
  order.product_name = "노트북 - MacBook Pro 14인치"
  order.amount = 2500000
  order.buyer_name = "홍길동"
  order.buyer_email = "hong@example.com"
  order.status = "pending"
  order.tax_free_amount = 0
end

# 면세 상품 포함 주문
Order.find_or_create_by!(order_no: "ORD20240101002") do |order|
  order.product_name = "도서 - Ruby on Rails 완벽 가이드"
  order.amount = 35000
  order.buyer_name = "김철수"
  order.buyer_email = "kim@example.com"
  order.status = "pending"
  order.tax_free_amount = 35000  # 도서는 면세
end

# 부분 면세 상품 주문
Order.find_or_create_by!(order_no: "ORD20240101003") do |order|
  order.product_name = "식료품 세트 (일부 면세)"
  order.amount = 100000
  order.buyer_name = "이영희"
  order.buyer_email = "lee@example.com"
  order.status = "pending"
  order.tax_free_amount = 30000  # 30,000원만 면세
end

# 소액 결제 테스트
Order.find_or_create_by!(order_no: "ORD20240101004") do |order|
  order.product_name = "커피 - 아메리카노"
  order.amount = 4500
  order.buyer_name = "박민수"
  order.buyer_email = "park@example.com"
  order.status = "pending"
  order.tax_free_amount = 0
end

# 고액 결제 테스트
Order.find_or_create_by!(order_no: "ORD20240101005") do |order|
  order.product_name = "전자제품 - OLED TV 65인치"
  order.amount = 3500000
  order.buyer_name = "최영수"
  order.buyer_email = "choi@example.com"
  order.status = "pending"
  order.tax_free_amount = 0
end

# 이미 결제된 주문 (테스트용)
Order.find_or_create_by!(order_no: "ORD20240101006") do |order|
  order.product_name = "이어폰 - AirPods Pro"
  order.amount = 350000
  order.buyer_name = "정미영"
  order.buyer_email = "jung@example.com"
  order.status = "paid"
  order.payment_method = "신용카드"
  order.tax_free_amount = 0
end

# 결제 실패한 주문 (테스트용)
Order.find_or_create_by!(order_no: "ORD20240101007") do |order|
  order.product_name = "태블릿 - iPad Pro 11인치"
  order.amount = 1200000
  order.buyer_name = "강동원"
  order.buyer_email = "kang@example.com"
  order.status = "failed"
  order.tax_free_amount = 0
end

puts "Created #{Order.count} sample orders."
puts "You can now start the Rails server with 'bin/rails server' and visit http://localhost:3000"