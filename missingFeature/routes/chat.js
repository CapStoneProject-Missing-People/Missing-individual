import express from 'express';
import mongoose from 'mongoose';
import Message from '../models/Message.js';
import { requireAuth, optionalAuth } from '../middleware/authMiddleware.js';
import { validateMessage } from '../validators/chatValidators.js';
// Add rate limiting to message sending
import rateLimit from 'express-rate-limit';

const messageLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 messages per windowMs
  message: 'Too many messages sent from this IP, please try again later'
});

const router = express.Router();

/**
 * @route GET /api/chat/:receiver
 * @desc Get messages between two users
 * @access Private
 */
router.get('/:receiver', requireAuth, async (req, res) => {
  console.log('Fetching messages...');
  try {
    const { receiver } = req.params;
    const { userId } = req.user;
    const { limit = 50, offset = 0 } = req.query;

    if (!receiver.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ message: 'Invalid receiver ID format' });
    }

    const messages = await Message.find({
      $or: [
        { sender: userId, receiver },
        { sender: receiver, receiver: userId },
      ],
    })
    .sort({ time: -1 }) // Newest first for pagination
    .skip(parseInt(offset))
    .limit(parseInt(limit))
    .lean();

    // Add total count for pagination
    const totalCount = await Message.countDocuments({
      $or: [
        { sender: userId, receiver },
        { sender: receiver, receiver: userId },
      ],
    });

    await Message.updateMany(
      { receiver: userId, sender: receiver, read: false },
      { $set: { read: true } }
    );

    res.json({
      success: true,
      data: messages.reverse(), // Reverse to maintain chronological order
      metadata: {
        count: messages.length,
        totalCount,
        unreadCount: messages.filter(m => !m.read && m.sender === receiver).length,
        hasMore: totalCount > (parseInt(offset) + parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error while fetching messages',
      error: error.message 
    });
  }
});

// Add this new route for image serving
router.get('/:id/image', async (req, res) => {
  console.log('Fetching image...');
  try {
    const message = await Message.findById(req.params.id);
    if (!message?.imageBase64) {
      return res.status(404).json({ success: false, message: 'Image not found' });
    }

    const imageBuffer = Buffer.from(message.imageBase64, 'base64');
    res.set('Content-Type', 'image/jpeg');
    res.send(imageBuffer);
  } catch (error) {
    res.status(500).json({ 
      success: false,
      message: 'Error retrieving image',
      error: error.message 
    });
  }
});

/**
 * @route POST /api/chat/
 * @desc Send a new message
 * @access Private
 */


// Modified POST /api/chat/ route
router.post('/', requireAuth, messageLimiter, validateMessage, async (req, res) => {
  console.log('Sending message...');
  try {
    const { receiver, message, imageBase64 } = req.body; // Changed from imageUrl
    const { userId } = req.user;

    // Validate image size (max 2MB)
    if (imageBase64 && imageBase64.length > 2.8 * 1024 * 1024) { // ~2MB in Base64
      return res.status(400).json({ 
        success: false,
        message: 'Image too large (max 2MB)' 
      });
    }

    const newMessage = new Message({
      sender: userId,
      receiver,
      message,
      imageBase64, // Store Base64 directly
      time: new Date(),
      read: false,
      status: 'sent'
    });

    const savedMessage = await newMessage.save();

    // Emit socket event
    if (req.io) {
      req.io.to(receiver).emit('newMessage', {
        ...savedMessage.toObject(),
        imageUrl: `/api/messages/${savedMessage._id}/image` // Include virtual URL
      });
    }

    res.status(201).json({
      success: true,
      data: {
        ...savedMessage.toObject(),
        imageUrl: `/api/messages/${savedMessage._id}/image` // Include virtual URL
      }
    });

  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send message',
      error: error.message
    });
  }
});

/**
 * @route GET /api/chat/sessions/:userId
 * @desc Get chat sessions for a user
 * @access Public (consider making it private)
 */
router.get('/sessions/:userId', requireAuth, async (req, res) => {
  console.log('Fetching chat sessions...');
  try {
    const { userId } = req.params;
    console.log(userId);
    
    // Add basic validation
    if (!userId.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ message: 'Invalid user ID format' });
    }

    const sessions = await Message.aggregate([
      {
        $match: {
          $or: [{ sender: new mongoose.Types.ObjectId(userId) }, 
                { receiver: new mongoose.Types.ObjectId(userId) }]
        }
      },
      {
        $project: {
          partner: {
            $cond: {
              if: { $eq: ["$sender", new mongoose.Types.ObjectId(userId)] },
              then: "$receiver",
              else: "$sender"
            }
          },
          message: 1,
          time: 1,
          read: 1,
          sender: 1,
          receiver: 1,
          status: 1
        }
      },
      {
        $group: {
          _id: "$partner",
          lastMessage: { $last: "$$ROOT" },
          unreadCount: {
            $sum: {
              $cond: [
                { 
                  $and: [
                    { $eq: ["$read", false] },
                    { $eq: ["$receiver", new mongoose.Types.ObjectId(userId)] },
                    { $ne: ["$sender", "$receiver"] } // Add this condition
                  ]
                },
                1, 
                0
              ]
            }
          }
        }
      },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'partnerDetails'
        }
      },
      {
        $unwind: {
          path: '$partnerDetails',
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $sort: { "lastMessage.time": -1 }
      }
    ]);

    console.log(sessions);

    res.json({
      success: true,
      data: sessions.map(session => ({
        partnerId: session._id,
        partnerName: session.partnerDetails?.name || 'Unknown',
        lastMessage: session.lastMessage.message,
        timestamp: session.lastMessage.time,
        isRead: session.lastMessage.read,
        unreadCount: session.unreadCount,
        imageBase64: session.lastMessage.imageBase64
      }))
    });
  } catch (error) {
    console.error('Error fetching chat sessions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch chat sessions',
      error: error.message
    });
  }
});



/**
 * @route DELETE /api/chat/:id
 * @desc Delete a message
 * @access Private (only message sender can delete)
 */
router.delete('/:id', requireAuth, async (req, res) => {
  console.log('Deleting message...');
  try {
    const { id } = req.params;
    const { userId } = req.user;

    const message = await Message.findById(id);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    if (message.sender.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized to delete this message'
      });
    }

    await message.deleteOne();

    // Emit socket event for message deletion
    if (req.io) {
      req.io.to(message.receiver).emit('messageDeleted', id);
    }

    res.json({
      success: true,
      message: 'Message deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting message:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete message',
      error: error.message
    });
  }
});

/**
 * @route PATCH /api/chat/:id/status
 * @desc Update message status (delivered/read)
 * @access Private
 */
router.patch('/:id/status', requireAuth, async (req, res) => {
  console.log('Updating message status...');
  try {
    const { id } = req.params;
    const { status } = req.body;
    const { userId } = req.user;

    if (!['delivered', 'read'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status value'
      });
    }

    const message = await Message.findOneAndUpdate(
      { _id: id, receiver: userId },
      { status },
      { new: true }
    );

    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Emit socket event for status update
    if (req.io) {
      req.io.to(message.sender).emit('messageStatus', {
        messageId: id,
        status
      });
    }

    res.json({
      success: true,
      data: message
    });

  } catch (error) {
    console.error('Error updating message status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update message status',
      error: error.message
    });
  }
});

export default router;
