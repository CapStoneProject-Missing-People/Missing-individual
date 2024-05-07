import express from "express"
import { compareFeature, createFeature, getFeatures, updateFeature, getSimilarityScore, getFeature, deleteFeature, searchFeature} from "../controller/featureController.js"
import { validateToken } from "../middleware/validationTokenHandler.js"

export const router = express.Router()

router.route('/getAll').get(getFeatures)
router.route('/getSingle/:id').get(getFeature)
router.route('/search').post(searchFeature)
router.get('/similarity/:caseId', validateToken, getSimilarityScore)
router.post('/create', validateToken, createFeature)
router.post('/compare', validateToken, compareFeature)
router.put('/update/:id', validateToken, updateFeature)
router.delete('/delete/:id', validateToken, deleteFeature)


