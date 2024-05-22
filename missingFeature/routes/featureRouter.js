import express from "express";
import { requireAuth } from "../middleware/authMiddleware.js";
import {
  compareFeature,
  getFeatures,
  updateFeature,
  getSimilarityScore,
  getFeature,
  deleteFeature,
  update,
  searchFeature,
  getOwnFeatures,
} from "../controller/featureController.js";

export const featureRouter = express.Router();

featureRouter.route("/getAll").get(getFeatures);
featureRouter.route("/getOwnFeatures").get(requireAuth, getOwnFeatures)
featureRouter.route("/getSingle/:id").get(getFeature);
featureRouter.route("/similarity/:caseId").get(getSimilarityScore);
featureRouter.route("/compare/:timeSinceDisappearance").post(compareFeature);
featureRouter.route("/update/:id").put(requireAuth, updateFeature);
featureRouter.route("/updateFeature/:id").put(requireAuth, update)
featureRouter.route("/delete/:id").delete(requireAuth, deleteFeature);
featureRouter.route("/search/:timeSinceDisappearance").post(searchFeature)