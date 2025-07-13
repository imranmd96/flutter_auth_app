# Payment Providers Documentation

## Overview
This document describes the payment provider implementations for Apple Pay and Google Pay in the payment service.

## Supported Providers
- Apple Pay
- Google Pay

## Configuration

### Apple Pay
```typescript
const applePayConfig = {
  merchantId: process.env.APPLE_PAY_MERCHANT_ID,
  merchantCertificate: process.env.APPLE_PAY_MERCHANT_CERTIFICATE,
  merchantPrivateKey: process.env.APPLE_PAY_MERCHANT_PRIVATE_KEY,
  environment: process.env.APPLE_PAY_ENVIRONMENT || 'TEST'
};
```

### Google Pay
```typescript
const googlePayConfig = {
  merchantId: process.env.GOOGLE_PAY_MERCHANT_ID,
  apiKey: process.env.GOOGLE_PAY_API_KEY,
  environment: process.env.GOOGLE_PAY_ENVIRONMENT || 'TEST'
};
```

## Usage

### One-time Payments
```typescript
const paymentResult = await provider.createPayment({
  amount: 100.00,
  currency: 'USD',
  orderId: 'order123',
  userId: 'user123',
  restaurantId: 'restaurant123',
  paymentMethod: 'apple_pay',
  paymentToken: 'payment-token'
});
```

### Subscriptions
```typescript
const subscriptionResult = await provider.createSubscription({
  planId: 'premium-monthly',
  userId: 'user123',
  restaurantId: 'restaurant123',
  paymentMethod: 'apple_pay',
  paymentToken: 'payment-token',
  startDate: new Date(),
  interval: 'monthly'
});
```

## Error Handling
The payment providers throw specific errors for different scenarios:
- `InvalidPaymentTokenError`: When the payment token is invalid
- `PaymentProcessingError`: When payment processing fails
- `SubscriptionError`: When subscription operations fail

## Monitoring
The payment providers are monitored for:
- Health checks
- Success rates
- Error rates
- Active subscriptions
- Respons 