const express = require('express');
const router = express.Router();
const {
  updateLocation,
  getLatestLocation,
  getNearbyDeliveries
} = require('../controllers/trackingController');

router.post('/:deliveryId/locations', updateLocation);
router.get('/:deliveryId/locations/latest', getLatestLocation);
router.get('/nearby', getNearbyDeliveries);

module.exports = router;
