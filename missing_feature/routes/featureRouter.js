import { Router } from "express";
import {
  compareFeature,
  createFeature,
  getFeatures,
  updateFeature,
} from "../controller/featureController.js";
import * as authController from "../controller/authController.js";
import { requireAuth, isAdmin } from "../middleware/authMiddleware.js";

const router = Router();

router.route("/signup").get(authController.signup_get);
router.route("/signup").post(authController.signup_post);
router.route("/login").get(authController.login_get);
router.route("/login").post(authController.login_post);
router.route("/logout").get(authController.logout_get);

router.route("/").get(requireAuth, getFeatures); // if it requires authentication
router.route("/").post(requireAuth, createFeature); // if it requires authentication
router.route("/compare").post(requireAuth, isAdmin("admin"), compareFeature); // / if it requires authentication and admin permission
router.route("/:id").put(requireAuth, updateFeature); // if it requires authentication

export default router;
