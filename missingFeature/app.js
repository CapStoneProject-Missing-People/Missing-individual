import express from "express";
import dotenv from "dotenv";
import { Server } from 'socket.io';
import mongoose from 'mongoose';
import cors from 'cors';
import http from 'http';
import multer from 'multer';
import chatRoutes from './routes/chat.js';
import { requireAuth, isAdmin } from './middleware/authMiddleware.js';
import Message from './models/Message.js';
import { userRouter } from "./routes/userRoutes.js";
import { featureRouter } from "./routes/featureRouter.js";
import { profileRouter } from "./routes/profileRouter.js";
import { connectionDb } from "./config/dbConnection.js";
import { routers } from "./routes/routes.js";
import { feedBackRouter } from "./routes/feedBackRouter.js";
import { adminRouters } from "./routes/adminRouter.js";
import Notification from "./models/NotificationModel.js";

dotenv.config();  // Load environment variables from .env file

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
  },
});
connectionDb().then(() => {
  console.log("Data base connection established");

  // periodically delete old notifications
  setInterval(async () => {
    console.log("checking for old notifications to delete");
    await Notification.deleteOldNotifications();
}, 3600*1000);
}).catch((err) => {
  console.log("Error connecting to database", err);
});


const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_STRING;

const upload = multer({ dest: 'uploads/' });  // Configure multer to save files to the 'uploads' folder
app.use(express.json());

app.use(cors());
app.use("/api/features", featureRouter);
app.use("/api/users", userRouter);
app.use("/api/profile", profileRouter);
app.use("/api/admin", adminRouters);
app.use("/api", routers);
app.use("/api", feedBackRouter);
app.use("/api/chat", chatRoutes); // Ensure routes are correct
app.use('/uploads', express.static('uploads'));  // Serve uploaded files as static files

// File upload endpoint
app.post('/api/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded');
  }
  res.status(200).json({ imageUrl: `/uploads/${req.file.filename}` });
});

// Mark message as read endpoint
app.post('/api/readMessage', requireAuth, async (req, res) => {
  const { messageId } = req.body;

  try {
    await Message.findByIdAndUpdate(messageId, { read: true });
    res.status(200).send({ success: true });
  } catch (error) {
    res.status(500).send({ success: false, error });
  }
});

// WebSocket connection
io.on('connection', (socket) => {
  console.log('New client connected');

  socket.on('sendMessage', async (data) => {
    const { sender, receiver, message, imageUrl, time } = data;

    if (!sender || !receiver || (!message && !imageUrl)) {
      console.error('Missing required fields');
      return;
    }

    const newMessage = new Message({
      sender,
      receiver,
      message: message || '',
      imageUrl,
      time: time || new Date().toISOString(),
      read: false,
    });

    try {
      await newMessage.save();
      const messageToEmit = {
        _id: newMessage._id,
        sender: newMessage.sender,
        receiver: newMessage.receiver,
        message: newMessage.message,
        imageUrl: newMessage.imageUrl,
        time: newMessage.time,
        read: newMessage.read,
      };
      io.emit('receiveMessage', messageToEmit);
    } catch (error) {
      console.error('Error saving message:', error);
    }
  });

  socket.on('markAsRead', async (data) => {
    const { messageId } = data;
    try {
      await Message.findByIdAndUpdate(messageId, { read: true });
      io.emit('messageRead', { messageId });
    } catch (error) {
      console.error('Error marking message as read:', error);
    }
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// Handle 404 - Resource Not Found
app.use((req, res, next) => {
  res.status(404).json({ msg: "Route not found" });
});

// Server listening
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
