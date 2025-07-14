"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("../controllers/auth.controller");
const validation_middleware_1 = require("../middleware/validation.middleware");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
router.get('/health', (_req, res) => {
    res.status(200).json({
        status: 'ok',
        message: 'Auth service is running'
    });
});
router.post('/register', validation_middleware_1.validateRegister, auth_controller_1.register);
router.post('/login', validation_middleware_1.validateLogin, auth_controller_1.login);
router.post('/refresh-token', auth_controller_1.refreshToken);
router.post('/logout', auth_controller_1.logout);
router.post('/update-password', auth_middleware_1.protect, auth_controller_1.updatePassword);
router.delete('/account', auth_middleware_1.protect, auth_controller_1.deleteAccount);
router.patch('/profile', auth_middleware_1.protect, auth_controller_1.updateProfile);
exports.default = router;
//# sourceMappingURL=auth.routes.js.map