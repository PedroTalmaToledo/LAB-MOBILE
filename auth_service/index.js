require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const authRoutes = require('./routes/authRoutes');

const app = express();
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Mount authentication routes
app.use('/auth', authRoutes);

// MongoDB & Server
const PORT = process.env.PORT || 5001;
mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => app.listen(PORT, () => console.log(`Auth Service running on port ${PORT}`)))
  .catch(err => console.error('DB connection error:', err));
