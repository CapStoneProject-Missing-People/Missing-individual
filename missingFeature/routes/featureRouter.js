import express from "express"
import { compareFeature, createFeature, getFeatures, updateFeature } from "../controller/featureController.js"

export const router = express.Router()

router.route('/').get(getFeatures)
router.route('/').post(createFeature)
router.route('/compare').post(compareFeature)
router.route('/:id').put(updateFeature)


