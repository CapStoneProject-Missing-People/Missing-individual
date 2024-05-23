import express from "express";
import {
  deleteUserPost,
  deleteUserProfile,
  getAllUsers,
  updateUserRole,
  getAllAdmins
} from "../controller/adminController.js";
import { requireAuth, isAdmin } from "../middleware/authMiddleware.js";

export const adminRouters = express.Router();

adminRouters
  .route("/getAll")
  .get(requireAuth, isAdmin(["admin", "superAdmin"]), getAllUsers);
adminRouters
  .route("/getAllAdmins")
  .get(requireAuth, isAdmin(["admin","superAdmin"]), getAllAdmins);
adminRouters
  .route("/deleteUser/:userId")
  .delete(requireAuth, isAdmin(["admin","superAdmin"]), deleteUserProfile);
adminRouters
  .route("/deletePost/:postId")
  .delete(requireAuth, isAdmin("admin"), deleteUserPost);

adminRouters
  .route("/updateRole/:userId")
  .put(requireAuth, isAdmin("superAdmin"), updateUserRole);
