import Features from "../models/featureModel.js";
import crypto from "crypto";
import embeddings from "../models/embeddingsModel.js";
import { pipeline } from "@xenova/transformers";
import { response } from "express";

//@desc Get Features
//@route GET /api/features
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
        return res.status(400).json({ error: "Invalid age range" });
      }
    }

    //Query database with constructed filter criteria
    const features = await Features.find(filterCriteria).lean();

    res.status(200).json(features);
  } catch {
    res.status(500).json({ error: "Server error" });
    console.log("Error fetching features: ", error.message);
  }
};

//@desc Get Feature
//@route GET /api/features/:id
//@access public
export const getFeature = async (req, res) => {
  try {
    const feature = await Features.findById(req.params.id);
    if (!feature) {
      res.status(404);
      throw new Error("Feature not found");
    }
    res.status(200).json(feature);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

//@desc Get Feature
//@route GET /api/features/:id
//@access private
// export const getFeature = async ( req, res ) => {
//   try{
//     const feature = await Features.findById(req.params.id)
//     if(!feature) {
//       res.status(404)
//       throw new Error("Feature not found")
//     }
//     res.status(200).json(feature)
//   }catch(error) {
//     res.status(500).json({ message: error.message})
//   }
// }

//@desc Get Feature
//@route GET /api/features/similarity/caseId
//@access public

//endpoint for getting similarity scores
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

const updateSimilarityField = async (
  caseId,
  existingEmbeddingId,
  similarityScore
) => {
  try {
    // Find the existing embedding by ID
    const existingEmbedding = await embeddings.findById(existingEmbeddingId);

    // Check if the existing embedding exists and has a similarity field
    if (existingEmbedding) {
      // Push the new similarity object into the existing array
      existingEmbedding.similarity.push({ CaseId: caseId, similarityScore });

      // Create a new document with the updated similarity field
      await embeddings.create(existingEmbedding);

      console.log(
        `Updated similarity field for embedding ${existingEmbeddingId} successfully`
      );
    } else {
      console.log(
        `Existing embedding ${existingEmbeddingId} not found or does not have a similarity field`
      );
    }
  } catch (error) {
    console.error("Error updating similarity field:", error);
  }
};

//@desc Get Feature
//@route GET /api/features
//@access public
//an endpoint to create features
export const createFeature = async (req, res) => {
  try {
    const {
      age,
      skin_color,
      clothing: {
        upper: { clothType: upperClothType, clothColor: upperClothColor },
        lower: { clothType: lowerClothType, clothColor: lowerClothColor },
      },
      body_size,
      description: {
        eyeDescription,
        noseDescription,
        hairDescription,
        lastSeenAddressDes,
      },
    } = req.body;

    const inputHash = calculateHash({
      age,
      skin_color,
      clothing: {
        upper: { clothType: upperClothType, clothColor: upperClothColor },
        lower: { clothType: lowerClothType, clothColor: lowerClothColor },
      },
      body_size,
      description: {
        eyeDescription,
        noseDescription,
        hairDescription,
        lastSeenAddressDes,
      },
    });
    //check if incoming feature already in database
    const existingFeature = await Features.findOne({ inputHash });

    if (existingFeature) {
      return res
        .status(400)
        .json({ error: "Duplicate feature already exists" });
    }

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
    console.log(descriptions);

    const feature = await Features.create({
      age,
      skin_color,
      clothing: {
        upper: { clothType: upperClothType, clothColor: upperClothColor },
        lower: { clothType: lowerClothType, clothColor: lowerClothColor },
      },
      body_size,
      description: descriptions,
      inputHash,
    });
    console.log("feature stored successfully");

    const existingEmbeddingsCount = await embeddings.countDocuments();
    let response = [];
    if (existingEmbeddingsCount < 1) {
      const caseId = feature._id;
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(descriptions, {
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
      const output = await pipelineModel(descriptions, {
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
            similarityScore: similarity,
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

      console.log(similarityScores);
      //sort similarity scores in descending order
      similarityScores.sort((a, b) => b.similarityScore - a.similarityScore);
      // Prepare top 10 similarities with their respective case IDs for response
      response = similarityScores.slice(0, 10).map((item) => ({
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
    res.status(200).json({ message: response });
  } catch (error) {
    res.status(500).json({ error: "Server error" });
    console.error("Error creating feature:", error);
  }
};

//@desc Get Feature
//@route GET /api/features/compare
//@access public
//an endpoint to compare features
export const compareFeature = async (req, res) => {
  try {
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
      let response = [];

      // Find all embeddings in the database
      const existingEmbeddings = await embeddings.find();
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(descriptions, {
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
      console.log(similarityScores);
      const {
        age,
        skin_color,
        clothing: {
          upper: { clothType: upperClothType, clothColor: upperClothColor },
          lower: { clothType: lowerClothType, clothColor: lowerClothColor },
        },
        body_size,
      } = req.body;

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

      const criteria = {
        age,
        skin_color,
        "clothing.upper.clothType": upperClothType,
        "clothing.upper.clothColor": upperClothColor,
        "clothing.lower.clothType": lowerClothType,
        "clothing.lower.clothColor": lowerClothColor,
        body_size,
      };

      const matchingCases = await Features.find({}).lean();

      matchingCases.forEach((caseData) => {
        const matchingStatus = { id: caseData._id };
        for (const key in criteria) {
          const value = criteria[key];
          if (key === "age") {
            if (caseData.age === value) {
              console.log("casedata.age ", caseData.age);
              console.log("value ", value);
              matchingStatus.age = `Exact age match`;
            } else {
              var ageRangeMatch = false;
              var caseDataAgeRange = "";
              var newReqAge = "";
              for (const rangeKey of ageRangeKeys) {
                const range = ageRanges[rangeKey];
                if (caseData.age >= range.$gte && caseData.age <= range.$lte) {
                  caseDataAgeRange = rangeKey;
                  // console.log("caseDataAgeRange: ", caseDataAgeRange)
                }
                if (value >= range.$gte && value <= range.$lte) {
                  newReqAge = rangeKey;
                  // console.log("newReqAge: ", newReqAge)
                }
              }

              if (caseDataAgeRange === newReqAge) {
                console.log("potential age match");
                ageRangeMatch = true;
                matchingStatus.age = `potential age match (${caseDataAgeRange})`;
              }

              if (!ageRangeMatch) {
                console.log("did not match");
                matchingStatus.age = "did not match";
              }
            }
          } else if (!key.startsWith("clothing.")) {
            matchingStatus[key] =
              caseData[key] === value ? "match" : "did not match";
          }

          if (key.startsWith("clothing.")) {
            const clothingParts = key.split(".");
            const clothingType = clothingParts[1];
            const clothKey = clothingParts[2];

            const caseClothType = caseData.clothing[clothingType][clothKey];
            matchingStatus[`${clothingType} ${clothKey}`] =
              caseClothType === value ? "match" : "did not match";
          }
        }

        similarityScores.forEach((score) => {
          console.log("existingId: ", score.existingCaseId);
          console.log("casedata id: ", caseData._id);
          console.log(score.existingCaseId.equals(caseData._id));
          if (score.existingCaseId.equals(caseData._id)) {
            console.log("they are the same");
            matchingStatus.similarityScore = score.similarityScore;
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

//@desc Get Feature
//@route GET /api/features
//@access public
//an endpoint to update fatures
export const updateFeature = async (req, res) => {
  try {
    const feature = await Features.findById(req.params.id);
    if (!feature) {
      res.status(404);
      throw new Error("Feature not found");
    }

    const updatedFeature = await Features.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    res.status(201).json(`Feature updated: ${updatedFeature}`);
    console.log("Feature updated successfully");
  } catch (error) {
    res.status(500).json({ error: "server error" });
    console.error(`Error updating feature ${error.message}`);
  }
};
