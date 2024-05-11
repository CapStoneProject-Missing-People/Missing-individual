import mongoose from "mongoose";

const { Schema, model } = mongoose;

const baseAttributes = {
  user_id: {
    type: String,
    required: true,
    ref: "User",
  },
  name: Schema({
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
  }),
  age: {
    type: Number,
    required: true,
  },
  skin_color: {
    type: String,
    enum: ["fair", "black", "white", "tseyim"],
    required: true,
  },
  clothing: Schema({
    upper: {
      clothType: {
        type: String,
        enum: ["tshirt", "hoodie", "sweater", "sweetshirt"],
        required: true,
      },
      clothColor: {
        type: String,
        enum: ["red", "blue", "white", "black", "orange", "light blue", "brown", "blue black", "yellow"],
        required: true,
      },
    },
    lower: {
      clothType: {
        type: String,
        enum: ["trouser", "short", "nothing", "boxer"],
        required: true,
      },
      clothColor: {
        type: String,
        enum: ["red", "blue", "white", "black", "orange", "light blue", "brown", "blue black", "yellow"],
        required: true,
      },
    },
    _id: false,
  }),
  body_size: {
    type: String,
    enum: ["thin", "average", "muscular", "overweight", "obese", "fit", "athletic", "curvy", "petite", "fat"],
  },
  description: {
    type: String,
    required: false,
  },
  featureType: {
    type: String
  },
  inputHash: {
    type: String,
    required: true,
    unique: true,
  },
};

const extendSchema = (baseSchema, additionalFields, removedFields) => {
  const extendedSchema = { ...baseSchema };
  Object.assign(extendedSchema, additionalFields);
  removedFields.forEach((field) => {
    delete extendedSchema[field];
  });
  return new Schema(extendedSchema);
};

const modelCache = {}
const initializeFeaturesModel = async (timeSinceDisappearance) => {
  try {
    const modelName = timeSinceDisappearance > 2 ? "Features_GT_2" : "Features_LTE_2"
    if (modelCache[modelName]) {
      return modelCache[modelName]
    }

    let featureSchema = extendSchema(baseAttributes, {}, []);

    if (timeSinceDisappearance > 2) {
      const additionalFields = {
        lastSeenLocation: { type: String },
        medicalInformation: { type: String },
        circumstanceOfDisappearance: { type: String }
      };
      const removedFields = ['clothing', 'body_size'];
      featureSchema = extendSchema(baseAttributes, additionalFields, removedFields);
    }
    const Features = model(modelName, featureSchema);
    modelCache[modelName] = Features
    return Features;
  } catch (error) {
    console.error("Error initializing Features model:", error);
    throw error;
  }
};


export default initializeFeaturesModel;
