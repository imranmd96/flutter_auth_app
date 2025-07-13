export interface TrialPeriod {
  duration: number; // in days
  startDate: Date;
  endDate: Date;
  isActive: boolean;
}

export interface Discount {
  type: 'percentage' | 'fixed';
  value: number;
  startDate: Date;
  endDate: Date;
  code?: string;
  isActive: boolean;
}

export interface SubscriptionPlan {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  interval: 'monthly' | 'yearly';
  features: string[];
  trialPeriod?: TrialPeriod;
  discounts?: Discount[];
  metadata?: Record<string, any>;
}

export interface SubscriptionFeatures {
  // Trial management
  startTrial(subscriptionId: string, duration: number): Promise<void>;
  endTrial(subscriptionId: string): Promise<void>;
  getTrialStatus(subscriptionId: string): Promise<TrialPeriod>;

  // Discount management
  applyDiscount(subscriptionId: string, discount: Discount): Promise<void>;
  removeDiscount(subscriptionId: string): Promise<void>;
  getActiveDiscounts(subscriptionId: string): Promise<Discount[]>;

  // Plan management
  changePlan(subscriptionId: string, newPlanId: string): Promise<void>;
  getAvailablePlans(): Promise<SubscriptionPlan[]>;
  getPlanDetails(planId: string): Promise<SubscriptionPlan>;

  // Usage tracking
  trackUsage(subscriptionId: string, feature: string, quantity: number): Promise<void>;
  getUsage(subscriptionId: string, feature: string): Promise<number>;
  getUsageLimit(subscriptionId: string, feature: string): Promise<number>;
} 