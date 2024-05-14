import mongoose from "mongoose";
import initializeFeaturesModel from "./featureModel.js";

const mergeFeatures = async () => {
  try {
    // Initialize models for both collections
    const Features_GT_2 = await initializeFeaturesModel(3); // Example: timeSinceDisappearance > 2
    const Features_LTE_2 = await initializeFeaturesModel(1); // Example: timeSinceDisappearance <= 2

    // Define the MergedFeatures model
    const MergedFeaturesSchema = Features_GT_2.schema;
    const MergedFeaturesModel = mongoose.model('MergedFeatures', MergedFeaturesSchema);

    // Check if MergedFeatures collection is empty
    const mergedFeaturesCount = await MergedFeaturesModel.countDocuments();
    if (mergedFeaturesCount === 0) {
      // If MergedFeatures collection is empty, merge both collections
      const features_GT_2_docs = await Features_GT_2.find({});
      const features_LTE_2_docs = await Features_LTE_2.find({});

      // Merge documents
      const mergedDocs = [...features_GT_2_docs, ...features_LTE_2_docs];

      // Insert merged documents into MergedFeatures collection
      await MergedFeaturesModel.create(mergedDocs);
      console.log("Merge operation completed successfully.");
    }

    return MergedFeaturesModel;
  } catch (error) {
    console.error("Error merging collections:", error);
    throw error;
  }
};

export default mergeFeatures;