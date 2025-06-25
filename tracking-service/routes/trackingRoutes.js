const express = require('express');
const router = express.Router();

const {
  updateLocation,
  getLatestLocation,
  getNearbyDeliveries
} = require('../controllers/trackingController');

// POST /:deliveryId/locations
router.post('/:deliveryId/locations', updateLocation);

// GET /:deliveryId/locations/latest
router.get('/:deliveryId/locations/latest', getLatestLocation);

// GET /nearby
router.get('/nearby', getNearbyDeliveries);

module.exports = router;
