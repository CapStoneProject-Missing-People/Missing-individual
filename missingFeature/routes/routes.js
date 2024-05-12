import express from "express";
import multer from "multer";
import { CreateMissingPerson } from "../controller/missingPersonController.js";
import { requireAuth } from "../middleware/authMiddleware.js";

const upload = multer();

export const router = express.Router();

router
  .route("/createMissingPerson")
  .post(upload.any(), requireAuth, CreateMissingPerson);
