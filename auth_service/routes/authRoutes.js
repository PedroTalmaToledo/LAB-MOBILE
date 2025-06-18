const express = require('express');
const router = express.Router();
const { register, login, verifyToken } = require('../controllers/authController');
const { body } = require('express-validator');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/register', [
  body('name').notEmpty(),
  body('email').isEmail(),
  body('password').isLength({ min: 6 }),
  body('role').isIn(['client','driver'])
], register);

router.post('/login', [
  body('email').isEmail(),
  body('password').exists()
], login);

router.get('/verify', authMiddleware, verifyToken);

module.exports = router;
