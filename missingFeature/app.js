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
import {routers} from "./routes/featureRouter.js"
import { profileRouter } from "./routes/profileRouter.js";
import { connectionDb } from "./config/dbConnection.js"
import { routes } from "./routes/routes.js";
import { adminRouters } from "./routes/adminRouter.js";
import cors from "cors";
// import cookieParser from "cookie-parser"
// import { requireAuth, checkUser } from "./middleware/authMiddleware"
dotenv.config()

dotenv.config();  // Load environment variables from .env file

const port = process.env.PORT || 3000;
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
  },
});
connectionDb();

const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_STRING;

const upload = multer({ dest: 'uploads/' });  // Configure multer to save files to the 'uploads' folder
app.use(express.json());

app.use(cors());
app.use("/api/features", featureRouter);
app.use("/api/users", userRouter);
app.use("/api/profile", profileRouter);
app.use("/api/admin", adminRouters);
app.use("/api", routes);

app.listen(port, () => {
  console.log(`server listening on port ${port}`);
});

// Handle 404 - Resource Not Found
app.use((req, res, next) => {
  res.status(404).json({ msg: "Route not found" });
});

// Server listening
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
