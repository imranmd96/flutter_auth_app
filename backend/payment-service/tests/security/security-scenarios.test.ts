import request from 'supertest';
import app from '../../src/server';
import { redisClient } from '../../src/config/redis';
import jwt from 'jsonwebtoken';

describe('Security Scenarios', () => {
  beforeEach(async () => {
    await redisClient.flushall();
  });

  describe('JWT Authentication', () => {
    const validToken = jwt.sign(
      { 
        userId: 'user123',
        role: 'admin',
        permissions: ['read', 'write']
      },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );

    const expiredToken = jwt.sign(
      { 
        userId: 'user123',
        role: 'admin',
        permissions: ['read', 'write']
      },
      process.env.JWT_SECRET!,
      { expiresIn: '0s' }
    );

    it('should reject requests without JWT token', async () => {
      const response = await request(app)
        .get('/api/restaurants')
        .send();
      
      expect(response.status).toBe(401);
      expect(response.body.message).toBe('JWT token is required');
    });

    it('should reject requests with expired token', async () => {
      const response = await request(app)
        .get('/api/restaurants')
        .set('Authorization', `Bearer ${expiredToken}`)
        .send();
      
      expect(response.status).toBe(401);
      expect(response.body.message).toBe('Token has expired');
    });

    it('should reject requests with blacklisted token', async () => {
      await redisClient.set(`blacklist:${validToken}`, 'true');

      const response = await request(app)
        .get('/api/restaurants')
        .set('Authorization', `Bearer ${validToken}`)
        .send();
      
      expect(response.status).toBe(401);
      expect(response.body.message).toBe('Token has been revoked');
    });
  });

  describe('Role-Based Access Control', () => {
    const adminToken = jwt.sign(
      { 
        userId: 'admin123',
        role: 'admin',
        permissions: ['read', 'write', 'delete']
      },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );

    const userToken = jwt.sign(
      { 
        userId: 'user123',
        role: 'user',
        permissions: ['read']
      },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );

    it('should allow admin to delete restaurant', async () => {
      const response = await request(app)
        .delete('/api/restaurants/123')
        .set('Authorization', `Bearer ${adminToken}`)
        .send();
      
      expect(response.status).not.toBe(403);
    });

    it('should reject user from deleting restaurant', async () => {
      const response = await request(app)
        .delete('/api/restaurants/123')
        .set('Authorization', `Bearer ${userToken}`)
        .send();
      
      expect(response.status).toBe(403);
      expect(response.body.message).toBe('Insufficient permissions');
    });
  });

  describe('Input Validation', () => {
    const validToken = jwt.sign(
      { 
        userId: 'user123',
        role: 'admin',
        permissions: ['read', 'write']
      },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );

    it('should reject invalid restaurant data', async () => {
      const response = await request(app)
        .post('/api/restaurants')
        .set('Authorization', `Bearer ${validToken}`)
        .send({
          name: '',
          address: {
            street: '',
            city: '',
            country: ''
          },
          cuisine: [],
          openingHours: {}
        });
      
      expect(response.status).toBe(400);
      expect(response.body.message).toBe('Restaurant name must be between 2 and 100 characters');
    });
  });
}); 