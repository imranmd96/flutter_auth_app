import request from 'supertest';
import app from '../../src/server';
import { redisClient } from '../../src/config/redis';
import jwt from 'jsonwebtoken';

describe('Security Edge Cases', () => {
  beforeEach(async () => {
    await redisClient.flushall();
  });

  describe('Token Edge Cases', () => {
    it('should handle malformed JWT tokens', async () => {
      const malformedTokens = [
        'invalid.token.format',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9', // Incomplete token
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ', // Missing signature
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIx
</rewritten_file> 