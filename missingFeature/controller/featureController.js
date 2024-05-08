import Features from "../models/featureModel.js";
import crypto from "crypto";
import embeddings from "../models/embeddingsModel.js";
import { pipeline } from "@xenova/transformers";

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
        throw new Error ("invalid filter criteria age range")
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
        filterCriteria.user_id = req.user.id;
      }
    }

    //Query database with constructed filter criteria
    const features = await Features.find(filterCriteria).lean();

    res.status(200).json(features);
  } catch {
    res.status(500).json({ error: "Server error" });
    console.log("Error ferching features: ", error.message);
  }
};

//@desc Get single Feature
//@route GET /api/features/getSingle/:id
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
export const createFeature = async (req, res) => {
  try {
    const {
      age,
      name: { 
        firstName, 
        middleName, 
        lastName,
       },
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
    console.log(lastName)

    const inputHash = calculateHash({
      age,
      name: { firstName, middleName, lastName },
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
    //check if incomming feature already in database
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

    const feature = await Features.create({
      age,
      name: {firstName, middleName, lastName},
      skin_color,
      clothing: {
        upper: { clothType: upperClothType, clothColor: upperClothColor },
        lower: { clothType: lowerClothType, clothColor: lowerClothColor },
      },
      body_size,
      description: descriptions,
      inputHash,
      user_id: req.user.id,
    });
    console.log("feature stored successfully");

    const existingEmbeddingsCount = await embeddings.countDocuments();
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

      //sort similarity scores in descending order
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
    res.status(200).json({ message: " feature stored succeffully",  createdFeature: feature});
  } catch (error) {
    res.status(500).json({ error: "Server error" });
    console.error("Error creating feature:", error);
  }
};

//@desc compare Feature
//@route POST /api/features/compare
//@access public
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
        name: {firstName, middleName, lastName},
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
        "name.firstName": firstName,
        "name.middleName": middleName,
        "name.lastName": lastName,
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
          } else if (!key.startsWith("clothing." && !key.startsWith("name."))) {
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

          if (key.startsWith("name.")) {
            const nameType = key.split(".")
            const names = nameType[1]
            const firstName = caseData.name[names]
            matchingStatus[`${names}`] = firstName === value ? "match" : "did not match"
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

//@desc updare Feature
//@route PUT /api/features
//@access private
export const updateFeature = async (req, res) => {
  try {
    const feature = await Features.findById(req.params.id);
    if (!feature) {
      res.status(404);
      throw new Error("Feature not found");
    }

    if( feature.user_id.toString() !== req.user.id) {
      res.status(403)
      throw new Error("User don't have permission to update other users feature!")
    }

    const {
      age,
      skin_color,
      name: {firstName, middleName, lastName},
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
    const concatenatedDescription = `${eyeDescription}.${ noseDescription}.${ hairDescription}.${ lastSeenAddressDes}`;

    const updatedFeature = await Features.findByIdAndUpdate(
      req.params.id,
     {
      age,
      name: {firstName, middleName, lastName},
      skin_color,
      clothing: {
        upper: { clothType: upperClothType, clothColor: upperClothColor },
        lower: { clothType: lowerClothType, clothColor: lowerClothColor },
      },
      body_size,
      description: concatenatedDescription,
    },
      { new: true }
    );
    res.status(201).json({ FeatureUpdated: updatedFeature }) ;
    console.log("Feature updated successfully");
  } catch (error) {
    res.json({ error: error.message });
    console.error(`Error updating feature ${error.message}`);
  }
};


//@desc Delete Feature
//@route Delete /api/features/delete/:id
//@access private
//an endpoint to delete fature
export const deleteFeature = async (req, res) => {
  try{
    const feature = await Features.findById(req.params.id)
    if (!feature) {
      res.status(404)
      throw new Error("feature not found")
    }
    if (feature.user_id.toString() !== req.user.id) {
      res.status(403)
      throw new Error("User don't have permission to update other users feature!")
    }
    await feature.deleteOne()
    res.status(200).json({message: "feature deleted succussfully", feature})
  } catch (error) {
    res.json({title: "UNAUTHORIZED", message: error.message})
  }
}

//@desc search Feature
//@route search /api/features/search
//@access public
//an endpoint to search fature
export const searchFeature = async (req, res) => {
  try {
    const { searchBy, searchTerm } = req.body;

    if (!searchBy || !searchTerm) {
      return res.status(400).json({ error: 'Both searchBy and searchTerm are required.' });
    }

    let searchCriteria = {};
    if (searchBy === 'firstName') {
      searchCriteria['name.firstName'] = { $regex: searchTerm, $options: 'i' };
    } else if (searchBy === 'middleName') {
      searchCriteria['name.middleName'] = { $regex: searchTerm, $options: 'i' };
    } else if (searchBy === 'lastName') {
      searchCriteria['name.lastName'] = { $regex: searchTerm, $options: 'i' };
    } else {
      return res.status(400).json({ error: 'Invalid searchBy parameter.' });
    }

    // Query database with constructed search criteria
    const features = await Features.find(searchCriteria).lean();

    res.status(200).json(features);
  } catch (error) {
    console.error('Error fetching features:', error.message);
    res.status(500).json({ error: 'Server error' });
  }
};
