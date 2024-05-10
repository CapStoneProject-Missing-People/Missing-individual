import express from "express";
import { RecognizeFace, addFaceFeature } from "../controller/faceRecognition.js";
import multer from 'multer';
import { FaceMatch } from "../controller/faceMatch.js";

const router = express.Router();

const upload = multer();

// face recognition routes
router.route("/recognize").post( upload.any(), RecognizeFace);
router.route("/add-face-feature").post(addFaceFeature);
router.route("/get-face-matches").get(FaceMatch);

export default router;
