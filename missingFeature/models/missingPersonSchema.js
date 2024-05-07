import mongoose from "mongoose";

const { Schema, model, models } = mongoose;
// Define MissingPerson schema
const missingPerson = new Schema({
    userID: { type: String, required: true },
    dateReported: { type: Date, default: Date.now },
    locationLastSeen: { type: String, required: true },
    status: { type: String, enum: ["missing", "found"], default: "missing" },
    imagePaths: [{ type: String }], // Array of image URLs
    faceFeatureCreated: { type: Boolean, default: false },
  });

const MissingPerson = models.MissingPerson || model("MissingPerson", missingPerson);

export default MissingPerson;
