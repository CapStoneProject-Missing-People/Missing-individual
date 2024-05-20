import express from "express";
import {
  deleteUserPost,
  deleteUserProfile,
  getAllUsers,
  updateUserRole,
} from "../controller/adminController.js";
import { requireAuth, isAdmin } from "../middleware/authMiddleware.js";

export const adminRouters = express.Router();

adminRouters
  .route("/getAll")
  .get(requireAuth, isAdmin(["admin", "superAdmin"]), getAllUsers);
adminRouters
  .route("/deleteUser/:userId")
  .delete(requireAuth, isAdmin("admin"), deleteUserProfile);
adminRouters
  .route("/deletePost/:postId")
  .delete(requireAuth, isAdmin("admin"), deleteUserPost);

adminRouters
  .route("/updateRole/:userId")
  .put(requireAuth, isAdmin("superAdmin"), updateUserRole);
