import express from "express";
import {
  compareFeature,
  createFeature,
  getFeatures,
  updateFeature,
  getSimilarityScore,
  getFeature,
} from "../controller/featureController.js";

export const routers = express.Router();

routers.route("/getAll").get(getFeatures);
routers.route("/getSingle/:id").get(getFeature);
routers.route("/similarity/:caseId").get(getSimilarityScore);
routers.route("/create").post(createFeature);
routers.route("/compare").post(compareFeature);
routers.route("/update/:id").put(updateFeature);
