import mongoose from "mongoose";

const { Schema, model } = mongoose;

const MergedFeatures = new Schema({
  user_id: {
    type: Schema.Types.ObjectId,
    required: true,
    ref: "User",
  },
  missing_case_id: {
    type: Schema.Types.ObjectId,
    required: false,
    ref: "MissingPerson"
  },
  name: {
    firstName: {
      type: String,
    },
    middleName: {
      type: String,
    },
    lastName: {
      type: String,
    },
    _id: false,
  },
  gender: {
    type: String,
    enum: ["male", "female"],
    required: true
  },
  age: {
    type: Number,
    required: true,
  },
  skin_color: {
    type: String,
    enum: ["fair", "black", "white", "tseyim"],
    required: true,
  },
  clothing: {
    upper: {
      clothType: {
        type: String,
        enum: ["tshirt", "hoodie", "sweater", "sweetshirt"],
        required: false,
      },
      clothColor: {
        type: String,
        enum: ["red", "blue", "white", "black", "orange", "light blue", "brown", "blue black", "yellow"],
        required: false,
      },
    },
    lower: {
      clothType: {
        type: String,
        enum: ["trouser", "shorts", "nothing", "boxer"],
        required: false,
      },
      clothColor: {
        type: String,
        enum: ["red", "blue", "white", "black", "orange", "light blue", "brown", "blue black", "yellow"],
        required: false,
      },
    },
    _id: false,
  },
  body_size: {
    type: String,
    enum: ["thin", "average", "muscular", "overweight", "obese", "fit", "athletic", "curvy", "petite", "fat"],
    required: false
  },
  description: {
    type: String,
    required: false,
  },
  timeSinceDisappearance: {
    type: Number,
  },
  inputHash: {
    type: String,
    required: true,
    unique: true,
  },
  lastSeenLocation: { 
    type: String,
    required: false
  },
  medicalInformation: { 
    type: String,
    required: false
  },
  circumstanceOfDisappearance: {
    type: String,
    required: false
  }
}, { timestamps: true });

export default model("MergedFeaturesModel", MergedFeatures)