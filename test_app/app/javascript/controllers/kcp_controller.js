import { Controller } from "@hotwired/stimulus";

// data-controller="kcp"
// Values:
//   data-kcp-order-id-value
//   data-kcp-amount-value
//   data-kcp-buyer-name-value
//   data-kcp-buyer-email-value
//   data-kcp-product-name-value
//   data-kcp-return-url-value
//   data-kcp-escrow-value
//   data-kcp-tax-free-amount-value

export default class extends Controller {
  static values = {
    orderId: String,
    amount: Number,
    buyerName: String,
    buyerEmail: String,
    productName: String,
    returnUrl: String,
    escrow: Boolean,
    taxFreeAmount: Number,
  };

  connect() {
    // KCP 스크립트는 서버에서 include되어야 함 (kcp_script_tag)
    console.log("KCP Controller connected");
    
    // 폼 존재 확인
    const form = document.forms["kcp_pay_form"];
    if (form) {
      console.log("KCP form found on page load");
      this.validateFormFields(form);
      
      // KCP 결제 완료 후 폼 submit을 가로채기 위한 리스너 추가
      form.addEventListener('submit', this.handleFormSubmit.bind(this));
    }
    
    // KCP 콜백 처리를 위한 전역 함수 등록
    window.kcp_payment_complete = this.handleKcpCallback.bind(this);
  }
  
  handleFormSubmit(event) {
    console.log("=== Form Submit Intercepted ===");
    console.log("Form data:", new FormData(event.target));
    
    // KCP에서 결과가 있는지 확인
    const form = event.target;
    const resCode = form.elements['res_cd']?.value;
    
    if (resCode) {
      console.log("KCP result detected:", resCode);
      // res_cd가 있으면 KCP에서 결과를 받은 것이므로 정상 진행
      return true;
    } else {
      console.log("No KCP result - preventing default submit");
      // 아직 KCP 처리가 안 되었으면 submit 방지
      event.preventDefault();
      return false;
    }
  }
  
  handleKcpCallback(result) {
    console.log("=== KCP Callback Received ===");
    console.log("Result:", result);
    
    const form = document.forms["kcp_pay_form"];
    if (form && result) {
      // 결과를 폼에 설정
      if (form.elements['res_cd']) form.elements['res_cd'].value = result.res_cd || '';
      if (form.elements['res_msg']) form.elements['res_msg'].value = result.res_msg || '';
      if (form.elements['tno']) form.elements['tno'].value = result.tno || '';
      
      // 폼을 서버로 제출
      form.submit();
    }
  }
  
  validateFormFields(form) {
    console.log("=== Form Validation ===");
    
    // KCP 필수 필드 목록 (KCP 문서 기준)
    const requiredFields = {
      // 가맹점 정보
      'site_cd': 'Site code (가맹점 코드)',
      'site_name': 'Site name (가맹점명)',
      
      // 주문 정보
      'ordr_idxx': 'Order ID (주문번호)',
      'good_name': 'Product name (상품명)',
      'good_mny': 'Amount (결제금액)',
      
      // 구매자 정보
      'buyr_name': 'Buyer name (구매자명)',
      'buyr_mail': 'Buyer email (구매자 이메일)',
      'buyr_tel1': 'Buyer phone (구매자 전화)',
      'buyr_tel2': 'Buyer phone (구매자 전화)',
      
      // 결제 설정
      'pay_method': 'Payment method (결제수단)',
      'curr_cd': 'Currency code (통화코드)',
      'eng_flag': 'Language flag (언어)',
      
      // 추가 필수 필드
      'req_tx': 'Request type (요청구분)',
      'encoding_trans': 'Encoding (인코딩)'
    };
    
    let missingFields = [];
    let emptyFields = [];
    
    for (const [fieldName, description] of Object.entries(requiredFields)) {
      const field = form.elements[fieldName];
      if (!field) {
        missingFields.push(`${fieldName} (${description})`);
      } else if (!field.value || field.value.trim() === '') {
        emptyFields.push(`${fieldName} (${description})`);
      }
    }
    
    if (missingFields.length > 0) {
      console.error("MISSING FIELDS:", missingFields);
    }
    
    if (emptyFields.length > 0) {
      console.warn("EMPTY FIELDS:", emptyFields);
    }
    
    if (missingFields.length === 0 && emptyFields.length === 0) {
      console.log("✓ All required fields present and populated");
    }
    
    return missingFields.length === 0;
  }

  requestPayment(event) {
    event?.preventDefault();

    // 폼 찾기
    const form = document.forms["kcp_pay_form"] || document.getElementById("kcp_pay_form");
    if (!form) {
      console.error("Form 'kcp_pay_form' not found");
      return;
    }

    // KCP 스크립트 로드 확인
    console.log("=== KCP Payment Debug ===");
    console.log("Form found:", form.name || form.id);
    console.log("KCP_Pay_Execute type:", typeof window.KCP_Pay_Execute);
    console.log("Form action:", form.action);
    console.log("Form method:", form.method);

    // 모든 폼 필드 확인
    console.log("All form elements:");
    for (let i = 0; i < form.elements.length; i++) {
      const element = form.elements[i];
      if (element.name && element.type === 'hidden') {
        console.log(`${element.name}: "${element.value}"`);
      }
    }
    
    // KCP가 일반적으로 확인하는 필드들
    const kcpFields = [
      'site_cd', 'ordr_idxx', 'good_mny', 'buyr_name', 'pay_method', 'curr_cd',
      'buyr_tel1', 'buyr_tel2', 'buyr_tel3', 'buyr_mail', 'good_name',
      'Ret_URL', 'mod_type', 'eng_flag', 'shop_user_id'
    ];
    console.log("\nKCP critical fields:");
    kcpFields.forEach(fieldName => {
      const field = form.elements[fieldName];
      if (!field) {
        console.error(`MISSING REQUIRED FIELD: ${fieldName}`);
      } else if (!field.value || field.value.trim() === '') {
        console.error(`EMPTY REQUIRED FIELD: ${fieldName}`);
      } else {
        console.log(`${fieldName}: "${field.value}"`);
      }
    });

    // KCP JavaScript 함수 직접 확인
    console.log("KCP functions available:");
    console.log("KCP_Pay_Execute:", typeof window.KCP_Pay_Execute);
    
    if (typeof window.KCP_Pay_Execute !== "function") {
      console.warn("KCP JavaScript not loaded properly. Running demo mode...");
      this.runDemoPayment(form);
      return;
    }
    
    // KCP JavaScript가 로드된 경우 실제 호출
    try {
      console.log("\n=== Attempting KCP_Pay_Execute ===");
      
      // KCP 함수가 폼 객체를 기대하는 경우를 위한 시도
      if (form && typeof window.KCP_Pay_Execute === "function") {
        // 다양한 호출 방식 시도
        try {
          console.log("Trying: KCP_Pay_Execute with form name string");
          window.KCP_Pay_Execute("kcp_pay_form");
        } catch (e1) {
          console.error("Method 1 failed:", e1.message);
          
          try {
            console.log("Trying: KCP_Pay_Execute with form object");
            window.KCP_Pay_Execute(form);
          } catch (e2) {
            console.error("Method 2 failed:", e2.message);
            
            try {
              console.log("Trying: KCP_Pay_Execute with no arguments");
              window.KCP_Pay_Execute();
            } catch (e3) {
              console.error("Method 3 failed:", e3.message);
              throw e1; // Re-throw original error
            }
          }
        }
      } else {
        console.warn("KCP JavaScript not properly loaded");
        this.runDemoPayment(form);
      }
    } catch (e) {
      console.error("KCP_Pay_Execute failed:", e);
      console.error("Error stack:", e.stack);
      console.warn("\nFalling back to demo mode...");
      this.runDemoPayment(form);
    }
  }

  runDemoPayment(form) {
    console.log("=== KCP 결제 데모 모드 ===");
    
    // 폼 데이터 추출
    const orderData = {
      orderId: form.elements['ordr_idxx'].value,
      productName: form.elements['good_name'].value,
      amount: form.elements['good_mny'].value,
      buyerName: form.elements['buyr_name'].value,
      buyerEmail: form.elements['buyr_mail'].value,
      payMethod: form.elements['pay_method'].value
    };
    
    console.log("결제 정보:", orderData);
    
    // 결제 수단별 메시지
    let payMethodName = "알 수 없음";
    if (orderData.payMethod === "100000000000") payMethodName = "신용카드";
    else if (orderData.payMethod === "010000000000") payMethodName = "계좌이체";
    else if (orderData.payMethod === "001000000000") payMethodName = "가상계좌";
    
    // 결제 진행 시뮬레이션
    const message = `
데모 결제를 진행합니다:

• 주문번호: ${orderData.orderId}
• 상품명: ${orderData.productName}
• 결제금액: ${parseInt(orderData.amount).toLocaleString()}원
• 구매자: ${orderData.buyerName}
• 결제수단: ${payMethodName}

실제 KCP 계정이 설정되면 실제 결제창이 열립니다.
데모로 결제 성공 처리하시겠습니까?
    `.trim();
    
    if (confirm(message)) {
      // 결제 성공 시뮬레이션
      this.simulatePaymentSuccess(orderData);
    } else {
      console.log("데모 결제 취소됨");
    }
  }
  
  simulatePaymentSuccess(orderData) {
    console.log("결제 성공 시뮬레이션 중...");
    
    // 2초 후 성공 페이지로 이동 (실제 KCP 콜백 시뮬레이션)
    setTimeout(() => {
      const successUrl = `/payments/success?order_no=${orderData.orderId}&demo=true`;
      window.location.href = successUrl;
    }, 2000);
    
    // 로딩 표시
    document.body.style.opacity = "0.7";
    document.body.style.pointerEvents = "none";
    
    const loading = document.createElement('div');
    loading.innerHTML = `
      <div style="
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: white;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        z-index: 9999;
        text-align: center;
      ">
        <div style="margin-bottom: 15px;">⏳</div>
        <div>데모 결제 처리 중...</div>
        <div style="font-size: 12px; color: #666; margin-top: 10px;">
          실제 환경에서는 KCP 결제창이 열립니다
        </div>
      </div>
    `;
    document.body.appendChild(loading);
  }
}
