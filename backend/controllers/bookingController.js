const Booking = require('../models/Booking');
const TherapistSlot = require('../models/TherapistSlot');
const Notification = require('../models/Notification');

// @desc    Book a slot
// @route   POST /api/bookings/book
// @access  Private (Patient only)
const bookSlot = async (req, res) => {
  try {
    const { slotId } = req.body;
    const patientId = req.user.id;

    if (req.user.role !== 'patient') {
      return res.status(403).json({ message: 'Only patients can book slots.' });
    }

    // Attempt to atomically reserve the slot
    const slot = await TherapistSlot.findOneAndUpdate(
      { _id: slotId, status: 'available' },
      {
        status: 'reserved',
        patientId,
        reservedUntil: new Date(Date.now() + 15 * 60000), // 15 minutes from now
      },
      { new: true }
    );

    if (!slot) {
      return res.status(400).json({ message: 'This slot is not available anymore.' });
    }

    // Create the booking
    const booking = await Booking.create({
      therapistId: slot.therapistId,
      patientId,
      slotId: slot._id,
      startAt: slot.startAt,
      endAt: slot.endAt,
      status: 'pending',
    });

    // Link booking to slot
    slot.bookingId = booking._id;
    await slot.save();

    // Create notification for therapist
    await Notification.create({
      userId: slot.therapistId,
      type: 'booking_request',
      title: 'New booking request',
      body: 'A patient requested a session.',
      bookingId: booking._id,
    });

    res.status(201).json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Accept a booking
// @route   POST /api/bookings/:id/accept
// @access  Private (Therapist only)
const acceptBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const therapistId = req.user.id;

    const booking = await Booking.findOne({ _id: bookingId, therapistId, status: 'pending' });

    if (!booking) {
      return res.status(404).json({ message: 'Pending booking not found or unauthorized.' });
    }

    // Check slot status and reservedUntil
    const slot = await TherapistSlot.findOne({ _id: booking.slotId, bookingId: booking._id });
    
    if (!slot) return res.status(404).json({ message: 'Slot not found for this booking.' });
    if (slot.status !== 'reserved') return res.status(400).json({ message: 'Slot is not reserved.' });
    if (slot.reservedUntil && new Date() > slot.reservedUntil) {
       return res.status(400).json({ message: 'Reservation expired. Cannot accept.' });
    }

    // Update booking status
    booking.status = 'accepted';
    await booking.save();

    // Update slot status
    slot.status = 'booked';
    await slot.save();

    // Notify patient
    await Notification.create({
      userId: booking.patientId,
      type: 'booking_accepted',
      title: 'Booking accepted',
      body: 'Your therapist accepted your session.',
      bookingId: booking._id,
    });

    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Reject a booking
// @route   POST /api/bookings/:id/reject
// @access  Private (Therapist only)
const rejectBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const therapistId = req.user.id;

    const booking = await Booking.findOne({ _id: bookingId, therapistId, status: 'pending' });
    if (!booking) return res.status(404).json({ message: 'Pending booking not found or unauthorized.' });

    booking.status = 'rejected';
    await booking.save();

    // Free the slot
    const slot = await TherapistSlot.findById(booking.slotId);
    if (slot) {
      slot.status = 'available';
      slot.patientId = null;
      slot.bookingId = null;
      slot.reservedUntil = null;
      await slot.save();
    }

    // Notify patient
    await Notification.create({
      userId: booking.patientId,
      type: 'booking_rejected',
      title: 'Booking rejected',
      body: 'Your therapist rejected the session.',
      bookingId: booking._id,
    });

    res.status(200).json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user's bookings (patient or therapist)
// @route   GET /api/bookings/me
// @access  Private
const getMyBookings = async (req, res) => {
  try {
    const filter = req.user.role === 'therapist' 
      ? { therapistId: req.user.id } 
      : { patientId: req.user.id };

    const bookings = await Booking.find(filter)
      .populate('therapistId', 'fullName email')
      .populate('patientId', 'fullName email')
      .populate('slotId')
      .sort({ startAt: -1 });

    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  bookSlot,
  acceptBooking,
  rejectBooking,
  getMyBookings,
};
