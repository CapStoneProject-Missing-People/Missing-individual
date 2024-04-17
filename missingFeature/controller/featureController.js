import Features from "../models/featureModel.js";
import crypto from "crypto";
import embeddings from "../models/embeddingsModel.js";
import { pipeline } from "@xenova/transformers";
import { rmSync } from "fs";
import { response } from "express";

export const getFeatures = async (req, res) => {
  const features = await Features.find();
  res.status(200).json(features);
};

const generateEmbeddings = async () => {
  const pipelineModel = await pipeline(
    "feature-extraction",
    "Xenova/all-MiniLM-L6-v2"
  );
  return pipelineModel;
};

const calculateHash = (data) => {
  const hash = crypto.createHash("sha256");
  hash.update(JSON.stringify(data));
  return hash.digest("hex");
};

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

const updateSimilarityField = async (caseId, similarityObj) => {
  try {
    console.log(similarityObj);

    // Check if similarityObj is a valid object
    if (similarityObj !== null && typeof similarityObj === 'object' && similarityObj.caseId && similarityObj.similarityStr !== undefined) {
      
      // Convert similarityStr to a number
      const similarity = parseFloat(similarityObj.similarityStr);

      // Construct the update query with the correct format
      const updateQuery = { $set: { similarity: { caseId: similarityObj.caseId, similarity } } };
      
      // Update the document
      await embeddings.findByIdAndUpdate(caseId, updateQuery);
      
    } else {
      console.error("Invalid similarityObj format. Expected { caseId: ObjectId, similarityStr: string }");
      return;
    }
  } catch (error) {
    console.error("Error updating similarity field:", error);
  }
};



export const createFeature = async (req, res) => {
  try {
    const {
      age,
      skin_color,
      clothing: {
        upper: { upperClothType, upperClothColor },
        lower: { lowerClothType, lowerClothColor },
      },
      body_size,
      description,
    } = req.body;

    const inputHash = calculateHash({
      age,
      skin_color,
      clothing: {
        upper: { clothType: upperClothType, clothColor: upperClothColor },
        lower: { clothType: lowerClothType, clothColor: lowerClothColor },
      },
      body_size,
    });

    const existingFeature = await Features.findOne({ inputHash });

    if (existingFeature) {
      return res
        .status(400)
        .json({ error: "Duplicate feature already exists" });
    }

    const feature = await Features.create({
      age,
      skin_color,
      clothing: {
        upper: { clothType: upperClothType, clothColor: upperClothColor },
        lower: { clothType: lowerClothType, clothColor: lowerClothColor },
      },
      body_size,
      description,
      inputHash,
    });

    console.log("feature stored successfully");

    const existingEmbeddingsCount = await embeddings.countDocuments();

    if (existingEmbeddingsCount < 1) {
      const caseId = feature._id
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(description, {
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
    } else {
      // Find all embeddings in the database
      const existingEmbeddings = await embeddings.find();
      const caseId = feature._id
      const pipelineModel = await generateEmbeddings();
      const output = await pipelineModel(description, {
        pooling: "mean",
        normalize: true,
      });
      const embeddingData = output.data;

      const embeddingArray = [...embeddingData];
      await embeddings.create({
        caseId,
        embedding: embeddingArray,
        similarity: [{}],
      });
      // Calculate cosine similarity with each existing embedding
      const similarityScores = await existingEmbeddings.map(
        (existingEmbedding) => {
          const similarity = calculateSimilarity(
            embeddingData,
            existingEmbedding.embedding
          );
          return { embeddingId: existingEmbedding._id, similarityScore: similarity };
        }
      );

      // Sort similarity scores in descending order
      similarityScores.sort((a, b) => b.similarityScore - a.similarityScore);

      // Update similarity field for top 10 similar embeddings
      const topNSimilarities = similarityScores.slice(0, 10); // Consider only the top 10 similar embeddings
      console.log(topNSimilarities);

      for (let i = 0; i < topNSimilarities.length; i++){
        console.log(`embedding id: ${embeddingId}, similarity: ${similarity}`);
        const similarityObj = {embeddingId, similarityScore}
        await updateSimilarityField(caseId, similarityObj)
      }
      
      }
    res.status(200).json({ message: "stored" });
  } catch (error) {
    res.status(500).json({ error: "Server error" });
    console.error("Error creating feature:", error);
  }
};

export const compareFeature = async (req, res) => {
  try {
    const {
      age,
      skin_color,
      clothing: {
        upper: { upperClothType, upperClothColor },
        lower: { lowerClothType, lowerClothColor },
      },
      body_size,
    } = req.body;
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

    const response = [];

    matchingCases.forEach((caseData) => {
      const matchingStatus = { id: caseData._id };
      for (const key in criteria) {
        const value = criteria[key];
        if (key.startsWith("clothing.")) {
          const clothingParts = key.split(".");
          const clothingType = clothingParts[1];
          const clothKey = clothingParts[2];

          const caseClothType = caseData.clothing[clothingType][clothKey];
          matchingStatus[`${clothingType} ${clothKey}`] =
            caseClothType === value ? "match" : "did not match";
        } else {
          matchingStatus[key] =
            caseData[key] === value ? "match" : "did not match";
        }
      }
      response.push(matchingStatus);
    });

    res.json({ matchingStatus: response });
  } catch (error) {
    res.status(500).json({ error: "Server error" });
    console.error("Error comparing features:", error.message);
  }
};

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
