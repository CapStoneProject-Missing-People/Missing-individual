import { Schema, model, models } from "mongoose";

// Define MissingPerson schema
const missingPerson = new Schema({
    userID: { type: String, required: true },
    dateReported: { type: Date, default: Date.now },
    description: { type: String, required: true },
    locationLastSeen: { type: String, required: true },
    status: { type: String, enum: ["missing", "found"], default: "missing" },
    age: { type: Number },
    skinColor: { type: String },
    bodySize: { type: String },
    height: { type: String },
    faceFeatureCreated: { type: Boolean, default: false },
  });

const MissingPerson = models.MissingPerson || model("MissingPerson", missingPerson);

export default MissingPerson;
