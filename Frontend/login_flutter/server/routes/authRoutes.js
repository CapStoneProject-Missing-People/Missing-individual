import * as authController from "../controller/authController.js";
import express from "express";
import { auth } from "../middleware/auth.js";
export const userRouter = express.Router();

userRouter.route("/signup").post(authController.signup_post);
userRouter.route("/login").post(authController.login_post);
userRouter.route("/tokenIsValid").post(authController.token_valid);
userRouter.route("/getUser").post(auth, authController.getUserData);
