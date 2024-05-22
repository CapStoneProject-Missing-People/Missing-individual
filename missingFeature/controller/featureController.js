import initializeFeaturesModel from "../models/featureModel.js";
import crypto from "crypto";
import embeddings from "../models/embeddingsModel.js";
import { pipeline } from "@xenova/transformers";
import mongoose from "mongoose";
import MergedFeaturesModel from "../models/mergedFeatureSchema.js"

export const getOwnFeatures = async (req, res) => {
  try {
    const filterCriteria = {}
    if (req.user) {
      // Check if the user wants to view their own features
      if (req.query.ownFeatures === "true") {
        filterCriteria.user_id = req.user.id;
      }
    }
    const features = await MergedFeaturesModel.find(filterCriteria).lean().populate({path: 'missing_case_id', select:['status', 'imageBuffers', 'dateReported']});
    console.log("features", features);

    res.status(200).json(features);
  } catch (error){
    res.status(500).json({ error: "Server error" });
    console.log("Error ferching features: ", error);
}
}

//@desc Get all Features
//@route GET /api/features/getAll
//@access public
export const getFeatures = async (req, res) => {
  try {
    let filterCriteria = {};

    // Map age ranges to MongoDB query conditions
    const ageRanges = {
      "1-4": { $gte: 1, $lte: 4 },
      "5-10": { $gte: 5, $lte: 10 },
      "11-15": { $gte: 11, $lte: 15 },
      "16-20": { $gte: 16, $lte: 20 },
      "21-30": { $gte: 21, $lte: 30 },
      "31-40": { $gte: 31, $lte: 40 },
      "41-50": { $gte: 41, $lte: 50 },
      ">51": { $gt: 51 },
    };

    //check if age range filter is provided in the request
    if (req.query.ageRange) {
      const ageRangeQuery = ageRanges[req.query.ageRange];
      if (ageRangeQuery) {
        filterCriteria.age = ageRangeQuery;
      } else {
        throw new Error("invalid filter criteria age range");
      }
    }

    if (req.query.filterBy && req.query[req.query.filterBy]) {
      const nameField = `name.${req.query.filterBy}`;
      filterCriteria[nameField] = {
        $regex: req.query[req.query.filterBy],
        $options: "i",
      };
    }

    // If user is authenticated, filter features by user ID
    if (req.user) {
      // Check if the user wants to view their own features
      if (req.query.ownFeatures === "true") {
        filterCriteria.user_id = req.user.userId;
      }
    }
    const features = await MergedFeaturesModel.find(filterCriteria).lean().populate({path: 'missing_case_id', select:['status', 'imageBuffers', 'dateReported']});
    console.log("features: ", features);

    res.status(200).json(features);
  } catch (error){
    res.status(500).json({ error: "Server error" });
    console.log("Error ferching features: ", error);
  }
};

//@desc Get single Feature
//@route GET /api/features/getSingle/:id
//@access public
export const getFeature = async (req, res) => {
  try {
    const Features_GT_2 = await initializeFeaturesModel(3); 
    const Features_LTE_2 = await initializeFeaturesModel(1);
    const MergedFeaturesSchema = Features_GT_2.schema || Features_LTE_2.schema;
    const MergedFeaturesModel = mongoose.model('MergedFeatures', MergedFeaturesSchema);
    const feature = await MergedFeaturesModel.findById(req.params.id);
    if (!feature) {
      res.status(404);
      throw new Error("Feature not found");
    }
    res.status(200).json(feature);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

//@desc Get similarity score
//@route GET /api/features/similarity/caseId
//@access private
export const getSimilarityScore = async (req, res) => {
  try {
    const { caseId } = req.params;

    //Find the embeddings document for the provided case ID
    const embedding = await embeddings.findOne({ caseId });
    if (!embedding) {
      
      return res
        .status(404)
        .json({ error: "Embeddings not found for the given case ID" });
    }

    //Extract and return the top 10 similarity scores
    const topSimilarities = embedding.similarity.slice(0, 10);

    res.status(200).json({ topSimilarities });
  } catch (error) {
    console.log("Error fetchig similarity scores: ", error);
    res.status(500).json({ error: "Server error " });
  }
};

//function to generate embeddigs
const generateEmbeddings = async () => {
  const pipelineModel = await pipeline(
    "feature-extraction",
    "Xenova/all-MiniLM-L6-v2"
  );
  return pipelineModel;
};

//a function that calculates hash from the features data
const calculateHash = (data) => {
  const hash = crypto.createHash("sha256");
  hash.update(JSON.stringify(data));
  return hash.digest("hex");
};

//the logic to calculate cosine similarity
const calculateSimilarity = (embedding1, embedding2) => {
  let dotProduct = 0;
  for (let i = 0; i < embedding1.length; i++) {
    dotProduct += embedding1[i] * embedding2[i];
  }

  const magnitude1 = Math.sqrt(
    embedding1.reduce((acc, val) => acc + Math.pow(val, 2), 0)
  );
  const magnitude2 = Math.sqrt(
    embedding2.reduce((acc, val) => acc + Math.pow(val, 2), 0)
  );

  const similarity = dotProduct / (magnitude1 * magnitude2);

  return similarity;
};

//updates the top10 similarities for a case
const updateSimilarityField = async (
  caseId,
  existingEmbeddingId,
  similarityScore
) => {
  try {
    const existingEmbedding = await embeddings.findById(existingEmbeddingId);
    if (existingEmbedding) {
      existingEmbedding.similarity.push({ CaseId: caseId, similarityScore });
      await embeddings.create(existingEmbedding);
    } else {
      console.log(
        `Existing embedding ${existingEmbeddingId} not found or does not have a similarity field`
      );
    }
  } catch (error) {
    console.error("Error updating similarity field:", error);
  }
};

//@desc create new Feature
//@route POST /api/features/create
//@access private
export const createFeature = async (data, timeSinceDisappearance, userId, res) => {
  try {
    const Features = await initializeFeaturesModel(timeSinceDisappearance)
    const featureData = {
      ...data,
      inputHash: calculateHash(data),
      user_id: userId
    }

    const existingFeature = await Features.findOne({inputHash: featureData.inputHash });
    if (existingFeature) {
      return 'duplicate feature already exist'
    }
    const feature = await Features.create( featureData );
    console.log("feature stored successfully");
    const featureId = feature._id
    const existingFeatureMerged = await MergedFeaturesModel.findOne({ inputHash: featureData.inputHash });
    if (existingFeatureMerged) {
      return 'Duplicate feature already exists in MergedFeatures collection'
    }

    const mergedFeatures = await MergedFeaturesModel.create( featureData )
    console.log("Feature stored successfully in MergedFeatures collection.");
    console.log("mergedFeatures: ", mergedFeatures)
    mergedFeatures.featureId = featureId
    mergedFeatures.save()
    const existingEmbeddingsCount = await embeddings.countDocuments();
    if (existingEmbeddingsCount < 1) {
      const caseId = feature._id;
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(data.description, {
        pooling: "mean",
        normalize: true,
      });
      const embeddingData = output.data;

      const embeddingArray = [...embeddingData];
      // Store the new embedding directly if no existing data in embeddings collection
      await embeddings.create({
        caseId,
        embedding: embeddingArray,
        similarity: {},
      });
      console.log("initial embedding stored successfully");
    } else {
      // Find all embeddings in the database
      const existingEmbeddings = await embeddings.find();
      const caseId = feature._id;
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(data.description, {
        pooling: "mean",
        normalize: true,
      });
      const embeddingData = output.data;

      const embeddingArray = [...embeddingData];
      // Calculate cosine similarity with each existing embedding
      const similarityScores = await existingEmbeddings.map(
        (existingEmbedding) => {
          const similarity = calculateSimilarity(
            embeddingData,
            existingEmbedding.embedding
          );
          return {
            existingCaseId: existingEmbedding.caseId,
            existingEmbeddingId: existingEmbedding._id,
            similarityScore: similarity * 100,
          };
        }
      );

      // Create an array of similarity objects
      const similarityObjects = similarityScores.map((item) => ({
        CaseId: item.existingCaseId, // Corrected property name
        existingEmbId: item.existingEmbeddingId,
        similarityScore: item.similarityScore,
      }));

      // Create the embeddings document with the similarity field
      await embeddings.create({
        caseId,
        embedding: embeddingArray,
        similarity: similarityObjects,
      });

      similarityScores.sort((a, b) => b.similarityScore - a.similarityScore);
      // Prepare top 10 similarities with their respective case IDs for response
      similarityScores.slice(0, 10).map((item) => ({
        caseId: item.existingCaseId,
        similarityScore: item.similarityScore,
      }));
      // Update similarity field for top 10 similar embeddings
      const topNSimilarities = similarityScores.slice(0, 10); // Consider only the top 10 similar embeddings
      for (let i = 0; i < topNSimilarities.length; i++) {
        const { existingCaseId, existingEmbeddingId, similarityScore } =
          topNSimilarities[i];
        await updateSimilarityField(
          caseId,
          existingEmbeddingId,
          similarityScore
        );
      }
    }
   return {message: " feature stored succeffully", createdFeature: feature, mergedFeature: mergedFeatures}
  } catch (error) {
    console.error("Error creating feature:", error);
    throw new Error(error)
  }
};


//@desc compare Feature
//@route POST /api/features/compare
//@access public
export const compareFeature = async (req, res) => {
  try {
    let { timeSinceDisappearance } = req.params
    const descriptionTypes = [
      "eyeDescription",
      "noseDescription",
      "hairDescription",
      "lastSeenAddressDes",
    ];

    let descriptions = "";
    for (const descType of descriptionTypes) {
      descriptions += req.body.description[descType];
    }
    // console.log(descriptions)

    const existingEmbeddingsCount = await embeddings.countDocuments();

    if (existingEmbeddingsCount < 1) {
      console.log("Nothing to compare with");
      res.json({ message: "nothing in database" });
      return;
    } else {
      let response = []
      let featureData = {};
      
      if (timeSinceDisappearance > 2) {
        featureModelName = "Features_GT_2";
        featureData = {
          lastSeenLocation: req.body.lastSeenLocation,
          medicalInformation: req.body.medicalInformation,
          circumstanceOfDisappearance: req.body.circumstanceOfDisappearance,
        };
      } else {
        featureModelName = "Features_LTE_2";
        console.log(req.body.clothing.lower.clothType)
        featureData = {
          "clothing.upper.clothType": req.body.clothing.upper.clothType,
          "clothing.upper.clothColor": req.body.clothing.upper.clothColor,
          "clothing.lower.clothType": req.body.clothing.lower.clothType,
          "clothing.lower.clothColor": req.body.clothing.lower.clothColor,
          body_size: req.body.body_size,
        };
      }
      
      const Features = await initializeFeaturesModel(timeSinceDisappearance)
     
      // Find all embeddings in the database
      const existingEmbeddings = await embeddings.find();
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(data.description, {
        pooling: "mean",
        normalize: true,
      });
      const embeddingData = output.data;

      const embeddingArray = [...embeddingData];
      // Calculate cosine similarity with each existing embedding
      const similarityScores = await existingEmbeddings.map(
        (existingEmbedding) => {
          const similarity = calculateSimilarity(
            embeddingData,
            existingEmbedding.embedding
          );
          return {
            existingCaseId: existingEmbedding.caseId,
            similarityScore: similarity,
          };
        }
      );

      similarityScores.sort((a, b) => b.similarityScore - a.similarityScore);
      // console.log(similarityScores);

   // Construct criteria based on the request body
      const criteria = {
        age: req.body.age,
        "name.firstName": req.body.name.firstName,
        "name.middleName": req.body.name.middleName,
        "name.lastName": req.body.name.lastName,
        skin_color: req.body.skin_color,
        ...featureData, // Include feature-specific data
      };

      console.log(criteria)
      const ageRanges = {
        "1-4": { $gte: 1, $lte: 4 },
        "5-10": { $gte: 5, $lte: 10 },
        "11-15": { $gte: 11, $lte: 15 },
        "16-20": { $gte: 16, $lte: 20 },
        "21-30": { $gte: 21, $lte: 30 },
        "31-40": { $gte: 31, $lte: 40 },
        "41-50": { $gte: 41, $lte: 50 },
        ">51": { $gt: 51 },
      };

      const ageRangeKeys = Object.keys(ageRanges);

      const matchingCases = await Features.find({}).lean();
      matchingCases.forEach((caseData) => {
        const matchingStatus = { id: caseData._id };
        for (const key in criteria) {
          // var featurePercentValue = 0
          const value = criteria[key];
          if (key === "age") {
            if (caseData.age === value) {
              matchingStatus.age = 100;
            } else {
              var ageRangeMatch = false;
              var caseDataAgeRange = "";
              var newReqAge = "";
              for (const rangeKey of ageRangeKeys) {
                const range = ageRanges[rangeKey];
                if (caseData.age >= range.$gte && caseData.age <= range.$lte) {
                  caseDataAgeRange = rangeKey;
                }
                if (value >= range.$gte && value <= range.$lte) {
                  newReqAge = rangeKey;
                }
              }

              if (caseDataAgeRange === newReqAge) {
                console.log("potential age match");
                // featurePercentValue = 85
                ageRangeMatch = true;
                matchingStatus.age = 85;
              }

              if (!ageRangeMatch) {
                console.log("did not match");
                matchingStatus.age = 0;
              }
            }
          } else if (key.startsWith("name.")) {
            const nameWritten = key.split(".");
            const nameType = nameWritten[1];
            matchingStatus[nameType] =
              caseData.name[nameType] === value ? 100 : 0;
          } else if (key.startsWith("clothing.")) {
            const clothingParts = key.split(".");
            const clothingType = clothingParts[1];
            const clothKey = clothingParts[2];
            const caseClothType = caseData.clothing[clothingType][clothKey];
            if (
              (caseClothType === "blue" && value === "light blue") ||
              (caseClothType === "light blue" && value === "blue")
            ) {
              console.log("85%");
              matchingStatus[`${clothingType} ${clothKey}`] = 85;
            } else if (
              (caseClothType === "yellow" && value === "orange") ||
              (caseClothType === "orange" && value === "yellow")
            ) {
              matchingStatus[`${clothingType} ${clothKey}`] = 85;
            } else {
              matchingStatus[`${clothingType} ${clothKey}`] =
                caseClothType === value ? 100 : 0;
            }
          } else {
            matchingStatus[key] = caseData[key] === value ? 100 : 0;
          }
        }

        similarityScores.forEach((score) => {
          if (score.existingCaseId.equals(caseData._id)) {
            matchingStatus.similarityScore = score.similarityScore * 100;
          }
        });

        response.push(matchingStatus);
      });
      res.json({ matchingStatus: response });
    }
  } catch (error) {
    res.status(500).json({ error: "Server error" });
    console.error("Error comparing features:", error.message);
  }
};


export const update = async (req, res) => {
  try {
    const { updateBy, updateTerm } = req.body;
    const timeSinceDisappearance = req.query.timeSinceDisappearance;
    
    if (!updateBy || !updateTerm) {
      return res.status(400).json({ error: "Update criteria not provided" });
    }

    const updateObject = {};
    updateObject[`name.${updateBy}`] = updateTerm;
    const Features = await initializeFeaturesModel(timeSinceDisappearance);
    const feature = await Features.findById(req.params.id);
    console.log(feature)
    if (!feature) {
      return res.status(404).json({ error: "Feature not found" });
    }

    // Check user permissions
    console.log(req.user.userId)
    console.log(feature.user_id)
    if (feature.user_id.toString() !== req.user.userId.toString()) {
      return res.status(403).json({ error: "User doesn't have permission to update other users' features!" });
    }

    // Update the feature in the primary collection
    const updatedFeature = await Features.findByIdAndUpdate(
      req.params.id,
      { $set: updateObject },
      { new: true }
    );

    const updatedMergedFeature = await MergedFeaturesModel.findByIdAndUpdate(
      MergedFeaturesModel.featureId,
      { $set: updateObject },
      { new: true }
    );

    res.status(200).json({ updatedFeature, updatedMergedFeature });
    console.log("Feature updated successfully");
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.error(`Error updating feature: ${error}`);
  }
};


//@desc updare Feature
//@route PUT /api/features
//@access private
export const updateFeature = async (req, res) => {
  try {
    const timeSinceDisappearance = req.query.timeSinceDisappearance;
    const Features = await initializeFeaturesModel(timeSinceDisappearance);
    const feature = await Features.findById(req.params.id);
    console.log('id: ', req.params.id)
    if (!feature) {
      res.status(404);
      throw new Error("Feature not found");
    }

    console.log(feature.user_id)
    console.log(req.user.userId)
    // console.log(req.user)
    if (feature.user_id.toString() !== req.user.userId.toString()) {
      console.log('not here')
      res.status(403);
      throw new Error(
        "User doesn't have permission to update other users' features!"
      );
    }

    let baseReq;
    if (timeSinceDisappearance > 2) {
      const { lastSeenLocation, medicalInformation, circumstanceOfDisappearance, ...base } = req.body;
      baseReq = { ...base, lastSeenLocation, medicalInformation, circumstanceOfDisappearance }
    } else {
      const { clothing: { upper: { clothType: upperClothType, clothColor: upperClothColor }, lower: { clothType: lowerClothType, clothColor: lowerClothColor } }, body_size, ...base } = req.body;
      baseReq = base;
    }

    const concatenatedDescription = `${req.body.description.eyeDescription}.${req.body.description.noseDescription}.${req.body.description.hairDescription}.${req.body.description.lastSeenAddressDes}`;
    const featureData = {
      ...baseReq,
      age: req.body.age,
      name: req.body.name,
      skin_color: req.body.skin_color,
      clothing: req.body.clothing ? {
        upper: { clothType: req.body.clothing.upper.clothType, clothColor: req.body.clothing.upper.clothColor },
        lower: { clothType: req.body.clothing.lower.clothType, clothColor: req.body.clothing.lower.clothColor }
      } : undefined,
      body_size: req.body.body_size,
      description: concatenatedDescription,
      inputHash: calculateHash(req.body),
      user_id: req.user.id
    };

    // Check if a feature with the same inputHash already exists
    const existingFeature = await Features.findOne({ inputHash: featureData.inputHash });
    if (existingFeature && existingFeature._id.toString() !== req.params.id) {
      // If the existing feature has a different ID, it's a duplicate
      return res.status(400).json({ error: "already updated" });
    }

    // Update the feature
    const updatedFeature = await Features.findByIdAndUpdate(
      req.params.id,
      featureData,
      { new: true }
    );
    console.log(MergedFeaturesModel.featureId)
    await MergedFeaturesModel.findByIdAndUpdate(
      MergedFeaturesModel.featureId,
      featureData,
      { new: true }
    );
    res.status(201).json({ FeatureUpdated: updatedFeature });
    console.log("Feature updated successfully");
  } catch (error) {
    res.status(500).json({ error: error.message });
    console.error(`Error updating feature: ${error}`);
  }
};

//@desc Delete Feature
//@route Delete /api/features/delete/:id
//@access private
//an endpoint to delete fature
export const deleteFeature = async (req, res) => {
  try {
    const timeSinceDisappearance = req.query.timeSinceDisappearance;
    const Features = await initializeFeaturesModel(timeSinceDisappearance);
    const feature = await Features.findById(req.params.id);
    if (!feature) {
      res.status(404).json({message: "feature not found"});
    }
    
    if (feature.user_id.toString() !== req.user.userId.toString()) {
      res.status(403);
      throw new Error(
        "User don't have permission to update other users feature!"
      );
    }
    await feature.deleteOne();
    await MergedFeaturesModel.deleteOne({ _id: req.params.id });
    res.status(200).json({ message: "feature deleted succussfully", feature });
  } catch (error) {
    res.json({ title: "UNAUTHORIZED", message: error.message });
  }
};

//@desc search Feature
//@route search /api/features/search
//@access public
//an endpoint to search fature
export const searchFeature = async (req, res) => {
  try {
    const { searchBy, searchTerm } = req.body;

    if (!searchBy || !searchTerm) {
      return res
        .status(400)
        .json({ error: "Both searchBy and searchTerm are required." });
    }

    let searchCriteria = {};
    if (searchBy === "firstName") {
      searchCriteria["name.firstName"] = { $regex: searchTerm, $options: "i" };
      console.log(searchCriteria)
    } else if (searchBy === "middleName") {
      searchCriteria["name.middleName"] = { $regex: searchTerm, $options: "i" };
    } else if (searchBy === "lastName") {
      searchCriteria["name.lastName"] = { $regex: searchTerm, $options: "i" };
    } else {
      return res.status(400).json({ error: "Invalid searchBy parameter." });
    }
    const features = await MergedFeaturesModel.find(searchCriteria).lean();
    console.log(features)
    res.status(200).json(features);
  } catch (error) {
    console.error("Error fetching features:", error.message);
    res.status(500).json({ error: "Server error" });
  }
};