const mongoose = require('mongoose');

const therapistProfileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  ratingAvg: {
    type: Number,
    default: 0.0,
  },
  ratingCount: {
    type: Number,
    default: 0,
  },
  locationText: {
    type: String,
    default: '',
  },
  locationUrl: {
    type: String,
    default: '',
  },
  bio: {
    type: String,
    default: '',
  },
  specialties: {
    type: [String],
    default: [],
  },
  therapiesCount: {
    type: Number,
    default: 0,
  },
}, { timestamps: true });

const TherapistProfile = mongoose.model('TherapistProfile', therapistProfileSchema);
module.exports = TherapistProfile;
