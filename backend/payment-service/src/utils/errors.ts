export class BaseError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, new.target.prototype);
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends BaseError {
  constructor(message: string) {
    super(400, message);
    this.name = 'ValidationError';
  }
}

export class AuthenticationError extends BaseError {
  constructor(message: string = 'Authentication failed') {
    super(401, message);
    this.name = 'AuthenticationError';
  }
}

export class AuthorizationError extends BaseError {
  constructor(message: string = 'Not authorized') {
    super(403, message);
    this.name = 'AuthorizationError';
  }
}

export class NotFoundError extends BaseError {
  constructor(message: string = 'Resource not found') {
    super(404, message);
    this.name = 'NotFoundError';
  }
}

export class ConflictError extends BaseError {
  constructor(message: string = 'Resource conflict') {
    super(409, message);
    this.name = 'ConflictError';
  }
}

export class PaymentError extends BaseError {
  constructor(message: string = 'Payment processing failed') {
    super(422, message);
    this.name = 'PaymentError';
  }
}

export class DatabaseError extends BaseError {
  constructor(message: string = 'Database operation failed') {
    super(500, message);
    this.name = 'DatabaseError';
    this.isOperational = false;
  }
}

export class ExternalServiceError extends BaseError {
  constructor(message: string = 'External service error') {
    super(502, message);
    this.name = 'ExternalServiceError';
    this.isOperational = false;
  }
} 