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

    // 결제 실행 (KCP 페이지의 form name/id 관례를 따를 수 있음)
    const form = this.element.closest("form");
    if (!form) {
      console.error("No form element found for KCP payment.");
      return;
    }

    // KCP_Pay_Execute(form) 같은 레거시 호출을 래핑
    try {
      window.KCP_Pay_Execute(form);
    } catch (e) {
      console.error("KCP_Pay_Execute failed:", e);
    }
  }
}
