import request from 'supertest';
import app from '../../src/server';
import { redisClient } from '../../src/config/redis';

describe('Security Tests', () => {
  beforeEach(async () => {
    await redisClient.flushall();
  });

  describe('API Key Authentication', () => {
    it('should reject requests without API key', async () => {
      const response = await request(app)
        .post('/api/payments')
        .send({});
      
      expect(response.status).toBe(401);
      expect(response.body.message).toBe('API key is required');
    });

    it('should reject requests with invalid API key', async () => {
      const response = await request(app)
        .post('/api/payments')
        .set('x-api-key', 'invalid-key')
        .send({});
      
      expect(response.status).toBe(401);
      expect(response.body.message).toBe('Invalid API key');
    });

    it('should enforce API key rate limits', async () => {
      const apiKey = 'valid-api-key';
      await redisClient.set(`api_key:${apiKey}`, 'true');

      // Make multiple requests
      for (let i = 0; i < 1001; i++) {
        await request(app)
          .post('/api/payments')
          .set('x-api-key', apiKey)
          .send({});
      }

      const response = await request(app)
        .post('/api/payments')
        .set('x-api-key', apiKey)
        .send({});
      
      expect(response.status).toBe(429);
      expect(response.body.message).toBe('API key rate limit exceeded');
    });
  });

  describe('Input Validation', () => {
    it('should reject invalid payment amounts', async () => {
      const response = await request(app)
        .post('/api/payments')
        .send({ amount: -1 });
      
      expect(response.status).toBe(400);
      expect(response.body.message).toBe('Amount must be between 0.01 and 1,000,000');
    });
  });
}); 