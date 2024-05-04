import express from "express"
import { compareFeature, createFeature, getFeatures, updateFeature, getSimilarityScore, getFeature} from "../controller/featureController.js"

export const router = express.Router()

router.route('/getAll').get(getFeatures)
router.route('/getSingle/:id').get(getFeature)
router.route('/similarity/:caseId').get(getSimilarityScore)
router.route('/create').post(createFeature)
router.route('/compare').post(compareFeature)
router.route('/update/:id').put(updateFeature)


