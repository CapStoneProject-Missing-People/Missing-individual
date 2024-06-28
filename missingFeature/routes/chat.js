import express from 'express';
import Message from '../models/Message.js';
import { requireAuth } from '../middleware/authMiddleware.js';

const router = express.Router();

// Get messages between two users
router.get('/:receiver', requireAuth, async (req, res) => {
  const { receiver } = req.params;
  console.log('receiver: ', receiver);
  console.log('current user: ', req.user.userId);
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
  console.log(req.body);
  try {
    const newMessage = new Message({
      sender: req.user.userId,
      receiver,
      message,
      imageUrl: imageUrl || '', // Use provided imageUrl or default to an empty string
      time: new Date(),
      read: false,
    });

    await newMessage.save();
    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get chat sessions for a user
router.get('/getChatSessions/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const userChats = await Message.find({
      $or: [{ sender: userId }, { receiver: userId }],
    });

    console.log(userChats);

    if (userChats.length > 0) {
     res.status(200).json(userChats);
    } else {
      res.status(404).json({ msg: 'No chats', status: 404 });
    }
  } catch (error) {
    console.error('Error fetching chat sessions:', error);
    res.status(500).json({ msg: 'Internal server error' });
  }
});

// Delete a message
router.delete('/delete/:id', requireAuth, async (req, res) => {
  const { id } = req.params;
  console.log(id);
  try {
    const message = await Message.findById(id);
    if (!message) {
      console.log('Failed to find message');
      return res.status(404).json({ message: 'Message not found' });
    }
    console.log(message.sender.toString());
    console.log(req.user.userId.toString());

    // Check if the user is the sender of the message
    if (message.sender.toString() !== req.user.userId.toString()) {
      console.log('You are not authorized to delete this message');
      return res.status(403).json({ message: 'You are not authorized to delete this message' });
    }
    console.log('Before removal');
    await message.deleteOne();
    res.status(200).json({ message: 'Message deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


export default router;
