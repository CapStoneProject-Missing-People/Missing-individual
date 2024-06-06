import * as authController from "../controller/authController.js";
import { requireAuth, isAdmin } from "../middleware/authMiddleware.js";
import express from "express";
export const userRouter = express.Router();

userRouter.route("/signup").post(authController.signup_post);
userRouter.route("/login").post(authController.login_post);
userRouter.route("/tokenIsValid").post(authController.token_valid);
userRouter.route("/getUser").post(requireAuth, authController.getUserData);
userRouter.route("/logout").get(requireAuth, authController.logout_get);
userRouter.route("/adminLogin").post(authController.admin_login_post);

