require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const morgan = require('morgan');
const trackingRoutes = require('./routes/trackingRoutes');

const app = express();
app.use(morgan('dev'));
app.use(express.json());

// Mount tracking routes
app.use('/tracking', trackingRoutes);

// Connect to MongoDB and start server
const PORT = process.env.PORT || 5002;
mongoose
  .connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => app.listen(PORT, () => console.log(`Tracking Service running on port ${PORT}`)))
  .catch((err) => console.error('MongoDB connection error:', err));
