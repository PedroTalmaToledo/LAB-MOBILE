const mongoose = require('mongoose');

const TrackingSchema = new mongoose.Schema({
  deliveryId: { type: String, required: true, index: true },
  driverId:   { type: String, required: true, index: true },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      required: true
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true
    }
  },
  timestamp: { type: Date, default: Date.now }
});

// Create 2dsphere index for geospatial queries
TrackingSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Tracking', TrackingSchema);
