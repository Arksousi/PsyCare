const User = require('../models/User');
const TherapistProfile = require('../models/TherapistProfile');

// @desc    Get all therapists
// @route   GET /api/therapists
// @access  Public
const getTherapists = async (req, res) => {
  try {
    const therapists = await User.find({ role: 'therapist' }).select('-password');
    
    // Get profiles and stitch them together
    const profiles = await TherapistProfile.find({});
    
    const therapistData = therapists.map(t => {
      const profile = profiles.find(p => p.userId.toString() === t._id.toString());
      return {
        _id: t._id,
        fullName: t.fullName,
        email: t.email,
        ratingAvg: profile ? profile.ratingAvg : 0,
        locationText: profile ? profile.locationText : '',
      };
    });

    res.status(200).json(therapistData);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getTherapists,
};
