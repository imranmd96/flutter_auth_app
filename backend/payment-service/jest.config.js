module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/__tests__/**/*',
    '!src/auth/**/*',
    '!src/middleware/jwt.middleware.ts',
    '!src/middleware/metrics.middleware.ts',
    '!src/middleware/auth.middleware.ts',
    '!src/middleware/rate-limit-endpoints.ts',
    '!src/middleware/role-rate-limit.ts',
    '!src/monitoring/**/*',
    '!src/providers/**/*',
    '!src/routes/payment.routes.ts',
    '!src/controllers/payment.controller.ts',
    '!src/config/metrics.ts'
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest'
  },
  testTimeout: 10000,
  verbose: true
}; 