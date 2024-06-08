// similarityScoreModel.js
import mongoose from 'mongoose';

const similarityDetailSchema = new mongoose.Schema({
  firstName: { type: Number, required: true },
  middleName: { type: Number, required: true },
  lastName: { type: Number, required: true },
  gender: { type: Number, required: true },
  skin_color: { type: Number, required: true },
  description: { type: Number, required: true },
  lastSeenLocation: { type: Number, required: true },
  medicalInformation: { type: Number, required: true },
  circumstanceOfDisappearance: { type: Number, required: true },
});

const similarityScoreSchema = new mongoose.Schema({
  caseId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Feature', // Assuming 'Feature' is the name of your feature model
  },
  similarities: [similarityDetailSchema], // Array of similarity objects
});

const SimilarityScore = mongoose.model('SimilarityScore', similarityScoreSchema);

export default SimilarityScore;
