import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const subscriptionSuccessRate = new Rate('subscription_success_rate');
const subscriptionProcessingTime = new Trend('subscription_processing_time');
const trialConversionRate = new Rate('trial_conversion_rate');

export const options = {
  scenarios: {
    subscription_creation: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 50 },
        { duration: '5m', target: 50 },
        { duration: '2m', target: 100 },
        { duration: '5m', target: 100 },
        { duration: '2m', target: 0 },
      ],
    },
    trial_conversion: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 30 },
        { duration: '5m', target: 30 },
        { duration: '2m', target: 0 },
      ],
    },
  },
  thresholds: {
    'subscription_success_rate': ['rate>0.95'],
    'subscription_processing_time': ['p(95)<2000'],
    'trial_conversion_rate': ['rate>0.80'],
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:3000';

export default function() {
  // Create subscription
  const subscriptionData = {
    planId: 'premium-monthly',
    userId: `user${__VU}`,
    restaurantId: `restaurant${__VU % 5}`,
    paymentMethod: 'apple_pay',
    paymentToken: 'test-token',
    startDate: new Date().toISOString(),
    interval: 'monthly',
    trialPeriod: {
      duration: 14,
      startDate: new Date().toISOString(),
      endDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString(),
      isActive: true
    }
  };

  const startTime = new Date();
  const response = http.post(`${BASE_URL}/api/subscriptions`, JSON.stringify(subscriptionData), {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer test-token'
    }
  });

  subscriptionProcessingTime.add(new Date() - startTime);
  subscriptionSuccessRate.add(response.status === 201);

  // Simulate trial conversion
  if (response.status === 201) {
    const subscriptionId = JSON.parse(response.body).subscriptionId;
    const conversionResponse = http.post(
      `${BASE_URL}/api/subscriptions/${subscriptionId}/convert`,
      null,
      {
        headers: {
          'Authorization': 'Bearer test-token'
        }
      }
    );
    trialConversionRate.add(conversionResponse.status === 200);
  }

  sleep(1);
} 