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
  }

  requestPayment(event) {
    event?.preventDefault();

    if (typeof window.KCP_Pay_Execute !== "function") {
      console.error(
        "KCP_Pay_Execute is not loaded. Make sure kcp_script_tag is included."
      );
      return;
    }

    // 폼과 필드 확인
    const form = document.forms["kcp_pay_form"] || document.getElementById("kcp_pay_form");
    if (!form) {
      console.error("Form not found");
      return;
    }

    // 모든 폼 필드 확인
    console.log("All form elements:");
    for (let i = 0; i < form.elements.length; i++) {
      const element = form.elements[i];
      if (element.name && element.type === 'hidden') {
        console.log(`${element.name}: "${element.value}"`);
      }
    }
    
    // KCP가 일반적으로 확인하는 필드들
    const kcpFields = ['site_cd', 'ordr_idxx', 'good_mny', 'buyr_name', 'pay_method', 'curr_cd'];
    console.log("\nKCP critical fields:");
    kcpFields.forEach(fieldName => {
      const field = form.elements[fieldName];
      console.log(`${fieldName}:`, field ? `"${field.value}"` : 'NOT FOUND');
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
      console.log("Calling KCP_Pay_Execute...");
      window.KCP_Pay_Execute("kcp_pay_form");
    } catch (e) {
      console.error("KCP_Pay_Execute failed:", e);
      console.warn("Falling back to demo mode...");
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
