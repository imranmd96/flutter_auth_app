import { Router } from 'express';
import { protect } from '../middleware/auth.middleware.js';
import { getProfile, updateProfile, uploadAvatar, getAvatar, } from '../controllers/user.controller.js';
import { validateUpdateProfile } from '../middleware/validation.middleware.js';
import multer from 'multer';
const upload = multer({ storage: multer.memoryStorage() });
const router = Router();
router.use(protect);
router.get('/profile', getProfile);
router.patch('/profile', validateUpdateProfile, updateProfile);
router.post('/profile/avatar', upload.single('avatar'), uploadAvatar);
router.get('/profile/avatar', getAvatar);
export default router;
//# sourceMappingURL=user.routes.js.map