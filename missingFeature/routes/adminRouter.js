
import express from "express";
import {
  getAllUsers,
  getAllAdmins,
  deleteUserProfile,
  deleteUserPost,
  updateUserRole,
  updatePermissions,
  updateUserProfile,
  deleteAdmin,
  getLoggedInUserData,
} from "../controller/adminController.js";
import {
  requireAuth,
  isAdmin,
  requirePermission,
} from "../middleware/authMiddleware.js";

export const adminRouters = express.Router();
adminRouters.get(
  "/getLogInData",
  requireAuth,
  isAdmin([3244,5150]),
  getLoggedInUserData
);
adminRouters.get(
  "/getAllUsers",
  requireAuth,
  isAdmin([3244, 5150]),
  requirePermission("read"),
  getAllUsers
);
adminRouters.get(
  "/getAllAdmins",
  requireAuth,
  isAdmin([5150]),
  getAllAdmins
);

adminRouters.put(
  "/updateUserProfile/:userId",
  requireAuth,
  isAdmin([3244, 5150]),
  requirePermission("update"),
  updateUserProfile
);
  
adminRouters.delete(
  "/deleteUser/:userId",
  requireAuth,
  isAdmin([3244, 5150]),
  requirePermission("delete"),
  deleteUserProfile
);
adminRouters.delete(
  "/deletePost/:postId",
  requireAuth,
  isAdmin([3244, 5150]),
  requirePermission("delete"),
  deleteUserPost
);
adminRouters.delete(
  "/deleteAdmin/:userId",
  requireAuth,
  isAdmin([5150]),
  deleteAdmin
);

adminRouters.patch(
  "/updateRole/:userId",
  requireAuth,
  isAdmin([5150]),
  updateUserRole
);

adminRouters.patch(
  "/updatePermissions/:userId",
  requireAuth,
  isAdmin([5150]),
  updatePermissions
);

export default adminRouters;
