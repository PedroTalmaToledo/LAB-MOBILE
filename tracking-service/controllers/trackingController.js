const Tracking = require('../models/Tracking');

// POST /tracking/:deliveryId/locations
exports.updateLocation = async (req, res) => {
  const { deliveryId } = req.params;
  const { driverId, latitude, longitude, timestamp } = req.body;
  try {
    const entry = new Tracking({
      deliveryId,
      driverId,
      location: { type: 'Point', coordinates: [longitude, latitude] },
      timestamp: timestamp || Date.now()
    });
    await entry.save();
    res.status(201).json({ message: 'Location updated', entry });
  } catch (err) {
    res.status(500).json({ error: 'Update failed', details: err.message });
  }
};

// GET /tracking/:deliveryId/locations/latest
exports.getLatestLocation = async (req, res) => {
  const { deliveryId } = req.params;
  try {
    const latest = await Tracking.findOne({ deliveryId })
      .sort({ timestamp: -1 })
      .select('-__v');
    if (!latest) return res.status(404).json({ message: 'No location found' });
    res.json(latest);
  } catch (err) {
    res.status(500).json({ error: 'Query failed', details: err.message });
  }
};

// GET /tracking/nearby?lat=&lng=&radius=
exports.getNearbyDeliveries = async (req, res) => {
  const { lat, lng, radius = 1000 } = req.query; // radius in meters
  try {
    const nearby = await Tracking.aggregate([
      {
        $geoNear: {
          near: { type: 'Point', coordinates: [parseFloat(lng), parseFloat(lat)] },
          distanceField: 'distance',
          maxDistance: parseInt(radius, 10),
          spherical: true
        }
      },
      { $sort: { distance: 1 } }
    ]);
    res.json(nearby);
  } catch (err) {
    res.status(500).json({ error: 'Geo query failed', details: err.message });
  }
};
