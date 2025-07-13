export interface PaymentProvider {
  initialize(): Promise<void>;
  createPayment(paymentData: PaymentData): Promise<PaymentResult>;
  verifyPayment(paymentId: string): Promise<PaymentVerification>;
  refundPayment(paymentId: string, amount: number): Promise<RefundResult>;
  createSubscription(data: SubscriptionData): Promise<SubscriptionResult>;
  updateSubscription(update: SubscriptionUpdate): Promise<SubscriptionResult>;
  cancelSubscription(subscriptionId: string): Promise<void>;
  getSubscription(subscriptionId: string): Promise<SubscriptionResult>;
  listSubscriptions(userId: string): Promise<SubscriptionResult[]>;
}

export interface PaymentData {
  amount: number;
  currency: string;
  orderId: string;
  userId: string;
  restaurantId: string;
  paymentMethod: 'apple_pay' | 'google_pay';
  paymentToken: string;
  metadata?: Record<string, any>;
}

export interface PaymentResult {
  paymentId: string;
  status: 'success' | 'failed' | 'pending';
  transactionId: string;
  amount: number;
  currency: string;
  timestamp: Date;
  metadata?: Record<string, any>;
}

export interface PaymentVerification {
  isValid: boolean;
  status: 'verified' | 'failed' | 'pending';
  paymentId: string;
  timestamp: Date;
}

export interface RefundResult {
  refundId: string;
  status: 'success' | 'failed' | 'pending';
  amount: number;
  currency: string;
  timestamp: Date;
}

export interface SubscriptionData {
  planId: string;
  userId: string;
  restaurantId: string;
  paymentMethod: 'apple_pay' | 'google_pay';
  paymentToken: string;
  startDate: Date;
  interval: 'monthly' | 'yearly';
  metadata?: Record<string, any>;
}

export interface SubscriptionResult {
  subscriptionId: string;
  status: 'active' | 'cancelled' | 'failed';
  planId: string;
  startDate: Date;
  nextBillingDate: Date;
  amount: number;
  currency: string;
  metadata?: Record<string, any>;
}

export interface SubscriptionUpdate {
  subscriptionId: string;
  status?: 'active' | 'cancelled' | 'paused';
  paymentToken?: string;
  metadata?: Record<string, any>;
} 