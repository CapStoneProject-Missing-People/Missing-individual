import pkg from "mongoose";
const { Schema, model, models } = pkg;


const faceSchema = new Schema({
  person_id: {
    type: String,
    required: true,
  },
  feature_vector: {
    type: Array,
    required: true,
  },
});

faceSchema.index({person_id: 1});

const FaceModel = models.FaceModel || model("FaceModel", faceSchema);

export default FaceModel;
