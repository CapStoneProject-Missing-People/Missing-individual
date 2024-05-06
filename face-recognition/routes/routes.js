import express from "express";
import { RecognizeFace, addFaceFeature } from "../controller/faceRecognition.js";
import { getAllActionLogs, getActionLogByID, getActionLogByUser } from "../controller/logging.js";
import multer from 'multer'; // Import multer

const upload = multer();

const router = express.Router();

// face recognition routes
router.route("/recognize").post(upload.any(), RecognizeFace);
router.route("/add-face-feature").post(upload.any(), addFaceFeature);

// log data routes
router.route("/get_action-logs").get(getAllActionLogs);
router.route("/get_user_action-logs/:userId").get(getActionLogByUser);
router.route("/get_action-log/:logId").get(getActionLogByID);

export default router;
