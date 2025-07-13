import jwt from 'jsonwebtoken';
import { IAuthUser } from '../models/authUser.model';

export const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
export const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'your-refresh-secret-key';

const ACCESS_TOKEN_EXPIRES_IN = (process.env.JWT_EXPIRES_IN || '25m') as any;
const REFRESH_TOKEN_EXPIRES_IN = (process.env.JWT_REFRESH_EXPIRES_IN || '30m') as any;

export const generateTokens = (user: IAuthUser) => {
  const accessToken = jwt.sign(
    { id: user._id, role: user.role },
    JWT_SECRET as jwt.Secret,
    { expiresIn: ACCESS_TOKEN_EXPIRES_IN }
  );
  const refreshToken = jwt.sign(
    { id: user._id, role: user.role },
    JWT_REFRESH_SECRET as jwt.Secret,
    { expiresIn: REFRESH_TOKEN_EXPIRES_IN }
  );
  return { accessToken, refreshToken };
}; 