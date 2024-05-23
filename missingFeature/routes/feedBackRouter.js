import express from "express";
import { createFeedback, getFeedBack } from "../controller/feedBackController.js";
import { requireAuth } from "../middleware/authMiddleware.js";

export const feedBackRouter = express.Router();

feedBackRouter.route("/getFeedBacks").get(getFeedBack);
feedBackRouter.route("/postFeedBack").post(requireAuth, createFeedback);
