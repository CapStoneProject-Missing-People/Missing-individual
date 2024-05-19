import express from "express";
import { requireAuth } from "../middleware/authMiddleware.js";
import {
  compareFeature,
  createFeature,
  getFeatures,
  updateFeature,
  getSimilarityScore,
  getFeature,
  deleteFeature,
} from "../controller/featureController.js";

export const featureRouter = express.Router();

featureRouter.route("/getAll").get(getFeatures);
featureRouter.route("/getSingle/:id").get(getFeature);
featureRouter.route("/similarity/:caseId").get(getSimilarityScore);
featureRouter.route("/create").post(createFeature);
featureRouter.route("/compare").post(compareFeature);
featureRouter.route("/update/:id").put(requireAuth, updateFeature);
featureRouter.route("/delete/:id").delete(requireAuth, deleteFeature)