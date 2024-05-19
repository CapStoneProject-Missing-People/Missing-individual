import mongoose from "mongoose";

const { Schema, model, models } = mongoose;
// Define MissingPerson schema
const missingPerson = new Schema({
  userID: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "user",
  },
  dateReported: { type: Date, default: Date.now },
  status: { type: String, enum: ["missing", "pending", "found"], default: "missing" },
  imageBuffers: [{ type: Buffer }], 
  faceFeatureCreated: { type: Boolean, default: false },
});

const MissingPerson =
  models.MissingPerson || model("MissingPerson", missingPerson);

export default MissingPerson;
