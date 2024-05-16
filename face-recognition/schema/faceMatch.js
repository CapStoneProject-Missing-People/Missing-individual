import pkg from "mongoose";
const { Schema, model, models } = pkg;


const faceMatchSchema = new Schema({
  person_id: {
    type: String,
    required: true,
  },
  distance: {
    type: String,
    required: true,
  },
  similarity: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  }
});

faceMatchSchema.index({person_id: 1});

const FaceMatchResult = models.FaceMatchResult || model("FaceMatchResult", faceMatchSchema);

export default FaceMatchResult;
