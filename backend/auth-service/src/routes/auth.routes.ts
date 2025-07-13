import { Router } from 'express';

import { register, login, refreshToken, logout, updatePassword, deleteAccount, updateProfile } from '../controllers/auth.controller';
import { validateRegister, validateLogin } from '../middleware/validation.middleware';
import { protect } from '../middleware/auth.middleware';

const router = Router();

// Health check
router.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Auth service is running'
  });
});

// Authentication routes
router.post('/register', validateRegister, register);
router.post('/login', validateLogin, login);
router.post('/refresh-token', refreshToken);
router.post('/logout', logout);
router.post('/update-password', protect, updatePassword);
router.delete('/account', protect, deleteAccount);
router.patch('/profile', protect, updateProfile);

export default router; 