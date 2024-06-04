import {
  getUserProfile,
  updateUserProfile,
  deleteUserProfile,
} from "../controller/userProfileController.js";
import { requireAuth } from "../middleware/authMiddleware.js";
import express from "express";
import multer from "multer";

const upload = multer();
export const profileRouter = express.Router();

profileRouter.route("/current").get(requireAuth, getUserProfile);
profileRouter.route("/update").put(requireAuth, updateUserProfile);
profileRouter.route("/delete").delete(requireAuth, deleteUserProfile);
