const express = require('express');
const router = express.Router();
const { bookSlot, acceptBooking, rejectBooking, getMyBookings } = require('../controllers/bookingController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

router.post('/book', protect, restrictTo('patient'), bookSlot);
router.post('/:id/accept', protect, restrictTo('therapist'), acceptBooking);
router.post('/:id/reject', protect, restrictTo('therapist'), rejectBooking);
router.get('/me', protect, getMyBookings);

module.exports = router;
