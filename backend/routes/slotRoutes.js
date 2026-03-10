const express = require('express');
const router = express.Router();
const { getSlots, getMySlots, createSlot, deleteSlot } = require('../controllers/slotController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, getSlots)
  .post(protect, restrictTo('therapist'), createSlot);

router.get('/me', protect, restrictTo('therapist'), getMySlots);

router.route('/:id')
  .delete(protect, restrictTo('therapist'), deleteSlot);

module.exports = router;
