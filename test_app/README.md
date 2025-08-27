# KCP Payments Rails 테스트 애플리케이션

이 애플리케이션은 `kcppayments_rails` 젬을 테스트하기 위한 Rails 8 샘플 애플리케이션입니다.

## 시작하기

### 1. 설치 및 설정

```bash
# 테스트 앱 디렉토리로 이동
cd test_app

# 의존성 설치 (이미 완료됨)
bundle install

# 데이터베이스 마이그레이션 (이미 완료됨)
bin/rails db:migrate

# 샘플 데이터 생성 (이미 완료됨)
bin/rails db:seed
```

### 2. KCP 테스트 계정 설정

`config/initializers/kcppayments_rails.rb` 파일에서 KCP 테스트 계정 정보를 설정하세요:

```ruby
KcppaymentsRails.configure do |config|
  config.site_cd = "T0000"  # KCP에서 발급받은 테스트 사이트 코드
  config.site_key = "3grptw1.zW0GSo4PQdaGvsF__"  # KCP에서 발급받은 테스트 사이트 키
end
```

### 3. 애플리케이션 실행

```bash
bin/rails server
```

브라우저에서 http://localhost:3000 접속

## 기능 테스트

### 주요 페이지

1. **주문 목록** (http://localhost:3000)
   - 모든 주문 조회
   - 새 주문 생성
   - 주문별 결제 진행

2. **새 주문 생성** (http://localhost:3000/orders/new)
   - 상품명, 금액, 구매자 정보 입력
   - 면세 금액 설정 가능

3. **결제 페이지** 
   - KCP 결제 모듈 통합
   - 신용카드, 계좌이체, 가상계좌 선택 가능
   - Stimulus 컨트롤러를 통한 결제 처리

### 테스트 시나리오

#### 1. 일반 결제 테스트
- 주문 목록에서 "노트북 - MacBook Pro 14인치" 선택
- "결제하기" 클릭
- 결제 수단 선택 후 결제 진행

#### 2. 면세 상품 테스트
- 주문 목록에서 "도서 - Ruby on Rails 완벽 가이드" 선택
- 전액 면세 처리 확인
- 결제 진행

#### 3. 부분 면세 테스트
- 주문 목록에서 "식료품 세트" 선택
- 부분 면세 금액 확인 (30,000원)
- 결제 진행

## 주요 파일 구조

```
test_app/
├── app/
│   ├── controllers/
│   │   ├── orders_controller.rb      # 주문 관리
│   │   └── payments_controller.rb    # 결제 처리
│   ├── models/
│   │   └── order.rb                  # 주문 모델
│   ├── views/
│   │   ├── orders/                   # 주문 관련 뷰
│   │   └── payments/                  # 결제 관련 뷰
│   └── javascript/
│       └── controllers/
│           └── kcp_controller.js      # KCP Stimulus 컨트롤러
├── config/
│   ├── routes.rb                     # 라우팅 설정
│   └── initializers/
│       └── kcppayments_rails.rb      # KCP 설정
└── db/
    └── seeds.rb                       # 샘플 데이터
```

## KCP 헬퍼 사용 예시

### 뷰에서 KCP 스크립트 로드
```erb
<%= kcp_script_tag %>
```

### 결제 폼에 KCP 데이터 속성 추가
```erb
<%= form_with html: kcp_form_attrs(
  order_id: @order.order_no,
  amount: @order.amount,
  buyer_name: @order.buyer_name,
  buyer_email: @order.buyer_email,
  product_name: @order.product_name,
  tax_free_amount: @order.tax_free_amount
) do |form| %>
  <!-- 폼 내용 -->
<% end %>
```

## 데모 모드

### KCP 계정이 없는 경우
이 테스트 앱은 **데모 모드**를 제공합니다:

1. **자동 감지**: KCP JavaScript가 로드되지 않으면 자동으로 데모 모드로 전환
2. **시뮬레이션**: 실제 결제 플로우를 시뮬레이션하여 젬 기능 테스트 가능
3. **완전한 테스트**: 주문 생성부터 결제 완료까지 전체 플로우 확인

**데모 모드에서 테스트 가능한 기능:**
- ✅ KCP 헬퍼 메소드 (`kcp_script_tag`, `kcp_form_attrs`)
- ✅ Stimulus 컨트롤러 통합
- ✅ 결제 폼 데이터 속성
- ✅ 결제 성공/실패 플로우
- ✅ 주문 상태 업데이트

## 실제 KCP 연동

### 1. KCP 계정 설정
실제 운영을 위해서는 KCP에서 발급받은 계정이 필요합니다:

```ruby
# config/initializers/kcppayments_rails.rb
KcppaymentsRails.configure do |config|
  config.site_cd = "실제_사이트_코드"
  config.site_key = "실제_사이트_키"
end
```

### 2. 도메인 등록
- KCP 관리자 페이지에서 서비스 도메인 등록 필요
- localhost는 테스트 계정에서만 허용되는 경우가 많음

## 문제 해결

### 결제 모듈이 로드되지 않는 경우
- KCP 사이트 코드와 키가 올바른지 확인
- 도메인이 KCP에 등록되어 있는지 확인
- JavaScript 콘솔에서 에러 확인
- 네트워크 탭에서 KCP 스크립트 로드 확인
- **데모 모드로 기본 기능 테스트 가능**

### 결제 후 콜백이 작동하지 않는 경우
- `payments_controller.rb`의 `callback` 액션 확인
- CSRF 토큰 검증이 스킵되었는지 확인
- 서버 로그에서 파라미터 확인

## 추가 개발

이 테스트 앱을 기반으로 다음과 같은 기능을 추가할 수 있습니다:

- 결제 취소 기능
- 결제 내역 조회
- 영수증 발급
- 정기 결제
- 부분 취소

## 라이선스

이 테스트 애플리케이션은 `kcppayments_rails` 젬의 일부입니다.