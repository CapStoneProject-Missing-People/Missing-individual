import mongoose from 'mongoose';

const matchingStatusSchema = new mongoose.Schema({
  newCaseId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Feature' },
  existingCaseId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Feature' },
  matchingStatus: {
    age: { type: Number, required: false },
    firstName: { type: Number, required: false },
    middleName: { type: Number, required: false },
    lastName: { type: Number, required: false },
    gender: { type: Number, required: false },
    skin_color: { type: Number, required: false },
    description: { type: Number, required: false },
    similarityScore: { type: Number, required: false },
    upperClothType: { type: Number, required: false },
    upperClothColor: { type: Number, required: false },
    lowerClothType: { type: Number, required: false },
    lowerClothColor: { type: Number, required: false },
    body_size: { type: Number, required: false },
    lastSeenLocation: { type: Number, required: false },
    medicalInformation: { type: Number, required: false },
    circumstanceOfDisappearance: { type: Number, required: false }
  },
});

const MatchingStatus = mongoose.model('MatchingStatus', matchingStatusSchema);

export default MatchingStatus;
