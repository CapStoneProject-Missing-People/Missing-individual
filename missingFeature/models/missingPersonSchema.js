import mongoose from "mongoose";

const { Schema, model, models } = mongoose;
// Define MissingPerson schema
const missingPerson = new Schema({
  userID: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "user",
  },
  dateReported: { type: Date, default: Date.now },
  status: { type: String, enum: ["missing", "found"], default: "missing" },
  imagePaths: [{ type: String }], // Array of image URLs
  faceFeatureCreated: { type: Boolean, default: false },
});

const MissingPerson =
  models.MissingPerson || model("MissingPerson", missingPerson);

export default MissingPerson;
