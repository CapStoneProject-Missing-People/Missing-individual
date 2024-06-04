import { initializeFeaturesModel, generateEmbeddings, calculateSimilarity } from './someHelperModule'; // Adjust the import based on your structure
import { embeddings } from './models/embeddings'; // Adjust the import based on your structure

export const calculateAverageSimilarity = async (featureData, timeSinceDisappearance) => {
  try {
    const descriptionTypes = [
      "eyeDescription",
      "noseDescription",
      "hairDescription",
      "lastSeenAddressDes",
    ];

    let descriptions = "";
    for (const descType of descriptionTypes) {
      if (featureData[descType]) {
        descriptions += featureData[descType];
      }
    }

    const existingEmbeddingsCount = await embeddings.countDocuments();

    if (existingEmbeddingsCount < 1) {
      console.log("Nothing to compare with");
      return 0;
    } else {
      let featureModelName = "";
      let featureSpecificData = {};

      if (timeSinceDisappearance > 2) {
        featureModelName = "Features_GT_2";
        featureSpecificData = {
          lastSeenLocation: featureData.lastSeenLocation,
          medicalInformation: featureData.medicalInformation,
          circumstanceOfDisappearance: featureData.circumstanceOfDisappearance,
        };
      } else {
        featureModelName = "Features_LTE_2";
        featureSpecificData = {
          "clothing.upper.clothType": featureData.clothingUpperClothType,
          "clothing.upper.clothColor": featureData.clothingUpperClothColor,
          "clothing.lower.clothType": featureData.clothingLowerClothType,
          "clothing.lower.clothColor": featureData.clothingLowerClothColor,
          body_size: featureData.body_size,
        };
      }

      const Features = await initializeFeaturesModel(timeSinceDisappearance);

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
      const similarityScores = existingEmbeddings.map((existingEmbedding) => {
        const similarity = calculateSimilarity(
          embeddingData,
          existingEmbedding.embedding
        );
        return similarity * 100;
      });

      // Construct criteria based on the request body
      const criteria = {
        age: featureData.age,
        "name.firstName": featureData.firstName,
        "name.middleName": featureData.middleName,
        "name.lastName": featureData.lastName,
        skin_color: featureData.skin_color,
        ...featureSpecificData, // Include feature-specific data
      };

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
      let totalSimilarityScore = 0;
      let totalComparisons = 0;

      matchingCases.forEach((caseData) => {
        let similarityScore = 0;
        let numMatchingFields = 0;

        for (const key in criteria) {
          const value = criteria[key];
          if (key === "age") {
            if (caseData.age === value) {
              similarityScore += 100;
              numMatchingFields += 1;
            } else {
              let ageRangeMatch = false;
              let caseDataAgeRange = "";
              let newReqAge = "";
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
                ageRangeMatch = true;
                similarityScore += 85;
                numMatchingFields += 1;
              }
            }
          } else if (key.startsWith("name.")) {
            const nameWritten = key.split(".");
            const nameType = nameWritten[1];
            if (caseData.name[nameType] === value) {
              similarityScore += 100;
              numMatchingFields += 1;
            }
          } else if (key.startsWith("clothing.")) {
            const clothingParts = key.split(".");
            const clothingType = clothingParts[1];
            const clothKey = clothingParts[2];
            const caseClothType = caseData.clothing[clothingType][clothKey];
            if (
              (caseClothType === "blue" && value === "light blue") ||
              (caseClothType === "light blue" && value === "blue") ||
              (caseClothType === "yellow" && value === "orange") ||
              (caseClothType === "orange" && value === "yellow")
            ) {
              similarityScore += 85;
              numMatchingFields += 1;
            } else if (caseClothType === value) {
              similarityScore += 100;
              numMatchingFields += 1;
            }
          } else if (caseData[key] === value) {
            similarityScore += 100;
            numMatchingFields += 1;
          }
        }

        similarityScores.forEach((score) => {
          if (score.existingCaseId.equals(caseData._id)) {
            similarityScore += score.similarityScore * 100;
            numMatchingFields += 1;
          }
        });

        if (numMatchingFields > 0) {
          totalSimilarityScore += similarityScore / numMatchingFields;
          totalComparisons += 1;
        }
      });

      const averageSimilarity = totalComparisons > 0 ? totalSimilarityScore / totalComparisons : 0;

      return averageSimilarity;
    }
  } catch (error) {
    console.error("Error calculating similarity:", error.message);
    throw new Error("Error calculating similarity");
  }
};
