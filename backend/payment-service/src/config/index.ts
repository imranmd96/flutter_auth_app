export const config = {
  // ... existing config ...
  
  applePay: {
    merchantId: process.env.APPLE_PAY_MERCHANT_ID,
    merchantCertificate: process.env.APPLE_PAY_MERCHANT_CERTIFICATE,
    merchantPrivateKey: process.env.APPLE_PAY_MERCHANT_PRIVATE_KEY,
    environment: process.env.APPLE_PAY_ENVIRONMENT || 'TEST'
  },
  
  googlePay: {
    merchantId: process.env.GOOGLE_PAY_MERCHANT_ID,
    apiKey: process.env.GOOGLE_PAY_API_KEY,
    environment: process.env.GOOGLE_PAY_ENVIRONMENT || 'TEST'
  }
}; 