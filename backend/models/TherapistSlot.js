const mongoose = require('mongoose');

const therapistSlotSchema = new mongoose.Schema({
  therapistId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  startAt: {
    type: Date,
    required: true,
  },
  endAt: {
    type: Date,
    required: true,
  },
  status: {
    type: String,
    enum: ['available', 'reserved', 'booked', 'cancelled'],
    default: 'available',
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },
  bookingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    default: null,
  },
  reservedUntil: {
    type: Date,
    default: null,
  },
}, { timestamps: true });

const TherapistSlot = mongoose.model('TherapistSlot', therapistSlotSchema);
module.exports = TherapistSlot;
