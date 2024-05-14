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

export const routers = express.Router();

routers.route("/getAll").get(getFeatures);
routers.route("/getSingle/:id").get(getFeature);
routers.route("/similarity/:caseId").get(getSimilarityScore);
routers.route("/create").post(createFeature);
routers.route("/compare").post(compareFeature);
routers.route("/update/:id").put(requireAuth, updateFeature);
routers.route("/delete/:id").delete(requireAuth, deleteFeature)