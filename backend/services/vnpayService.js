const crypto = require('crypto');
const querystring = require('querystring');
const moment = require('moment');

/**
 * VNPay Payment Gateway Service
 * 
 * Handles VNPay Sandbox integration for payment processing
 * API Documentation: https://sandbox.vnpayment.vn/apis/docs/
 * 
 * Test Credentials (Sandbox):
 * - Card Number: 9704198526191432198
 * - Card Holder: NGUYEN VAN A
 * - Expiry Date: 07/15
 * - OTP: 123456
 */
class VNPayService {
  constructor() {
    // VNPay Sandbox URL
    this.vnpUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
    this.vnpApiUrl = 'https://sandbox.vnpayment.vn/merchant_webapi/api/transaction';
    
    // Credentials from .env
    this.tmnCode = process.env.VNP_TMN_CODE;
    this.hashSecret = process.env.VNP_HASH_SECRET;
    this.returnUrl = process.env.VNP_RETURN_URL;
    
    // Validate configuration
    if (!this.tmnCode || !this.hashSecret || !this.returnUrl) {
      console.warn('⚠️  VNPay configuration missing in .env file');
    }
  }

  /**
   * Sort object keys alphabetically (required by VNPay)
   * @param {Object} obj - Object to sort
   * @returns {Object} Sorted object
   */
  sortObject(obj) {
    const sorted = {};
    const keys = Object.keys(obj).sort();
    
    keys.forEach(key => {
      sorted[key] = obj[key];
    });
    
    return sorted;
  }

  /**
   * Create VNPay payment URL
   * 
   * @param {string} orderId - Order ID (unique transaction reference)
   * @param {number} amount - Payment amount in VND
   * @param {string} orderInfo - Order description
   * @param {string} ipAddr - Customer IP address
   * @param {string} bankCode - Bank code (optional, empty for all banks)
   * @returns {string} VNPay payment URL
   */
  createPaymentUrl(orderId, amount, orderInfo, ipAddr, bankCode = '') {
    const date = new Date();
    const createDate = moment(date).format('YYYYMMDDHHmmss');
    const expireDate = moment(date).add(15, 'minutes').format('YYYYMMDDHHmmss');
    
    let vnp_Params = {
      vnp_Version: '2.1.0',
      vnp_Command: 'pay',
      vnp_TmnCode: this.tmnCode,
      vnp_Locale: 'vn',
      vnp_CurrCode: 'VND',
      vnp_TxnRef: orderId.toString(),
      vnp_OrderInfo: orderInfo,
      vnp_OrderType: 'other',
      vnp_Amount: amount * 100, // VNPay requires amount in smallest unit (VND * 100)
      vnp_ReturnUrl: this.returnUrl,
      vnp_IpAddr: ipAddr,
      vnp_CreateDate: createDate,
      vnp_ExpireDate: expireDate,
    };

    // Add bank code if specified
    if (bankCode) {
      vnp_Params.vnp_BankCode = bankCode;
    }

    // Sort parameters
    vnp_Params = this.sortObject(vnp_Params);
    
    // Create signature
    const signData = querystring.stringify(vnp_Params, { encode: false });
    const hmac = crypto.createHmac('sha512', this.hashSecret);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
    
    vnp_Params.vnp_SecureHash = signed;

    // Build final URL
    const paymentUrl = this.vnpUrl + '?' + querystring.stringify(vnp_Params, { encode: false });
    
    return paymentUrl;
  }

  /**
   * Verify VNPay return URL signature
   * 
   * @param {Object} vnp_Params - Query parameters from VNPay return URL
   * @returns {boolean} True if signature is valid
   */
  verifyReturnUrl(vnp_Params) {
    const secureHash = vnp_Params.vnp_SecureHash;
    
    // Remove hash fields before verifying
    const paramsToVerify = { ...vnp_Params };
    delete paramsToVerify.vnp_SecureHash;
    delete paramsToVerify.vnp_SecureHashType;
    
    // Sort parameters
    const sortedParams = this.sortObject(paramsToVerify);
    
    // Create signature
    const signData = querystring.stringify(sortedParams, { encode: false });
    const hmac = crypto.createHmac('sha512', this.hashSecret);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');

    return secureHash === signed;
  }

  /**
   * Parse VNPay return parameters
   * 
   * @param {Object} vnp_Params - Query parameters from VNPay
   * @returns {Object} Parsed payment result
   */
  parseReturnParams(vnp_Params) {
    return {
      orderId: vnp_Params.vnp_TxnRef,
      amount: parseInt(vnp_Params.vnp_Amount) / 100, // Convert back to VND
      orderInfo: vnp_Params.vnp_OrderInfo,
      responseCode: vnp_Params.vnp_ResponseCode,
      transactionNo: vnp_Params.vnp_TransactionNo,
      bankCode: vnp_Params.vnp_BankCode,
      bankTranNo: vnp_Params.vnp_BankTranNo,
      cardType: vnp_Params.vnp_CardType,
      payDate: vnp_Params.vnp_PayDate,
      transactionStatus: vnp_Params.vnp_TransactionStatus,
    };
  }

  /**
   * Get payment status message from response code
   * 
   * @param {string} responseCode - VNPay response code
   * @returns {string} Status message in Vietnamese
   */
  getResponseMessage(responseCode) {
    const messages = {
      '00': 'Giao dịch thành công',
      '07': 'Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, giao dịch bất thường)',
      '09': 'Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng',
      '10': 'Giao dịch không thành công do: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần',
      '11': 'Giao dịch không thành công do: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch',
      '12': 'Giao dịch không thành công do: Thẻ/Tài khoản của khách hàng bị khóa',
      '13': 'Giao dịch không thành công do: Quý khách nhập sai mật khẩu xác thực giao dịch (OTP)',
      '24': 'Giao dịch không thành công do: Khách hàng hủy giao dịch',
      '51': 'Giao dịch không thành công do: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch',
      '65': 'Giao dịch không thành công do: Tài khoản của Quý khách đã vượt quá giới hạn giao dịch trong ngày',
      '75': 'Ngân hàng thanh toán đang bảo trì',
      '79': 'Giao dịch không thành công do: KH nhập sai mật khẩu thanh toán quá số lần quy định',
      '99': 'Các lỗi khác (lỗi còn lại, không có trong danh sách mã lỗi đã liệt kê)',
    };

    return messages[responseCode] || 'Lỗi không xác định';
  }

  /**
   * Check if payment was successful
   * 
   * @param {string} responseCode - VNPay response code
   * @returns {boolean} True if payment successful
   */
  isPaymentSuccess(responseCode) {
    return responseCode === '00';
  }

  /**
   * Create query transaction URL for VNPay API
   * 
   * @param {string} orderId - Order ID
   * @param {string} transDate - Transaction date (YYYYMMDDHHmmss)
   * @param {string} ipAddr - IP address
   * @returns {Object} Query request data
   */
  createQueryRequest(orderId, transDate, ipAddr) {
    const requestData = {
      vnp_RequestId: moment().format('YYYYMMDDHHmmss') + Math.floor(Math.random() * 1000000),
      vnp_Version: '2.1.0',
      vnp_Command: 'querydr',
      vnp_TmnCode: this.tmnCode,
      vnp_TxnRef: orderId.toString(),
      vnp_OrderInfo: `Query transaction ${orderId}`,
      vnp_TransactionDate: transDate,
      vnp_CreateDate: moment().format('YYYYMMDDHHmmss'),
      vnp_IpAddr: ipAddr,
    };

    // Sort and create signature
    const sortedData = this.sortObject(requestData);
    const signData = querystring.stringify(sortedData, { encode: false });
    const hmac = crypto.createHmac('sha512', this.hashSecret);
    const secureHash = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
    
    requestData.vnp_SecureHash = secureHash;

    return requestData;
  }

  /**
   * Get list of supported banks
   * 
   * @returns {Array} List of bank objects with code and name
   */
  getSupportedBanks() {
    return [
      { code: '', name: 'Cổng thanh toán VNPAYQR', logo: 'vnpayqr' },
      { code: 'VNPAYQR', name: 'Ứng dụng hỗ trợ VNPAYQR', logo: 'vnpayqr' },
      { code: 'VNBANK', name: 'Thẻ ATM/Tài khoản nội địa', logo: 'vnbank' },
      { code: 'INTCARD', name: 'Thẻ thanh toán quốc tế', logo: 'intcard' },
      { code: 'VIETCOMBANK', name: 'Vietcombank', logo: 'vcb' },
      { code: 'VIETINBANK', name: 'Vietinbank', logo: 'vtb' },
      { code: 'BIDV', name: 'BIDV', logo: 'bidv' },
      { code: 'AGRIBANK', name: 'Agribank', logo: 'agribank' },
      { code: 'SACOMBANK', name: 'Sacombank', logo: 'sacombank' },
      { code: 'TECHCOMBANK', name: 'Techcombank', logo: 'techcombank' },
      { code: 'ACB', name: 'ACB', logo: 'acb' },
      { code: 'VPBANK', name: 'VPBank', logo: 'vpbank' },
      { code: 'TPBANK', name: 'TPBank', logo: 'tpbank' },
      { code: 'MBBANK', name: 'MBBank', logo: 'mbbank' },
      { code: 'SCB', name: 'SCB', logo: 'scb' },
    ];
  }
}

module.exports = new VNPayService();
