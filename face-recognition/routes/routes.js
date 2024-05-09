import express from "express";
import { RecognizeFace, addFaceFeature } from "../controller/faceRecognition.js";


const router = express.Router();

// face recognition routes
router.route("/recognize").post(RecognizeFace);
router.route("/add-face-feature").post(addFaceFeature);

export default router;
