import express from 'express';
import Message from '../models/Message.js';
import { requireAuth } from '../middleware/authMiddleware.js';

const router = express.Router();

// Get messages between two users
router.get('/:receiver', requireAuth, async (req, res) => {
  const { receiver } = req.params;
  console.log('receiver: ', receiver)
  console.log('current user: ', req.user.userId)
  try {
    const messages = await Message.find({
      $or: [
        { sender: req.user.userId, receiver },
        { sender: receiver, receiver: req.user.userId },
      ],
    }).sort({ time: 1 }).lean(); // Use lean to avoid Mongoose document conversion
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Send a message
router.post('/', requireAuth, async (req, res) => {
  const { receiver, message, imageUrl } = req.body;
  console.log(req.body)
  try {
    console.log(req.user)
    console.log('before creatinn')
    const newMessage = new Message({
      sender: req.user.userId,
      receiver,
      message,
      imageUrl: false,
      time: new Date(),
      read: false,
    });
    console.log('before creatinn')

    await newMessage.save();
    console.log('before await')

    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
