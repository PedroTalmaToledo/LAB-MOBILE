const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');

// POST /auth/register
exports.register = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { name, email, password, role } = req.body;
  try {
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ message: 'Email already registered' });

    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(password, salt);
    user = new User({ name, email, password: hash, role });
    await user.save();

    const payload = { userId: user._id, role: user.role };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });

    res.status(201).json({ token });
  } catch (err) {
    res.status(500).json({ error: 'Registration failed', details: err.message });
  }
};

// POST /auth/login
exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

    const payload = { userId: user._id, role: user.role };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });

    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: 'Login failed', details: err.message });
  }
};

// GET /auth/verify
exports.verifyToken = (req, res) => {
  res.json({ valid: true, user: req.user });
};
