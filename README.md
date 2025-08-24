# KCP Payments Rails

Rails 7/8에서 KCP 표준결제 연동을 간편하게 도와주는 Rails Engine + Stimulus 래퍼 젬입니다.

## 설치

```ruby
gem "kcppayments_rails", github: "luciuschoi/kcppayments_rails"
```

```bash
bundle install
bin/rails g kcppayments_rails:install
```

## 초기화 설정

`config/initializers/kcppayments_rails.rb` 파일을 열어 KCP 상점 정보를 설정하세요.

## 뷰 사용 예시 (ERB)

```erb
<%= kcp_script_tag %>

<%= form_with url: checkout_payments_path, method: :post, **kcp_form_attrs(
  order_id: @order.number,
  amount: @order.total_price,
  buyer_name: current_user.name,
  buyer_email: current_user.email,
  product_name: @order.summary,
  return_url: payment_complete_url
) do |f| %>
  <button data-controller="kcp" data-action="click->kcp#requestPayment">결제하기</button>
<% end %>
```

## 서버 처리

승인/취소 등의 서버-서버 통신은 `KcppaymentsRails::Client`를 사용하세요.

```ruby
client = KcppaymentsRails::Client.new
result = client.approve({ # KCP 요구 파라미터 })
```

## 주의사항

- KCP 표준결제는 레거시 스크립트를 로드합니다. `kcp_script_tag`를 `<head>` 혹은 `<body>` 상단에서 불러오세요.
- 상점코드(`site_cd`)와 키(`site_key`)는 환경변수 또는 이니셜라이저에서 설정하세요.
