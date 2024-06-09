import express from "express";
import { requireAuth } from "../middleware/authMiddleware.js";
import {
  compareFeature,
  getFeatures,
  getSimilarityScore,
  getFeature,
  deleteFeature,
  update,
  searchFeature,
  getOwnFeatures,
  getPotentialMatchs
} from "../controller/featureController.js";

export const featureRouter = express.Router();

featureRouter.route("/getAll").get(getFeatures);
featureRouter.route("/getOwnFeatures").get(requireAuth, getOwnFeatures)
featureRouter.route("/getSingle/:caseId").get(getFeature);
featureRouter.route("/similarity/:caseId").get(getSimilarityScore);
featureRouter.route("/compare/:timeSinceDisappearance").post(compareFeature);
featureRouter.route("/updateFeature/:caseId").put(requireAuth, update)
featureRouter.route("/delete/:caseId").delete(requireAuth, deleteFeature);
featureRouter.route("/search/:timeSinceDisappearance").post(searchFeature)
featureRouter.route("/getPotentialMatch").get(requireAuth, getPotentialMatchs)
