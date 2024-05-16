import * as authController from "../controller/authController.js";
import { requireAuth, isAdmin } from "../middleware/authMiddleware.js";
import express from "express";
export const userRouter = express.Router();

userRouter.route("/signup").get(authController.signup_get);
userRouter.route("/signup").post(authController.signup_post);
userRouter.route("/login").get(authController.login_get);
userRouter.route("/login").post(authController.login_post);
userRouter.route("/logout").get(authController.logout_get);
