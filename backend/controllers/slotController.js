const TherapistSlot = require('../models/TherapistSlot');

// @desc    Get all available slots (can filter by therapistId)
// @route   GET /api/slots
// @access  Private
const getSlots = async (req, res) => {
  try {
    const filter = { status: 'available' };
    if (req.query.therapistId) {
      filter.therapistId = req.query.therapistId;
    }

    const slots = await TherapistSlot.find(filter).sort({ startAt: 1 });
    res.status(200).json(slots);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get therapist's own slots
// @route   GET /api/slots/me
// @access  Private (Therapist only)
const getMySlots = async (req, res) => {
  try {
    const slots = await TherapistSlot.find({ therapistId: req.user.id })
      .populate('patientId', 'fullName email')
      .populate('bookingId')
      .sort({ startAt: 1 });
    
    res.status(200).json(slots);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a new slot
// @route   POST /api/slots
// @access  Private (Therapist only)
const createSlot = async (req, res) => {
  try {
    const { startAt, endAt } = req.body;

    if (!startAt || !endAt) {
      return res.status(400).json({ message: 'Please provide startAt and endAt' });
    }

    const slot = await TherapistSlot.create({
      therapistId: req.user.id,
      startAt,
      endAt,
      status: 'available',
    });

    res.status(201).json(slot);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete a slot
// @route   DELETE /api/slots/:id
// @access  Private (Therapist only)
const deleteSlot = async (req, res) => {
  try {
    const slot = await TherapistSlot.findById(req.params.id);

    if (!slot) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    // Check user
    if (slot.therapistId.toString() !== req.user.id) {
      return res.status(401).json({ message: 'User not authorized' });
    }

    // Only allow deletion of available or cancelled slots
    if (slot.status === 'reserved' || slot.status === 'booked') {
      return res.status(400).json({ message: 'Cannot delete a reserved or booked slot' });
    }

    await slot.deleteOne();
    res.status(200).json({ id: req.params.id });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getSlots,
  getMySlots,
  createSlot,
  deleteSlot,
};
