import express from "express";
import dotenv from "dotenv";
import { Server } from "socket.io";
import mongoose from "mongoose";
import cors from "cors";
import http from "http";
import multer from "multer";
import chatRoutes from "./routes/chat.js";
import { requireAuth, isAdmin } from "./middleware/authMiddleware.js";
import Message from "./models/Message.js";
import { userRouter } from "./routes/userRoutes.js";
import { featureRouter } from "./routes/featureRouter.js";
import { profileRouter } from "./routes/profileRouter.js";
import { connectionDb } from "./config/dbConnection.js";
import { routers } from "./routes/routes.js";
import { feedBackRouter } from "./routes/feedBackRouter.js";
import { adminRouters } from "./routes/adminRouter.js";
import Notification from "./models/NotificationModel.js";

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
  path: "/socket.io",
  // Enable connection state recovery
  connectionStateRecovery: {
    maxDisconnectionDuration: 2 * 60 * 1000, // 2 minutes
    skipMiddlewares: true,
  }
});

// Track connected users and their socket IDs
const activeUsers = new Map();

connectionDb()
  .then(() => {
    console.log("Database connection established");

    // Periodically delete old notifications
    setInterval(async () => {
      console.log("Checking for old notifications to delete");
      await Notification.deleteOldNotifications();
    }, 3600 * 1000);
  })
  .catch((err) => {
    console.log("Error connecting to database", err);
  });

const PORT = process.env.PORT || 4000;

const upload = multer({ 
  dest: "uploads/",
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  }
});

app.use(express.json());
app.use(cors());

// Routes
app.use("/api/features", featureRouter);
app.use("/api/users", userRouter);
app.use("/api/profile", profileRouter);
app.use("/api/admin", adminRouters);
app.use("/api", routers);
app.use("/api", feedBackRouter);
app.use("/api/chat", chatRoutes);
app.use("/uploads", express.static("uploads"));

// File upload endpoint
app.post("/api/upload", upload.single("image"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: "No file uploaded" });
  }
  res.status(200).json({ 
    success: true, 
    imageUrl: `/uploads/${req.file.filename}` 
  });
});

// Mark message as read endpoint
app.post("/api/readMessage", requireAuth, async (req, res) => {
  const { messageId } = req.body;

  try {
    const updatedMessage = await Message.findByIdAndUpdate(
      messageId, 
      { read: true },
      { new: true }
    );
    
    if (!updatedMessage) {
      return res.status(404).json({ 
        success: false, 
        message: "Message not found" 
      });
    }

    // Notify sender that their message was read
    io.to(activeUsers.get(updatedMessage.sender.toString()))?.emit("messageStatus", {
      messageId: updatedMessage._id,
      status: "read"
    });

    res.status(200).json({ 
      success: true,
      message: updatedMessage 
    });
  } catch (error) {
    console.error("Error marking message as read:", error);
    res.status(500).json({ 
      success: false, 
      message: "Server error",
      error: error.message 
    });
  }
});

// Socket.io Connection Handling
io.on("connection", (socket) => {
  console.log(`New connection: ${socket.id}`);

  // Register user with their socket
  socket.on("registerUser", (userId) => {
    if (!userId) {
      console.log("No userId provided for registration");
      return;
    }
    activeUsers.set(userId, socket.id);
    console.log(`User ${userId} connected with socket ${socket.id}`);
  });

  // Join a chat room
  socket.on("joinChat", (chatId) => {
    socket.join(chatId);
    console.log(`Socket ${socket.id} joined chat ${chatId}`);
  });

  // Leave a chat room
  socket.on("leaveChat", (chatId) => {
    socket.leave(chatId);
    console.log(`Socket ${socket.id} left chat ${chatId}`);
  });

  // Handle new messages
  socket.on("sendMessage", async (data) => {
    try {
      const { chatId, senderId, receiverId, content, imageUrl } = data;

      if (!chatId || !senderId || !receiverId || (!content && !imageUrl)) {
        console.error("Missing required fields for message");
        return;
      }

      const newMessage = new Message({
        sender: senderId,
        receiver: receiverId,
        message: content || "",
        imageUrl: imageUrl || null,
        time: new Date(),
        read: false,
        status: "sent"
      });

      const savedMessage = await newMessage.save();

      // Prepare the message data to emit
      const messageData = {
        id: savedMessage._id.toString(),
        senderId: savedMessage.sender,
        receiverId: savedMessage.receiver,
        content: savedMessage.message,
        imageUrl: savedMessage.imageUrl,
        timestamp: savedMessage.time,
        status: savedMessage.status,
        read: savedMessage.read
      };

      // Broadcast to the chat room
      io.to(chatId).emit("newMessage", {
        chatId,
        message: messageData
      });

      // If the receiver is connected but not in the chat room, notify them
      const receiverSocketId = activeUsers.get(receiverId);
      if (receiverSocketId && !socket.rooms.has(chatId)) {
        io.to(receiverSocketId).emit("newMessage", {
          chatId,
          message: messageData
        });
      }

    } catch (error) {
      console.error("Error handling message:", error);
    }
  });

  // Handle typing notifications
  socket.on("typing", (data) => {
    const { chatId, userId, isTyping } = data;
    socket.to(chatId).emit("typing", {
      chatId,
      userId,
      isTyping
    });
  });

  // Handle message status updates
  socket.on("updateStatus", async (data) => {
    try {
      const { messageId, status } = data;
      
      const updatedMessage = await Message.findByIdAndUpdate(
        messageId,
        { status },
        { new: true }
      );

      if (!updatedMessage) {
        console.error("Message not found for status update");
        return;
      }

      // Notify the sender about the status change
      const senderSocketId = activeUsers.get(updatedMessage.sender.toString());
      if (senderSocketId) {
        io.to(senderSocketId).emit("messageStatus", {
          messageId: updatedMessage._id,
          status: status
        });
      }
    } catch (error) {
      console.error("Error updating message status:", error);
    }
  });

  // Handle disconnections
  socket.on("disconnect", () => {
    console.log(`Client disconnected: ${socket.id}`);
    // Remove user from active users map
    for (const [userId, socketId] of activeUsers.entries()) {
      if (socketId === socket.id) {
        activeUsers.delete(userId);
        console.log(`User ${userId} disconnected`);
        break;
      }
    }
  });
});

// Handle 404 - Resource Not Found
app.use((req, res, next) => {
  res.status(404).json({ 
    success: false,
    message: "Route not found" 
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Server error:", err);
  res.status(500).json({
    success: false,
    message: "Internal server error",
    error: process.env.NODE_ENV === "development" ? err.message : undefined
  });
});

// Start server
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || "development"}`);
});